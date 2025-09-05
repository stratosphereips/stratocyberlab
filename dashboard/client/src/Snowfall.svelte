<script>
  import { onMount } from "svelte";

  let snowflakes = [];
  const SNOWFLAKE_COUNT = 100;

  // Generate random snowflake properties
  function createSnowflake() {
    return {
      id: Math.random().toString(36).substring(7),
      x: Math.random() * 100, // Percentage
      y: -Math.random() * 100, // Start above view
      size: Math.random() * 50, // Size between 2 and 6 px
      speed: Math.random() * (0.3 - 0.1) + 0.1, // Falling speed
      swing: Math.random() * 10 + 2, // Horizontal movement
    };
  }

  // Initialize snowflakes
  onMount(() => {
    snowflakes = Array.from({ length: SNOWFLAKE_COUNT }, createSnowflake);
  });

  // Update snowflakes' position
  function updateSnowflakes() {
    snowflakes = snowflakes.map((flake) => {
      let newY = flake.y + flake.speed;
      let newX =
        flake.x + Math.sin((flake.y / 100) * Math.PI) * flake.swing * 0.01;
      let newSpeed = flake.speed

      if (newY > 100 || newX > 100) {
        newY = 0
        newX = Math.random() * 100
        newSpeed = Math.random() * (0.3 - 0.1) + 0.1
      }
      // if (newX > 100 ) {
      //
      // }

      return { ...flake, x: newX, y: newY, speed: newSpeed };
    });
  }

  // Animation loop
  let animationFrame;
  const loop = () => {
    updateSnowflakes();
    animationFrame = requestAnimationFrame(loop);
  };

  onMount(() => {
    loop();
    return () => cancelAnimationFrame(animationFrame);
  });
</script>

<style>
  .snowfall-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    pointer-events: none; /* Allows interactions with underlying UI */
    overflow: hidden;
    z-index: 9999; /* Ensure it overlays everything */
  }

  /*.snowflake {*/
  /*  !*width: 10px;*!*/
  /*  !*height: 10px;*!*/
  /*  background: none;*/
  /*  border: none;*/
  /*  position: absolute;*/
  /*  pointer-events: none;*/
  /*  color: #4cd5ff; !* Light blue color *!*/
  /*  !*font-size: 16px;*!*/
  /*  text-shadow: 0 0 5px rgba(173, 216, 230, 0.8);*/
  /*}*/
  .snowflake {
    position: absolute;
    color: #add8e6; /* Light blue color */
    text-shadow: 0 0 5px rgba(173, 216, 230, 0.8);
    pointer-events: none;
  }

  /*.snowflake::before {*/
  /*  content: "❄"; !* Unicode snowflake character *!*/
  /*  display: inline-block;*/
  /*}*/
</style>

<div class="snowfall-overlay">
  {#each snowflakes as { x, y, size }}
    <div
  class="snowflake"
  style="transform: translate({x}vw, {y}vh); font-size: {size}px;"
>
  ❄
</div>

<!--    <div-->
<!--      class="snowflake"-->
<!--      style="transform: translate({x}vw, {y}vh); width: {size}px; height: {size}px;"-->
<!--    ></div>-->
  {/each}
</div>
