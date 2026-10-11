<script>
  import { onDestroy, onMount, tick } from 'svelte';
  import { CalendarDays, Clock, LockClosed, PlayCircle } from 'svelte-heros';
  import { classes } from './stores';

  const LECTURE_DURATION_MS = 200 * 60 * 1000; // same lecture window as ClassDetail

  const STATES = {
    live: { label: 'Happening now', icon: PlayCircle, tone: 'primary' },
    held: { label: 'Class finished', icon: CalendarDays, tone: 'secondary' },
    upcoming: { label: 'Upcoming', icon: Clock, tone: 'secondary' },
    locked: { label: 'Locked', icon: LockClosed, tone: 'secondary' },
  };
  const TEXT_TONE = {
    primary: 'text-primary',
    secondary: 'text-secondary',
  };

  let now = Date.now();
  let timer;
  let strip;

  onMount(() => {
    timer = setInterval(() => (now = Date.now()), 30 * 1000);
  });

  onDestroy(() => clearInterval(timer));

  function splitName(name) {
    const match = name.match(/^(\S+)\s+-\s+(.+)$/);
    return match ? { code: match[1], title: match[2] } : { code: '', title: name };
  }

  // Descriptions are trusted repository HTML, but cards show only a short plain-text preview.
  // DOMParser builds an inert document: nothing in it runs or loads.
  function plainText(html) {
    const spaced = (html ?? '').replace(/<(br|\/?(p|li|ul|ol|div))\b[^>]*>/gi, ' ');
    const text = new DOMParser().parseFromString(spaced, 'text/html').body.textContent ?? '';
    return text.replace(/\s+/g, ' ').trim();
  }

  // Descriptions often continue with lab setup steps; the first sentence is the summary.
  function firstSentence(text) {
    return text.match(/^.+?[.!?](?=\s|$)/)?.[0] ?? text;
  }

  const startOf = (cls) => Date.parse(cls.starting_time);
  const formatDate = (cls, options) =>
    Number.isFinite(startOf(cls)) ? new Date(startOf(cls)).toLocaleDateString(undefined, options) : 'TBA';

  function stateOf(cls, time) {
    if (cls.locked) return 'locked';
    const start = startOf(cls);
    if (!Number.isFinite(start) || time < start) return 'upcoming';
    if (time <= start + LECTURE_DURATION_MS) return 'live';
    return 'held';
  }

  $: sorted = ($classes ?? [])
    .slice()
    .sort((a, b) => (startOf(a) || Infinity) - (startOf(b) || Infinity))
    .map((cls) => ({ ...cls, ...splitName(cls.name), preview: firstSentence(plainText(cls.description)) }));
  $: states = Object.fromEntries(sorted.map((cls) => [cls.id, stateOf(cls, now)]));
  $: total = sorted.length;
  $: currentIndex = (() => {
    const index = sorted.findIndex((cls) => !(now > startOf(cls) + LECTURE_DURATION_MS));
    return index === -1 ? total - 1 : index;
  })();
  $: current = sorted[currentIndex];
  $: held = sorted.filter((cls) => now > startOf(cls) + LECTURE_DURATION_MS).length;
  $: allHeld = total > 0 && held === total;

  // Keep the current class visible in the horizontally scrolling roadmap.
  $: centerChip(strip, currentIndex);
  async function centerChip(container, index) {
    if (!container) return;
    await tick();
    const chip = container.children[index];
    if (chip)
      container.scrollLeft = chip.offsetLeft - container.offsetLeft - (container.clientWidth - chip.clientWidth) / 2;
  }
</script>

