<script>
  import { clearProgress, dashboardReset } from '../stores';

  let dialog;
  let scope = 'progress';
  let busy = false;
  let error = '';
  let notice = '';
  const choices = [
    { id: 'progress', title: 'Learning progress', detail: 'Clear all solved tasks and campaign progress.' },
    { id: 'ai', title: 'AI settings', detail: 'Remove external model configurations.' },
    { id: 'everything', title: 'Everything', detail: 'Clear both learning progress and AI settings.' },
  ];

  async function reset() {
    busy = true;
    error = '';
    try {
      const response = await fetch('/api/state/reset', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ scope }),
      });
      const result = await response.json();
      if (!response.ok) throw new Error(result.error || 'Could not reset dashboard state.');
      dashboardReset.set({ scope, at: Date.now() });
      if (scope !== 'ai') await clearProgress();
      notice = `${choices.find((choice) => choice.id === scope).title} reset.`;
      dialog.close();
    } catch (err) {
      error = err.message || 'Could not reset dashboard state.';
    } finally {
      busy = false;
    }
  }
</script>

<button class="btn btn-outline-secondary btn-sm rounded-pill" on:click={() => { error = ''; notice = ''; dialog.showModal(); }}>
  Reset state
</button>
{#if notice}<span class="small text-success" role="status">{notice}</span>{/if}

<dialog bind:this={dialog} aria-labelledby="reset-state-title" on:cancel={(event) => { if (busy) event.preventDefault(); }}>
  <h2 id="reset-state-title" class="h5">Reset dashboard state</h2>
  <p>Choose what to clear. This cannot be undone.</p>
  <fieldset disabled={busy}>
    <legend class="visually-hidden">State to reset</legend>
    {#each choices as choice}
      <label class="d-flex gap-2 mb-3">
        <input type="radio" name="reset-scope" value={choice.id} bind:group={scope} class="form-check-input flex-shrink-0" />
        <span><strong>{choice.title}</strong><span class="d-block small text-muted">{choice.detail}</span></span>
      </label>
    {/each}
  </fieldset>
  {#if error}<p class="text-danger" role="alert">{error}</p>{/if}
  <div class="d-flex justify-content-end gap-2">
    <button class="btn btn-secondary" disabled={busy} on:click={() => dialog.close()}>Cancel</button>
    <button class="btn btn-danger" disabled={busy} on:click={reset}>{busy ? 'Resetting…' : 'Confirm reset'}</button>
  </div>
</dialog>

<style>
  dialog { border: 0; border-radius: 0.5rem; padding: 1.5rem; max-width: 32rem; width: calc(100% - 2rem); }
  dialog::backdrop { background: rgb(0 0 0 / 50%); }
</style>
