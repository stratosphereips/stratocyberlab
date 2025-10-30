<script>
  import {onMount, onDestroy} from 'svelte';
  import {isLoading} from './stores';

  export let curClass;

  export let initialWidth = 640;
  export let initialHeight = 360;
  export let minWidth = 320;
  export let minHeight = 180;

  // Playlist with all livestreams
  // https://www.youtube.com/playlist?list=PLQL6z4JeTTQmu09ItEQaqjt6tk0KnRsLh
  const liveStreamUrl = 'https://www.youtube.com/embed/ngZnsOGo6OY'

  const LECTURE_DURATION_MS = 200 * 60 * 1000; // 200 minutes
  const BUFFER_BEFORE_MS = 10 * 60 * 1000; // 10 minutes

  let parsedStartingTime = new Date(curClass.starting_time)
  parsedStartingTime = parsedStartingTime
          .toString()
          .replace("Central European Summer Time", "CEST")
          .replace("Central European Standard Time", "CET")

  let now = new Date();
  let timer;

  onMount(() => {
    // Tick every second for countdown/live window
    timer = setInterval(() => {
      now = new Date();
    }, 1000);
  });

  onDestroy(() => {
    clearInterval(timer);
  });

  // --- Time helpers (timezone aware because the ISO string includes the offset) ---
  $: start = curClass?.starting_time ? new Date(curClass.starting_time) : null;
  $: end = start ? new Date(start.getTime() + LECTURE_DURATION_MS) : null;

  $: bufferStart = start ? new Date(start.getTime() - BUFFER_BEFORE_MS) : null;
  $: bufferEnd = end ? new Date(end.getTime() + BUFFER_BEFORE_MS) : null;

  $: isInBufferOrLive = start && now >= bufferStart && now <= bufferEnd;
  $: isPast = bufferEnd && now > bufferEnd;
  $: classNotEnded = now < end

  function formatCountdown(ms) {
    // Clamp negative values to zero
    const total = Math.max(0, Math.floor(ms / 1000));
    const days = Math.floor(total / 86400);
    const hours = Math.floor((total % 86400) / 3600);
    const minutes = Math.floor((total % 3600) / 60);
    const seconds = total % 60;

    const dd = String(days).padStart(2, '0');
    const hh = String(hours).padStart(2, '0');
    const mm = String(minutes).padStart(2, '0');
    const ss = String(seconds).padStart(2, '0');
    return `${dd}:${hh}:${mm}:${ss}`;
  }

  $: countdownToStart = start ? formatCountdown(start.getTime() - now.getTime()) : null;

  async function flipActivity() {
    isLoading.set(true);
    try {
      let payload = {id: curClass.id};
      const action = curClass.running === true ? 'stop' : 'start';
      const res = await fetch(`/api/classes/${action}`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
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

{#if !start}
  <div class="alert alert-warning me-2" role="alert">
    The lecture start time is not configured.
  </div>
{:else}
  {#if isInBufferOrLive}
    <h6>Lecture Livestream</h6>
    <div class="resizable-frame" style="
      --w: {initialWidth}px;
      --h: {initialHeight}px;
      --min-w: {minWidth}px;
      --min-h: {minHeight}px;">
      <iframe
        src={liveStreamUrl}
        title="BSY class Live Stream"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        referrerpolicy="strict-origin-when-cross-origin"
        allowfullscreen
      ></iframe>
    </div>

  {:else if isPast && curClass.yt_recording_url}
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

  {:else if isPast && !curClass.yt_recording_url}
    <div class="alert alert-info me-2" role="alert">
      The lecture has already finished. Please check back later for the recording.
    </div>

  {:else}
    <div class="alert alert-info d-flex align-items-center me-2" role="alert">
    <i class="bi bi-clock me-2"></i>
    <div>
      <div class="fw-semibold">Starts at {parsedStartingTime}</div>
      <div class="small text-muted">
        The livestream will appear here once we go live.
      </div>
    </div>
    <div class="ms-auto text-nowrap fs-5 fw-bold" aria-live="polite" aria-atomic="true">
      {countdownToStart}
    </div>
  </div>
  {/if}
{/if}

{#if classNotEnded}
  <div class="alert alert-warning text-muted me-2" role="alert">
    <div class="fw-semibold mb-1">Before the class starts:</div>
    <ul class="mb-0">
      <li>Update SCL to have the latest version including built-in study materials.</li>
      {#if curClass.dir}
      <li>Start the class environment. Starting for the first time may take some time.</li>
      {/if}
    </ul>
  </div>
{/if}

<div class="pt-3 mb-3">
  <div>
  <h5>Description</h5>
  <!-- eslint-disable-next-line svelte/no-at-html-tags -->
  {@html curClass.description}
  </div>
</div>

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
        <span>The class environment is up and running!</span>
      {:else}
        <span>The class environment is not running</span>
      {/if}
    </div>

    <button class="btn {!curClass.running ? 'btn-primary' : 'btn-secondary'} ms-auto" on:click={flipActivity}>
      {curClass.running ? 'Stop' : 'Start'}
    </button>
  </div>
{/if}
