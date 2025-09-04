<script>
  import { onMount } from 'svelte';
  import Modal from './Modal.svelte';
  import { fetchGitHubMainCommit, fetchLocalCommit } from '../fetch';

  let localCommit = '';
  let githubCommit = '';
  let loading = true;
  let show = false;

  const normalize = (v) =>
    (v === undefined || v === null || v === 'null') ? null : String(v).trim();

  async function load() {
    loading = true;
    try {
      const [local, remote] = await Promise.allSettled([
        fetchLocalCommit(),
        fetchGitHubMainCommit()
      ]);
      localCommit  = local.status  === 'fulfilled' ? local.value : null;
      githubCommit = remote.status === 'fulfilled' ? remote.value : null;
    } finally {
      loading = false;
    }
  }

  onMount(load);

  $: normalizedLocal  = normalize(localCommit);
  $: normalizedRemote = normalize(githubCommit);

  $: state =
    loading ? 'loading'
    : normalizedRemote === null ? 'unknown'
    : (normalizedLocal && normalizedRemote && normalizedLocal === normalizedRemote) ? 'ok'
    : 'outdated';

  $: label =
    state === 'loading'   ? 'Checking…'
    : state === 'ok'      ? 'Up to date'
    : state === 'outdated'? 'Update available'
    :                       'Unknown';

  $: pillClasses =
    state === 'ok'
      ? 'text-success-emphasis bg-success-subtle border border-success-subtle'
      : state === 'outdated'
      ? 'text-danger-emphasis bg-danger-subtle border border-danger-subtle'
      : state === 'unknown'
      ? 'text-secondary-emphasis bg-secondary-subtle border border-secondary-subtle'
      : 'text-body bg-body-tertiary border';

  function openDetails() { if (state !== 'loading') show = true; }
</script>

<!-- Navbar pill (ms-auto pushes right) -->
<div
  class={"ms-auto d-inline-flex align-items-center gap-2 px-2 py-1 rounded-pill small shadow-sm " + pillClasses}
  role="button"
  tabindex="0"
  title="Click for details"
  aria-label={"Project version status — " + label}
  style="cursor: pointer;"
  on:click={openDetails}
  on:keyup={(e) => (e.key === 'Enter' || e.key === ' ') && openDetails()}
>
  <span class="d-inline-flex">
    {#if state === 'loading'}
      <div class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></div>
    {:else if state === 'ok'}
      <i class="bi bi-check-circle-fill"></i>
    {:else if state === 'outdated'}
      <i class="bi bi-exclamation-triangle-fill"></i>
    {:else}
      <i class="bi bi-question-circle-fill"></i>
    {/if}
  </span>
  <div class="d-flex flex-column">
    <span class="fw-semibold">{label}</span>
<!--    <span class="text-muted">{hint}</span>-->
  </div>
</div>

<!-- Modal (use default 'md' width to avoid cramped content) -->
<Modal bind:open={show} title="StratoCyberLab version details" size="md" on:close={() => (show = false)}>
  <div class="d-grid gap-3">
    {#if state === 'ok'}
      <div class="text-success fw-semibold">✅ Your project is up to date with Github upstream.</div>
    {:else if state === 'outdated'}
      <div class="text-warning-emphasis fw-semibold">⚠️ Your version differs from Github main branch.</div>
      <div>Pull the latest changes to update.</div>
    {:else if state === 'unknown'}
      <div class="text-secondary fw-semibold">🤔 Couldn’t compare version with Github.</div>
      <div>Please check your internet connection and try again.</div>
    {:else}
      <div>Checking versions…</div>
    {/if}

    <!-- Commit hashes (label never shrinks; hash wraps inside remaining width) -->
    <div class="border rounded-3 p-3 bg-body-tertiary">
      <div class="d-flex align-items-center gap-2 mb-2">
        <span class="text-muted small">Local commit</span>
        <code class="flex-fill d-inline-block px-2 py-1 bg-body rounded border font-monospace">
          {normalizedLocal?.slice(0, 10) ?? '—'}
        </code>
      </div>
      <div class="d-flex align-items-center gap-2">
        <span class="text-muted d-inline-block small">Github commit</span>
        <code class="flex-fill d-inline-block px-2 py-1 bg-body rounded border font-monospace">
          {normalizedRemote?.slice(0, 10) ?? '—'}
        </code>
      </div>
    </div>

    <!-- How to update -->
    {#if state === 'outdated'}
    <div class="small">
      <p class="mb-2 fw-semibold">How to update</p>
      <ol class="ps-3 mb-2">
        <li>Stop the StratoCyberLab</li>
        <li>Run <code class="font-monospace">git pull</code> in the project directory.</li>
        <li>Start the project again.</li>
      </ol>
    </div>
    {/if}
  </div>

  <svelte:fragment slot="footer">
    <button type="button" class="btn btn-outline-secondary w-auto" on:click={() => (show = false)}>
      Close
    </button>
  </svelte:fragment>
</Modal>

<style>
  /* Optional: subtle hover affordance for the pill */
  .rounded-pill:hover { box-shadow: 0 .5rem 1rem rgba(0,0,0,.05) !important; }
</style>
