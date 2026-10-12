<script>
  import { onMount } from 'svelte';
  import { Cog6Tooth } from 'svelte-heros';

  export let limits;
  export let options;
  export let disabled = false;

  const STORAGE_KEY = 'scl-terminal-context';
  let panel;
  let trigger;
  let linesInput;
  let draftLines;
  let draftKB;
  let open = false;
  let storageError = '';

  function defaults() {
    return { lines: limits.default_lines, bytes: limits.default_bytes };
  }

  function valid(value) {
    return (
      Number.isSafeInteger(value?.lines) &&
      value.lines > 0 &&
      Number.isSafeInteger(value?.bytes) &&
      value.bytes >= 1000 &&
      value.bytes <= limits.max_bytes
    );
  }

  $: if (limits && !valid(options)) options = defaults();

  onMount(() => {
    try {
      const saved = JSON.parse(localStorage.getItem(STORAGE_KEY));
      if (valid(saved)) options = saved;
    } catch {
      // Missing or invalid browser preferences use the defaults.
    }
  });

  function showSettings() {
    draftLines = options.lines;
    draftKB = options.bytes / 1000;
    storageError = '';
    const rect = trigger.getBoundingClientRect();
    panel.style.left = `${Math.max(8, Math.min(rect.left, window.innerWidth - 312))}px`;
    panel.showPopover();
    panel.style.top = `${Math.max(8, rect.top - panel.offsetHeight - 8)}px`;
    linesInput.focus();
  }

  function apply() {
    options = { lines: draftLines, bytes: Math.round(draftKB * 1000) };
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(options));
    } catch {
      storageError = 'Applied for this session. Browser storage is unavailable.';
      return;
    }
    panel.hidePopover();
    trigger.focus();
  }
</script>

{#if options && limits}
  <button
    type="button"
    class="context-limits"
    bind:this={trigger}
    {disabled}
    aria-label="Terminal context settings"
    title="Adjust terminal context limits"
    aria-expanded={open}
    aria-controls="terminal-context-settings"
    on:click={showSettings}
  >
    <Cog6Tooth width="15" height="15" aria-hidden="true" />
  </button>
  <div
    id="terminal-context-settings"
    popover="auto"
    bind:this={panel}
    on:toggle={(event) => (open = event.newState === 'open')}
  >
    <form on:submit|preventDefault={apply}>
      <strong>Terminal context</strong>
      <p class="small text-body-secondary mt-2">Include the newest terminal output along with your message.</p>
      <label class="form-label small" for="terminal-context-lines">Maximum lines</label>
      <input
        id="terminal-context-lines"
        class="form-control form-control-sm mb-2"
        type="number"
        min="1"
        max={Number.MAX_SAFE_INTEGER}
        step="1"
        required
        bind:value={draftLines}
        bind:this={linesInput}
      />
      <label class="form-label small" for="terminal-context-kb">Maximum size (KB)</label>
      <input
        id="terminal-context-kb"
        class="form-control form-control-sm"
        type="number"
        min="1"
        max={limits.max_bytes / 1000}
        step="0.1"
        required
        bind:value={draftKB}
      />
      <p class="small text-body-secondary mt-2 mb-2">
        Stops when either limit is reached. Maximum {limits.max_bytes / 1_000_000} MB.
      </p>
      <p class="small text-body-secondary">
        Larger context uses more tokens and may slow replies. Changes apply only to future messages.
      </p>
      {#if storageError}<p class="small" role="status">{storageError}</p>{/if}
      <div class="d-flex justify-content-between gap-2">
        <button
          type="button"
          class="btn btn-sm btn-link p-0"
          on:click={() => {
            draftLines = limits.default_lines;
            draftKB = limits.default_bytes / 1000;
          }}>Reset to defaults</button
        >
        <button class="btn btn-sm btn-primary" type="submit" {disabled}>Apply</button>
      </div>
    </form>
  </div>
{/if}

<style>
  .context-limits {
    border: 0;
    background: transparent;
    color: var(--bs-secondary-color);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0;
    cursor: pointer;
  }
  .context-limits:hover {
    color: var(--bs-body-color);
  }
  .context-limits:disabled {
    opacity: 0.55;
  }
  [popover] {
    position: fixed;
    font-size: 1rem;
    line-height: 1.5;
    cursor: default;
    inset: auto;
    margin: 0;
    width: min(304px, calc(100vw - 16px));
    max-height: 80vh;
    overflow-y: auto;
    padding: 1rem;
    border: 1px solid var(--bs-border-color);
    border-radius: 0.75rem;
    background: var(--bs-body-bg);
    color: var(--bs-body-color);
    box-shadow: 0 4px 20px #0002;
  }
</style>
