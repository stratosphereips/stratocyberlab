<script>
  import { onMount, onDestroy, tick } from 'svelte';
  import { writable, get } from 'svelte/store';
  import { marked } from 'marked';
  import { CommandLine, PaperAirplane, QuestionMarkCircle, Sparkles } from 'svelte-heros';
  import ExternalModels from './ExternalModels.svelte';
  import TerminalContext from './TerminalContext.svelte';
  import { dashboardReset } from './stores';

  export let terminalOpen = false;
  export let getTerminalContext = async () => null;

  let includeTerminalContext = true;

  // ---- chat state (preserved rendering) ----
  let chatHistory = writable([]);
  let newMessage = '';
  let waitingForReply = false;
  let messageList;
  let composerInput;
  const COMPOSER_MAX_HEIGHT = 160;
  const TERMINAL_EXPLANATION_PROMPT =
    'Explain what is happening in the terminal output and help me understand it and/or fix potential errors.';

  async function scrollChatToBottom() {
    await tick();
    if (messageList) messageList.scrollTop = messageList.scrollHeight;
  }

  // Keep the composer as tall as its content, up to a fixed ceiling.
  function autoResizeComposer() {
    if (!composerInput) return;
    composerInput.style.height = 'auto';
    composerInput.style.height = `${Math.min(composerInput.scrollHeight, COMPOSER_MAX_HEIGHT)}px`;
  }

  async function resetComposerHeight() {
    await tick();
    autoResizeComposer();
  }

  // ---- model + server state ----
  let currentModel = '';
  let currentExternalId = null;
  let externalModels = [];
  let localError = '';
  let stateError = '';
  let localModels = []; // [{ name, size }]
  let pulls = {}; // { [model]: { status, total, completed, percent } }
  let checking = true;
  let stateRequest = 0;

  // ---- UI state ----
  let manageModelsOpen = false;
  let downloadExpanded = false;
  let modelToDownload = '';
  let fetchingInfo = false;
  let expandedThoughts = {};

  const POLL_MS = 1200;

  // Controlled polling (only when downloads are active or just started)
  let pollTimer = null;
  let isPolling = false;
  let forcePollCycles = 0; // small grace period right after starting a pull

  onMount(async () => {
    await refreshState();
    // Start polling only if initial state shows active pulls
    if (Object.keys(pulls || {}).length > 0) startPolling();
  });
  onDestroy(stopPolling);

  onMount(() => dashboardReset.subscribe((event) => {
    if (event && event.scope !== 'progress') {
      manageModelsOpen = false;
      currentModel = '';
      currentExternalId = null;
      externalModels = [];
      refreshState();
    }
  }));

  function schedulePoll() {
    pollTimer = setTimeout(pollTick, POLL_MS);
  }

  function stopPolling() {
    if (pollTimer) {
      clearTimeout(pollTimer);
      pollTimer = null;
    }
    isPolling = false;
    forcePollCycles = 0;
  }

  function startPolling(graceCycles = 0) {
    if (isPolling) return;
    isPolling = true;
    forcePollCycles = graceCycles;
    pollTick(); // immediate tick
  }

  async function pollTick() {
    try {
      const r = await fetch('/api/llm/pulls');
      const data = await r.json();
      pulls = data.pulls || {};
      const pullingAny = Object.keys(pulls).length > 0;

      if (pullingAny) {
        await refreshModelsOnly(); // sizes/locals might change mid-pull
        schedulePoll();
      } else if (forcePollCycles > 0) {
        // right after starting a pull, server may need a moment to surface it
        forcePollCycles -= 1;
        schedulePoll();
      } else {
        await refreshModelsOnly();
        stopPolling();
      }
    } catch {
      if (isPolling) {
        if (forcePollCycles > 0) {
          forcePollCycles -= 1;
          schedulePoll();
        } else {
          stopPolling();
        }
      }
    }
  }

  async function refreshModelsOnly() {
    try {
      const res = await fetch('/api/llm/models');
      const data = await res.json();
      localModels = data.models || [];
    } catch {
      // intentionally ignored
    }
  }

  async function refreshState() {
    const requestId = ++stateRequest;
    checking = true;
    stateError = '';
    try {
      const r = await fetch('/api/llm/state');
      if (!r.ok) throw new Error('Could not load model configuration.');
      const data = await r.json();
      if (requestId !== stateRequest) return;
      currentModel = data.current_model || '';
      currentExternalId = data.current_external_id ?? null;
      externalModels = data.external_models || [];
      localError = data.local_error || '';
      localModels = data.models || [];
      pulls = data.pulls || {};
    } catch (err) {
      if (requestId === stateRequest) stateError = err.message;
    } finally {
      if (requestId === stateRequest) checking = false;
    }
  }

  // ---- chat actions ----
  async function sendMessage(content = null) {
    const fromComposer = content === null;
    const messageContent = fromComposer ? newMessage : content;
    if (!messageContent.trim() || waitingForReply) return;

    const message = { role: 'user', content: messageContent };
    if (fromComposer) {
      newMessage = '';
      resetComposerHeight();
    }
    waitingForReply = true;

    try {
      if (terminalOpen && includeTerminalContext) {
        const context = await getTerminalContext();
        if (context && terminalOpen && includeTerminalContext) message.terminal_context = context;
      }
      chatHistory.update((h) => [...h, message]);
      const body = get(chatHistory);
      await scrollChatToBottom();
      const response = await fetch('/api/llm/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });

      if (!response.ok) {
        const t = await response.text();
        throw new Error(t || `Chat failed (${response.status})`);
      }
      chatHistory.set(await response.json());
      await scrollChatToBottom();
    } catch (err) {
      if (fromComposer && !get(chatHistory).includes(message)) {
        newMessage = message.content;
        resetComposerHeight();
      }
      alert(err);
    } finally {
      waitingForReply = false;
    }
  }

  function clearChat() {
    chatHistory.set([]);
    expandedThoughts = {};
  }

  function handleKeyPress(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      if (!waitingForReply) sendMessage();
    }
  }

  // ---- model mgmt actions ----
  function fmtBytes(n) {
    if (!n && n !== 0) return '—';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    let i = 0;
    let v = Number(n);
    while (v >= 1024 && i < units.length - 1) {
      v /= 1024;
      i++;
    }
    return `${v.toFixed(1)} ${units[i]}`;
  }

  async function setModel(name, externalId = null) {
    if (!name || waitingForReply || (name === currentModel && externalId === currentExternalId)) return;
    try {
      const r = await fetch('/api/llm/model', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, external_id: externalId }),
      });
      if (!r.ok) throw new Error(await r.text());
      currentModel = name;
      currentExternalId = externalId;
    } catch (e) {
      alert(e);
    }
  }

  async function deleteLocal(name) {
    const isCurrent = currentExternalId === null && name === currentModel;
    const msg = isCurrent
      ? `Remove local model "${name}"?\n\nThis is currently selected; the selection will be cleared.`
      : `Remove local model "${name}"?`;
    if (!confirm(msg)) return;

    try {
      const r = await fetch(`/api/llm/models/${encodeURIComponent(name)}`, {
        method: 'DELETE',
      });
      if (!r.ok) throw new Error(await r.text());

      // Get authoritative state from the server — this will also clear current_model if needed.
      await refreshState();
    } catch (e) {
      alert(e);
    }
  }

  async function confirmAndDownload() {
    const name = modelToDownload.trim();
    if (!name || fetchingInfo) return;

    fetchingInfo = true;
    try {
      const r = await fetch('/api/llm/models/pull', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name }),
      });
      if (!r.ok && r.status !== 409) throw new Error(await r.text());

      modelToDownload = '';
      // Begin polling now that a download has been initiated.
      startPolling(5);
    } catch (e) {
      alert(e);
    } finally {
      fetchingInfo = false;
    }
  }

  $: pullingList = Object.entries(pulls || {}).map(([name, p]) => ({
    name,
    ...p,
    percent: p && p.total ? Math.min(100, Math.round(((p.completed || 0) * 100) / p.total)) : undefined,
  }));

  function parseThinking(content) {
    const thinkRegex = /<think>([\s\S]*?)<\/think>/g;
    let match;
    const thoughts = [];
    let processedContent = content;

    while ((match = thinkRegex.exec(content)) !== null) {
      thoughts.push(match[1].trim());
      processedContent = processedContent.replace(match[0], '');
    }

    return {
      thoughts,
      content: processedContent.trim(),
    };
  }

  function toggleThoughts(messageIndex) {
    expandedThoughts[messageIndex] = !expandedThoughts[messageIndex];
    expandedThoughts = { ...expandedThoughts };
  }
