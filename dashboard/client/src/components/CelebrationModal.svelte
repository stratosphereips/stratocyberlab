<script>
  import { createEventDispatcher } from 'svelte';
  import Modal from './Modal.svelte';

  export let open = false;
  export let message = '';

  const dispatch = createEventDispatcher();

  const BALLOON_COUNT = 16;
  const CONFETTI_COUNT = 40;
  const COLORS = ['#e74c3c', '#f39c12', '#f1c40f', '#2ecc71', '#1abc9c', '#3498db', '#9b59b6', '#e84393'];

  function pickColor(index) {
    return COLORS[index % COLORS.length];
  }

  function createBalloons() {
    return Array.from({ length: BALLOON_COUNT }, (unused, index) => ({
      id: `balloon-${index}`,
      color: pickColor(index),
      left: Math.random() * 92 + 4, // percentage of the viewport width
      scale: Math.random() * 0.5 + 0.7,
      rise: Math.random() * 4 + 7, // seconds needed to fly across the screen
      sway: Math.random() * 2 + 2, // seconds of one left-right wobble
      delay: Math.random() * 4,
    }));
  }

  function createConfetti() {
    return Array.from({ length: CONFETTI_COUNT }, (unused, index) => ({
      id: `confetti-${index}`,
      color: pickColor(index + 3),
      left: Math.random() * 100,
      fall: Math.random() * 2 + 2.5,
      delay: Math.random() * 3,
      tilt: Math.random() * 360,
      round: index % 3 === 0,
    }));
  }

  let balloons = [];
  let confetti = [];
  let wasOpen = false;

  // Build the decorations once per opening so the animation restarts every time.
  $: if (open !== wasOpen) {
    wasOpen = open;
    balloons = open ? createBalloons() : [];
    confetti = open ? createConfetti() : [];
  }
</script>

<style>
  .celebration-layer {
    position: fixed;
    inset: 0;
    overflow: hidden;
    pointer-events: none; /* the modal underneath stays clickable */
    z-index: 1100; /* above the Bootstrap modal (1055) */
  }

  .balloon-track {
    position: absolute;
    bottom: -25vh;
    animation: balloon-rise linear infinite;
  }

  .balloon-sway {
    animation: balloon-sway ease-in-out infinite alternate;
  }

  .balloon {
    position: relative;
    width: 46px;
    height: 58px;
    border-radius: 50% 50% 48% 48%;
    background: radial-gradient(circle at 32% 28%, rgba(255, 255, 255, 0.75), var(--balloon-color) 58%);
    box-shadow: 0 6px 14px rgba(0, 0, 0, 0.18);
  }

  /* knot */
  .balloon::before {
    content: '';
    position: absolute;
    left: 50%;
    bottom: -5px;
    width: 8px;
    height: 8px;
    transform: translateX(-50%) rotate(45deg);
    background: var(--balloon-color);
    border-radius: 2px;
  }

  /* string */
  .balloon::after {
    content: '';
    position: absolute;
    left: 50%;
    top: 100%;
    width: 1px;
    height: 70px;
    margin-top: 6px;
    background: rgba(0, 0, 0, 0.25);
  }

  .confetti {
    position: absolute;
    top: -10vh;
    width: 8px;
    height: 12px;
    opacity: 0.9;
    animation: confetti-fall linear infinite;
  }

  .confetti.round {
    border-radius: 50%;
    height: 8px;
  }

  @keyframes balloon-rise {
    from {
      transform: translateY(0);
    }
    to {
      transform: translateY(-135vh);
    }
  }

  @keyframes balloon-sway {
    from {
      transform: translateX(-28px) rotate(-6deg);
    }
    to {
      transform: translateX(28px) rotate(6deg);
    }
  }

  @keyframes confetti-fall {
    from {
      transform: translateY(0) rotate(0deg);
    }
    to {
      transform: translateY(120vh) rotate(720deg);
    }
  }

  .celebration-body {
    padding: 0.5rem 0.5rem 0;
  }

  .celebration-emoji {
    font-size: 3.5rem;
    line-height: 1;
    animation: trophy-pop 1.4s ease-in-out infinite;
  }

  .celebration-title {
    background: linear-gradient(90deg, #f39c12, #e84393, #3498db);
    -webkit-background-clip: text;
    background-clip: text;
    color: transparent;
    font-weight: 700;
  }

  @keyframes trophy-pop {
    0%,
    100% {
      transform: scale(1) rotate(-4deg);
    }
    50% {
      transform: scale(1.12) rotate(4deg);
    }
  }

  /* Keep the celebration readable for users who do not want motion. */
  @media (prefers-reduced-motion: reduce) {
    .balloon-track,
    .balloon-sway,
    .confetti,
    .celebration-emoji {
      animation: none;
    }

    .balloon-track {
      bottom: auto;
      top: 10vh;
    }
  }
</style>

<Modal {open} title="" size="md" on:close>
  <div class="celebration-body text-center">
    <div class="celebration-emoji">🎉</div>
    <h3 class="celebration-title mt-3 mb-2">Congratulations!</h3>
    {#if message}
      <p class="mb-1">{message}</p>
    {/if}
    <p class="text-muted mb-0">Task solved. Keep going!</p>
  </div>
  <svelte:fragment slot="footer">
    <button type="button" class="btn btn-success w-auto" on:click={() => dispatch('close')}>Awesome!</button>
  </svelte:fragment>
</Modal>

{#if open}
  <div class="celebration-layer" aria-hidden="true">
    {#each balloons as balloon (balloon.id)}
      <div class="balloon-track" style="left: {balloon.left}%; animation-duration: {balloon.rise}s; animation-delay: {balloon.delay}s;">
        <div class="balloon-sway" style="animation-duration: {balloon.sway}s; animation-delay: {balloon.delay}s;">
          <div class="balloon" style="--balloon-color: {balloon.color}; transform: scale({balloon.scale});"></div>
        </div>
      </div>
    {/each}
    {#each confetti as piece (piece.id)}
      <div
        class="confetti {piece.round ? 'round' : ''}"
        style="left: {piece.left}%; background: {piece.color}; animation-duration: {piece.fall}s; animation-delay: {piece.delay}s; rotate: {piece.tilt}deg;"
      ></div>
    {/each}
  </div>
{/if}
