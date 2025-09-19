<script>
  import { onMount } from 'svelte';
  import { writable, get } from 'svelte/store';
  import { marked } from 'marked';

  // ---- chat state (preserved rendering) ----
  let chatHistory = writable([]);
  let newMessage = '';
  let waitingForReply = false;

  // ---- model + server state ----
  let currentModel = '';
  let localModels = []; // [{ name, size }]
  let pulls = {}; // { [model]: { status, total, completed, percent } }
  let checking = true;

  // ---- UI state ----
  let manageModelsOpen = false;
  let modelToDownload = '';
  let fetchingInfo = false;
  let expandedThoughts = {};

  const POLL_MS = 1200;

  // Controlled polling (only when downloads are active or just started)
  let pollTimer = null;
  let isPolling = false;
  let forcePollCycles = 0; // small grace period right after starting a pull

  const LS_KEY_MODEL = 'ai-assistant.currentModel';

  onMount(async () => {
    // Read the browser selection before touching network state
    let preferred = '';
    try {
      preferred = localStorage.getItem(LS_KEY_MODEL) || '';
    } catch {
      // intentionally ignored
    }

    await refreshState();
    // Start polling only if initial state shows active pulls
    if (Object.keys(pulls || {}).length > 0) startPolling();

    if (preferred) {
      await setModel(preferred);
    }
  });

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
    checking = true;
    try {
      const r = await fetch('/api/llm/state');
      const data = await r.json();
      currentModel = data.current_model || '';
      localModels = data.models || [];
      pulls = data.pulls || {};
    } finally {
      checking = false;
    }
  }

  // ---- chat actions ----
  async function sendMessage() {
    if (!newMessage.trim() || waitingForReply) return;

    chatHistory.update((h) => [...h, { role: 'user', content: newMessage }]);
    const body = get(chatHistory);
    newMessage = '';
    waitingForReply = true;

    try {
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
    } catch (err) {
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

  async function setModel(name) {
    if (!name || name === currentModel) return;
    try {
      const r = await fetch('/api/llm/model', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name }),
      });
      if (!r.ok) throw new Error(await r.text());
      currentModel = name;
      try {
        localStorage.setItem(LS_KEY_MODEL, name);
      } catch {
        // intentionally ignored
      }
    } catch (e) {
      alert(e);
    }
  }

  async function deleteLocal(name) {
    const isCurrent = name === currentModel;
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
          </small>
        </div>

        <div class="d-flex gap-2 ms-2">
          <button class="btn btn-outline-secondary btn-sm" on:click={() => (manageModelsOpen = true)}>
            Manage models
          </button>
          <button class="btn btn-outline-danger btn-sm" on:click={clearChat}> Reset chat </button>
        </div>
      </div>
    </div>

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

    <div class="card-body d-flex flex-column p-0 overflow-y-auto">
      {#if checking}
        <div class="d-flex align-items-center justify-content-center py-4">Loading…</div>
      {:else}
        <div class="d-flex flex-column" style="flex: 1">
          <div class="flex-grow-1 overflow-auto p-3">
            {#each $chatHistory as { role, content }, index}
              {#if role === 'user'}
                <div class="mb-2 d-flex justify-content-end">
                  <div class="message-bubble p-2 rounded-2 bg-danger-subtle text-body text-start">
                    {content}
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

          <div class="input-group p-2 border-top bg-white">
            <textarea
              class="form-control bg-light"
              bind:value={newMessage}
              placeholder="Type a message and hit enter"
              on:keypress={handleKeyPress}
            ></textarea>
          </div>
        </div>
      {/if}
    </div>
  </div>

  <!-- Manage models modal -->
  {#if manageModelsOpen}
    <div class="modal-backdrop show"></div>
    <div class="modal d-block" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Manage models</h5>
            <button type="button" class="btn-close" on:click={() => (manageModelsOpen = false)}></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <span class="form-label">Download a new model:</span>
              <div class="input-group">
                <input class="form-control" placeholder="model[:tag]" bind:value={modelToDownload} />
                <button class="btn btn-primary" on:click={confirmAndDownload} disabled={fetchingInfo}>
                  {#if fetchingInfo}
                    <span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>
                  {/if}
                  Download
                </button>
              </div>
              <div class="form-text">
                Browse models on <a href="https://ollama.com/search" target="_blank" rel="noopener">ollama.com/search</a
                >. Before downloading, check the model's size. The model will be downloaded locally to your machine. For
                a start, we recommend <code>qwen3:1.7b</code> with a size 1.3GB.
              </div>
            </div>

            <hr />

            <div class="mb-2 fw-semibold">Local models</div>
            {#if localModels.length === 0}
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
                      {#if currentModel === m.name}
                        <button class="btn btn-sm btn-outline-success" disabled> Selected </button>
                      {:else}
                        <button class="btn btn-sm btn-outline-secondary" on:click={() => setModel(m.name)}>
                          Use this
                        </button>
                      {/if}
                      <button class="btn btn-sm btn-outline-danger" on:click={() => deleteLocal(m.name)}>
                        Remove
                      </button>
                    </div>
                  </div>
                {/each}
              </div>
            {/if}
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" on:click={() => (manageModelsOpen = false)}>Close</button>
          </div>
        </div>
      </div>
    </div>
  {/if}
</div>