</script>

<style>
  .typing-indicator {
    display: inline-block;
    font-size: 1.5em;
  }
  .typing-indicator span {
    display: inline-block;
    animation: blink 1s infinite;
  }
  .typing-indicator span:nth-child(2) {
    animation-delay: 0.3s;
  }
  .typing-indicator span:nth-child(3) {
    animation-delay: 0.6s;
  }
  @keyframes blink {
    0%,
    100% {
      opacity: 0;
    }
    50% {
      opacity: 1;
    }
  }

  .message-bubble {
    max-width: 92%;
    min-width: 0;
  }

  .chat-composer {
    max-height: 65%;
    overflow-y: auto;
    background: var(--bs-body-bg);
  }

  /* ---- context / suggestion chips ---- */
  .chip {
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    padding: 0.3rem 0.7rem;
    font-size: 0.8125rem;
    line-height: 1.2;
    border: 1px solid var(--bs-border-color);
    border-radius: 999px;
    background: transparent;
    color: var(--bs-secondary-color);
    cursor: pointer;
    transition:
      background-color 0.15s ease-in-out,
      border-color 0.15s ease-in-out,
      color 0.15s ease-in-out;
  }

  .chip:hover:not(:disabled),
  .chip:focus-visible {
    border-color: var(--bs-secondary-color);
    color: var(--bs-body-color);
  }

  .chip:disabled {
    cursor: default;
    opacity: 0.55;
  }

  .context-chip input {
    cursor: inherit;
  }

  .context-chip:has(input:disabled) {
    cursor: default;
    opacity: 0.55;
  }

  .context-chip.is-on {
    background: var(--bs-secondary-bg);
    border-color: transparent;
    color: var(--bs-body-color);
  }

  .info-chip {
    display: inline-flex;
    align-items: center;
    padding: 0;
    border: 0;
    background: transparent;
    color: var(--bs-secondary-color);
    cursor: help;
  }

  .info-chip:hover {
    color: var(--bs-body-color);
  }

  /* ---- input box ---- */
  .composer-box {
    border: 1px solid var(--bs-border-color);
    border-radius: 1.25rem;
    background: var(--bs-body-bg);
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
    transition:
      border-color 0.15s ease-in-out,
      box-shadow 0.15s ease-in-out;
  }

  .composer-box:focus-within {
    border-color: var(--bs-secondary-color);
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.07);
  }

  .composer-box.is-disabled {
    background: var(--bs-tertiary-bg);
  }

  .composer-input {
    display: block;
    width: 100%;
    resize: none;
    border: 0;
    outline: none;
    background: transparent;
    color: var(--bs-body-color);
    font-size: 0.9375rem;
    line-height: 1.45;
    padding: 0.75rem 0.9rem 0.25rem;
    max-height: 160px;
    overflow-y: auto;
  }

  .composer-input::placeholder {
    color: var(--bs-secondary-color);
  }

  .composer-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 0.5rem;
    padding: 0.25rem 0.5rem 0.5rem 0.9rem;
  }

  .composer-hint {
    font-size: 0.75rem;
    color: var(--bs-secondary-color);
  }

  .composer-send {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    flex-shrink: 0;
    border: 0;
    border-radius: 999px;
    background: var(--bs-body-color);
    color: var(--bs-body-bg);
    transition:
      opacity 0.15s ease-in-out,
      transform 0.15s ease-in-out;
  }

  .composer-send:disabled {
    opacity: 0.3;
  }

  .composer-send:not(:disabled):hover {
    transform: translateY(-1px);
  }
