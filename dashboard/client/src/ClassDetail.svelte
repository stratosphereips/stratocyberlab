<script>
  import { isLoading } from './stores';

  export let curClass;

  export let initialWidth = 640;
  export let initialHeight = 360;
  export let minWidth = 320;
  export let minHeight = 180;

  async function flipActivity() {
    isLoading.set(true);
    try {
      let payload = { id: curClass.id };
      const action = curClass.running === true ? 'stop' : 'start';
      const res = await fetch(`/api/classes/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      if (res.status !== 200) {
        throw new Error(`Error: request failed with HTTP status ${res.status}: ${await res.text()}`);
      }
      curClass.running = action === 'start';
    } catch (err) {
      console.error(err);
      alert(err instanceof Error ? err.message : err);
    }
    isLoading.set(false);
  }

  function isClassLiveNow() {
    // Class happens every Thursday from 14:30 CEST until end of January 2025 (kept as in your snippet)
    const now = new Date();
    const february2026 = new Date('2026-02-01T00:00:00Z');
    if (now > february2026) return false;

    const currentDay = now.getDay();
    const currentTimeUTC = now.getUTCHours();
    const isThursday = currentDay === 4;
    const isWithinTimeRange = currentTimeUTC >= 12 && currentTimeUTC < 17;
    return isThursday && isWithinTimeRange;
  }
</script>

<style>
  .slow-spinner {
    animation-duration: 1.5s;
  }

  /* NEW: resizable wrapper around the iframe */
  .resizable-frame {
    /* initial size via CSS vars (set inline below) */
    width: var(--w, 640px);
    height: var(--h, 360px);

    /* don't exceed parent */
    max-width: 100%;

    /* limits so it can't collapse too small */
    min-width: var(--min-w, 320px);
    min-height: var(--min-h, 180px);

    /* enable user resizing */
    resize: both;
    overflow: auto; /* required for resize to show up */

    /* nice look in Bootstrap contexts */
    border: 1px solid rgba(0, 0, 0, 0.125);
    border-radius: 0.5rem; /* ~rounded-3 */
    background: #000; /* avoids white flash around video during resize */
  }

  .resizable-frame iframe {
    width: 100%;
    height: 100%;
    border: 0;
    display: block; /* avoid stray gaps */
  }
</style>

<div class="mb-3 d-flex justify-content-between align-items-center">
  <div>
    <h4 class="d-inline">{curClass.name}</h4>
  </div>
</div>

{#if curClass.yt_recording_url}
  <h6>Lecture Recording</h6>
  <div class="resizable-frame" style="
    --w: {initialWidth}px;
    --h: {initialHeight}px;
    --min-w: {minWidth}px;
    --min-h: {minHeight}px;">
    <iframe
      src={curClass.yt_recording_url}
      title="Recording of BSY class lecture"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      referrerpolicy="strict-origin-when-cross-origin"
      allowfullscreen
    ></iframe>
  </div>
{:else if isClassLiveNow()}
  <h6>Lecture Livestream</h6>
  <div class="resizable-frame" style="
      --w: {initialWidth}px;
      --h: {initialHeight}px;
      --min-w: {minWidth}px;
      --min-h: {minHeight}px;">
    <iframe
      src="https://www.youtube.com/embed/HShkFvjHPjw?si=SD9QTP6_i-VSC7rf"
      title="BSY class Live Stream"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      referrerpolicy="strict-origin-when-cross-origin"
      allowfullscreen
    ></iframe>
  </div>
{/if}


<p class="pt-3 text-muted">
  <!-- eslint-disable-next-line svelte/no-at-html-tags -->
  {@html curClass.description}
</p>

{#if curClass.dir}
  <div
    class="alert me-2 d-flex justify-content-between align-items-center {curClass.running
      ? 'alert-success'
      : 'alert-light'}"
    role="alert"
  >
    <div class="d-flex align-items-center">
      {#if curClass.running}
        <div class="spinner-grow text-success me-2 slow-spinner" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
        <span>The class is up and running!</span>
      {:else}
        <span>The class is not running</span>
      {/if}
    </div>

    <button class="btn {!curClass.running ? 'btn-primary' : 'btn-secondary'} ms-auto" on:click={flipActivity}>
      {curClass.running ? 'Stop' : 'Start'}
    </button>
  </div>
{/if}