<style>
  .eyebrow {
    font-size: 0.75rem;
    letter-spacing: 0.06em;
    text-transform: uppercase;
  }

  .roadmap-strip {
    display: flex;
    gap: 0.5rem;
    overflow-x: auto;
    padding: 0.25rem 0.125rem 0.5rem;
    scrollbar-width: thin;
  }

  .chip {
    flex: 0 0 auto;
    min-width: 5.25rem;
    padding: 0.45rem 0.6rem;
    border: 1px solid var(--bs-border-color);
    border-radius: 0.5rem;
    background: var(--bs-body-bg);
    color: inherit;
    font-size: 0.8rem;
    line-height: 1.3;
    text-align: center;
    text-decoration: none;
  }

  a.chip:hover {
    border-color: var(--bs-primary-border-subtle);
  }

  .chip.held {
    background: var(--bs-tertiary-bg);
  }

  .chip.locked {
    color: var(--bs-secondary-color);
  }

  .chip.current {
    border-color: var(--bs-primary);
    box-shadow: 0 0 0 2px rgba(var(--bs-primary-rgb), 0.2);
  }

  .dot {
    display: block;
    width: 0.5rem;
    height: 0.5rem;
    margin: 0 auto 0.25rem;
    border-radius: 50%;
  }

  .class-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
    gap: 1rem;
  }

  .class-card {
    overflow: hidden;
    color: inherit;
    text-decoration: none;
    transition:
      transform 0.15s ease,
      box-shadow 0.15s ease;
  }

  a.class-card:hover,
  a.class-card:focus-visible {
    transform: translateY(-2px);
    box-shadow: var(--bs-box-shadow);
  }

  .cover {
    position: relative;
    aspect-ratio: 16 / 9;
    overflow: hidden;
    background: linear-gradient(135deg, #1f2a44, #3d5f93);
  }

  .cover img {
    display: block;
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .class-card.locked .cover img {
    filter: blur(6px) grayscale(0.5);
    transform: scale(1.1);
  }

  .class-card.locked .card-body {
    opacity: 0.6;
  }

  .lock-overlay {
    position: absolute;
    inset: 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 0.25rem;
    background: rgb(0 0 0 / 35%);
    color: #fff;
    font-weight: 600;
  }

  .description {
    display: -webkit-box;
    overflow: hidden;
    -webkit-line-clamp: 4;
    line-clamp: 4;
    -webkit-box-orient: vertical;
  }
</style>

<div class="pe-4 pb-5">
  <h3 class="mb-3">Classes</h3>

  {#if !$classes}
    <div class="d-flex justify-content-center py-5">
      <div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div>
    </div>
  {:else if total === 0}
    <div class="alert alert-info">No classes are available yet.</div>
  {:else}
    <!-- Roadmap -->
    <section class="card shadow-sm mb-4" aria-labelledby="roadmap-title">
      <div class="card-body">
        <div class="eyebrow text-secondary">Journey roadmap</div>
        <h2 id="roadmap-title" class="h6 fw-semibold mb-3">
          {#if allHeld}
            All {total} classes held
          {:else}
            Class {currentIndex + 1} of {total} · {current.title}
          {/if}
        </h2>

        <div class="d-flex justify-content-between eyebrow text-secondary mb-1">
          <span>{held} of {total} classes held</span>
          <span>{total - held} more to go</span>
        </div>
        <div
          class="progress mb-3"
          style="height: 6px"
          role="progressbar"
          aria-label="Classes held"
          aria-valuemin="0"
          aria-valuemax={total}
          aria-valuenow={held}
        >
          <div class="progress-bar bg-primary" style="width: {(held / total) * 100}%"></div>
        </div>

        <div class="roadmap-strip" bind:this={strip}>
          {#each sorted as cls, i (cls.id)}
            <svelte:element
              this={cls.locked ? 'div' : 'a'}
              href={cls.locked ? undefined : `#class/${cls.id}`}
              class="chip {states[cls.id]}"
              class:current={i === currentIndex}
              aria-current={i === currentIndex ? 'step' : undefined}
              title="{cls.name} · {STATES[states[cls.id]].label}"
            >
              <span class="dot bg-{STATES[states[cls.id]].tone}" class:opacity-25={states[cls.id] === 'locked'}></span>
              <span class="d-block fw-semibold">{cls.code || `Class ${i + 1}`}</span>
              <span class="d-block text-secondary">{formatDate(cls, { month: 'short', day: 'numeric' })}</span>
            </svelte:element>
          {/each}
        </div>
      </div>
    </section>

    <!-- Class cards -->
    <h4 class="h5 mb-3">Your classes</h4>
    <div class="class-grid">
      {#each sorted as cls (cls.id)}
        {@const state = STATES[states[cls.id]]}
        <svelte:element
          this={cls.locked ? 'div' : 'a'}
          href={cls.locked ? undefined : `#class/${cls.id}`}
          class="card class-card shadow-sm"
          class:locked={cls.locked}
          aria-label={cls.locked ? undefined : `Open ${cls.name}`}
        >
          <div class="cover">
            {#if cls.has_cover}
              <img src="/api/classes/{encodeURIComponent(cls.id)}/cover" alt="" loading="lazy" />
            {/if}
            {#if cls.locked}
              <div class="lock-overlay">
                <LockClosed width="20" height="20" aria-hidden="true" />
                <span>Locked</span>
              </div>
            {/if}
          </div>
          <div class="card-body d-flex flex-column">
            <div class="d-flex justify-content-between align-items-center mb-2">
              {#if cls.code}
                <span class="badge rounded-pill {cls.locked ? 'text-bg-secondary' : 'text-bg-primary'}">
                  {cls.code}
                </span>
              {/if}
              <span class="small text-secondary ms-auto">
                {formatDate(cls, { year: 'numeric', month: 'short', day: 'numeric' })}
              </span>
            </div>
            <h5 class="h6 fw-semibold mb-2">{cls.title}</h5>
            <p class="description small text-secondary mb-3">{cls.preview}</p>
            <div class="mt-auto small d-flex align-items-center gap-1 {TEXT_TONE[state.tone]}">
              <svelte:component this={state.icon} width="16" height="16" aria-hidden="true" />
              <span>{state.label}</span>
            </div>
          </div>
        </svelte:element>
      {/each}
    </div>
  {/if}
</div>