</style>

<div class="h-100">
  <div class="card shadow-sm h-100 d-flex flex-column overflow-hidden" style="border-radius: 0">
    <!-- Header (h-scroll lives inside this element) -->
    <div class="card-header flex-shrink-0 sticky-top bg-white overflow-auto">
      <div class="d-flex flex-nowrap align-items-center justify-content-between">
        <div class="text-nowrap">
          <div class="h5 mb-0">AI Assistant</div>
          <small class="text-muted">
            Model:&nbsp;{#if checking}loading…{:else}{currentModel || '—'}{/if}
            {#if !checking && currentExternalId !== null}
              (external){/if}
          </small>
        </div>

        <div class="d-flex gap-2 ms-2">
          <button
            class="btn btn-outline-secondary btn-sm"
            on:click={() => {
              manageModelsOpen = true;
              refreshState();
            }}
          >
            Models
          </button>
          <button class="btn btn-outline-danger btn-sm" disabled={waitingForReply} on:click={clearChat}>
            Reset chat
          </button>
        </div>
      </div>
    </div>

    {#if stateError}<div class="alert alert-danger m-2" role="alert">{stateError}</div>{/if}
    {#if pullingList.length}
      <div class="px-3 pt-2">
        {#each pullingList as p}
          <div class="d-flex align-items-center gap-2 mb-2">
            <div class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></div>
            <div class="flex-grow-1">
              <div class="small fw-semibold">{p.name} — {p.status}</div>
              {#if p.percent !== undefined}
                <div
                  class="progress"
                  role="progressbar"
                  aria-valuenow={p.percent}
                  aria-valuemin="0"
                  aria-valuemax="100"
                >
                  <div class="progress-bar" style={`width:${p.percent}%`}></div>
                </div>
              {/if}
            </div>
          </div>
        {/each}
      </div>
    {/if}

    <div class="card-body d-flex flex-column p-0 overflow-hidden" style="min-height: 0">
      {#if checking}
        <div class="d-flex align-items-center justify-content-center py-4">Loading…</div>
      {:else}
        <div class="d-flex flex-column" style="flex: 1; min-height: 0">
          <div class="flex-grow-1 overflow-auto p-3" style="min-height: 0" bind:this={messageList}>
            {#each $chatHistory as { role, content, terminal_context }, index}
              {#if role === 'user'}
                <div class="mb-2 d-flex justify-content-end">
                  <div class="message-bubble p-2 rounded-2 bg-danger-subtle text-body text-start">
                    {content}
                    {#if terminal_context}<TerminalContext context={terminal_context} />{/if}
                  </div>
                </div>
              {:else}
                {@const parsed = parseThinking(content)}
                <div class="mb-2 d-flex justify-content-start">
                  <div class="message-bubble p-2 rounded-2 bg-light text-body text-start">
                    {#if parsed.thoughts.length > 0}
                      <button class="btn btn-sm btn-light mb-2" on:click={() => toggleThoughts(index)}>
                        💭 Thoughts {expandedThoughts[index] ? '▼' : '▶'}
                      </button>
                      {#if expandedThoughts[index]}
                        {#each parsed.thoughts as thought}
                          <div
                            class="small fst-italic text-secondary border-start ps-3 bg-light-subtle rounded-2 py-2 mb-2"
                          >
                            {thought}
                          </div>
                        {/each}
                      {/if}
                    {/if}
                    {#if parsed.content}
                      <!-- eslint-disable-next-line svelte/no-at-html-tags -->
                      {@html marked.parse(parsed.content)}
                    {/if}
                  </div>
                </div>
              {/if}
            {/each}

            {#if waitingForReply}
              <div class="ms-3 typing-indicator"><span>.</span><span>.</span><span>.</span></div>
            {/if}
          </div>

          <div class="chat-composer flex-shrink-0 p-3 border-top">
            {#if terminalOpen}
              <div class="d-flex flex-wrap align-items-center gap-2 mb-2">
                <label class="chip context-chip" class:is-on={includeTerminalContext}>
                  <input
                    type="checkbox"
                    class="form-check-input m-0"
                    bind:checked={includeTerminalContext}
                    disabled={waitingForReply}
                  />
                  <CommandLine width="15" height="15" aria-hidden="true" />
                  <span>Terminal context</span>
                </label>
                <button
                  type="button"
                  class="info-chip"
                  aria-label="Terminal context limits"
                  title="Includes the latest 100 lines or 10,000 UTF-8 bytes, whichever limit is reached first. Captured when you send."
                >
                  <QuestionMarkCircle width="16" height="16" aria-hidden="true" />
                </button>
                {#if includeTerminalContext}
                  <button
                    type="button"
                    class="chip ms-auto"
                    disabled={!currentModel || waitingForReply}
                    title="Send the latest terminal output to the AI for troubleshooting."
                    on:click={() => sendMessage(TERMINAL_EXPLANATION_PROMPT)}
                  >
                    <Sparkles width="15" height="15" aria-hidden="true" />
                    <span>Explain the output</span>
                  </button>
                {/if}
              </div>
            {/if}

            <div class="composer-box" class:is-disabled={!currentModel}>
              <textarea
                class="composer-input"
                rows="1"
                bind:this={composerInput}
                bind:value={newMessage}
                disabled={!currentModel}
                placeholder={currentModel ? 'Ask the assistant anything…' : 'Select a model to start chatting'}
                on:keypress={handleKeyPress}
                on:input={autoResizeComposer}
              ></textarea>
              <div class="composer-footer">
                <span class="composer-hint">Enter to send · Shift + Enter for a new line</span>
                <button
                  type="button"
                  class="composer-send"
                  aria-label="Send message"
                  title="Send message"
                  disabled={!currentModel || waitingForReply || !newMessage.trim()}
                  on:click={() => sendMessage()}
                >
                  <PaperAirplane width="16" height="16" aria-hidden="true" />
                </button>
              </div>
            </div>
          </div>
        </div>
      {/if}
    </div>
  </div>

  <!-- Manage models modal -->
  {#if manageModelsOpen}
    <div class="modal-backdrop show"></div>
    <div class="modal d-block" tabindex="-1">
      <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Manage models</h5>
            <button
              type="button"
              class="btn-close"
              aria-label="Close manage models"
              on:click={() => (manageModelsOpen = false)}
            ></button>
          </div>
          <div class="modal-body">
            <h5>Local models</h5>
            {#if localError}
              <div class="text-muted">{localError}</div>
            {:else if localModels.length === 0}
              <div class="text-muted">No local models yet.</div>
            {:else}
              <div class="list-group">
                {#each localModels as m}
                  <div class="list-group-item d-flex align-items-center justify-content-between">
                    <div>
                      <div class="fw-semibold">{m.name}</div>
                      <small class="text-muted">{fmtBytes(m.size)}</small>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                      {#if currentExternalId === null && currentModel === m.name}
                        <button class="btn btn-sm btn-outline-success" disabled> Selected </button>
                      {:else}
                        <button
                          class="btn btn-sm btn-outline-secondary"
                          disabled={waitingForReply}
                          on:click={() => setModel(m.name)}
                        >
                          Use this
                        </button>
                      {/if}
                      <button
                        class="btn btn-sm btn-outline-danger"
                        disabled={waitingForReply}
                        on:click={() => deleteLocal(m.name)}
                      >
                        Remove
                      </button>
                    </div>
                  </div>
                {/each}
              </div>
            {/if}
            <button
              class="btn btn-sm btn-outline-primary mt-3"
              aria-expanded={downloadExpanded}
              aria-controls="local-download-form"
              on:click={() => (downloadExpanded = !downloadExpanded)}
            >
              <span aria-hidden="true">{downloadExpanded ? '−' : '+'}</span>
              {downloadExpanded ? 'Close download' : 'Download local model'}
            </button>
            {#if downloadExpanded}
              <div id="local-download-form" class="border rounded bg-light p-3 mt-3">
                <label for="local-model-name" class="form-label">Download a new model</label>
                <div class="input-group">
                  <input
                    id="local-model-name"
                    class="form-control"
                    placeholder="model[:tag]"
                    bind:value={modelToDownload}
                  />
                  <button
                    class="btn btn-primary"
                    on:click={confirmAndDownload}
                    disabled={fetchingInfo || !modelToDownload.trim()}
                  >
                    {#if fetchingInfo}
                      <span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>
                    {/if}
                    Download
                  </button>
                </div>
                <div class="form-text">
                  Browse models on <a href="https://ollama.com/search" target="_blank" rel="noopener"
                    >ollama.com/search</a
                  >. Before downloading, check the model's size. The model will be downloaded locally to your machine.
                  For a start, we recommend <code>qwen3:1.7b</code> with a size 1.3GB.
                </div>
              </div>
            {/if}
            <hr class="my-4" />
            <ExternalModels
              models={externalModels}
              {currentExternalId}
              {waitingForReply}
              onSelect={setModel}
              onChange={refreshState}
            />
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" on:click={() => (manageModelsOpen = false)}>Close</button>
          </div>
        </div>
      </div>
    </div>
  {/if}
</div>
