<script>
  import Dashboard from './Dashboard.svelte';
  import AssistantLLM from './AssistantLLM.svelte';
  import LoadingOverlay from './LoadingOverlay.svelte';
  import SSH from './Ssh.svelte';
  import { onMount } from 'svelte';
  import ClassDoc from './ClassDoc.svelte';
  import Snowfall from './Snowfall.svelte';
  import { challenges, classes, campaigns } from './stores';
  import { chosenClass } from './routing';
  import { fetchChallenges, fetchClasses, fetchCampaigns } from './fetch';
  import TopNavBar from './TopNavBar.svelte';

  let showSSH = false;
  let sshInitialised = false;

  let sshHeight = 50;
  let isSshResizing = false;
  $: dashboardHeight = showSSH ? 100 - sshHeight : 100;

  // splitRatio variable in [0.3, 0.9] range
  let splitRatio = 0.6; // 66% left panel by default
  let isVerticalResizing = false;
  let splitWrap; // container ref to compute local positions

  onMount(async () => {
    fetchChallenges().then((loadedChallenges) => ($challenges = loadedChallenges));
    fetchClasses().then((loadedClasses) => ($classes = loadedClasses));
    fetchCampaigns().then((loadedCampaigns) => ($campaigns = loadedCampaigns));
  });

  let resizeTerminalContentFunc;

  const snowFlakesEasterEggFeatureFlag = false;

  onMount(() => {
    window.addEventListener('mousemove', resizeSSH);
    window.addEventListener('mouseup', stopSshResizing);

    window.addEventListener('mousemove', resizeVertical);
    window.addEventListener('mouseup', stopVerticalResizing);
  });

  function toggleShowSSH() {
    sshInitialised = true;
    showSSH = !showSSH;
  }

  function startSshResizing() {
    isSshResizing = true;
  }

  function stopSshResizing() {
    isSshResizing = false;
  }

  function resizeSSH(e) {
    if (!isSshResizing) {
      return;
    }
    const totalHeight = window.innerHeight;
    const newHeight = 100 - (e.clientY / totalHeight) * 100;
    if (newHeight >= 10 && newHeight <= 90) {
      sshHeight = newHeight;
      resizeTerminalContentFunc();
    }
  }

  function startVerticalResizing() {
    isVerticalResizing = true;
    document.body.classList.add('resizing-col');
  }
  function stopVerticalResizing() {
    if (!isVerticalResizing) return;
    isVerticalResizing = false;
    document.body.classList.remove('resizing-col');
  }
  function resizeVertical(e) {
    if (!isVerticalResizing || !splitWrap) return;
    const rect = splitWrap.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const ratio = x / rect.width;

    // clamp between 30% and (100% - handle guard). We don’t subtract the draggable handle,
    // because the handle is its own flex item and layout handles the remainder.
    splitRatio = Math.min(0.9, Math.max(0.3, ratio));
  }

  let isSnowFalling = snowFlakesEasterEggFeatureFlag;

  function toggleSnowfall() {
    isSnowFalling = !isSnowFalling;
  }
</script>
<style>
  .snowfall-toggle {
    font-size: 1rem;
    margin-right: 15px;
    background-color: transparent; /* Transparent background for cleaner look */
    cursor: pointer; /* Pointer cursor for interactivity */
    transition: all 0.3s ease; /* Smooth transition for hover effect */
  }

  .snowfall-toggle:hover {
    background-color: #f0f0f0; /* Light gray background */
    transform: scale(1.1); /* Slightly enlarge */
  }

  .custom-rounded-button {
    border-radius: 20px 20px 0 0;
  }

  /* Prevent accidental text selection and show col-resize globally while dragging */
  /* "Global" is a hack otherwise compiler does not include the class in final bundle as it thinks it's not used */
  :global(body.resizing-col) {
    cursor: col-resize;
    user-select: none;
  }

  /* Split layout */
  .split-wrap {
    display: flex;
    flex-wrap: nowrap; /* critical: never wrap */
    width: 100%;
    height: 100%;
    min-width: 0; /* allow shrinking inside */
    overflow: hidden; /* keep everything in viewport */
    box-sizing: border-box;
    gap: 0; /* no gaps so 3px handle is exact */
  }

  .split-left {
    flex: 0 0 var(--left);
    max-width: var(--left); /* ensure it never exceeds intended width */
    min-width: 0; /* content won’t force overflow */
  }

  .split-handle {
    flex: 0 0 3px;
    width: 3px;
    cursor: col-resize;
  }

  .split-right {
    flex: 1 1 auto; /* take the remaining width exactly */
    min-width: 0; /* allow content to shrink */
  }
</style>

<LoadingOverlay />
{#if snowFlakesEasterEggFeatureFlag && isSnowFalling}
  <Snowfall />
{/if}
<div class="container-fluid p-0 d-flex flex-column" style="height: {dashboardHeight}vh; overflow-y: auto;">
  <!-- Navbar -->
  <TopNavBar />
  <!--  TODO: migrate this to TopNavBar before enabling-->
  {#if snowFlakesEasterEggFeatureFlag}
    <div class="mr-3">
      <button class="btn snowfall-toggle" on:click={toggleSnowfall}> ☀️ </button>
    </div>
  {/if}

  <!-- Main dashboard content -->
  <div class="split-wrap flex-grow-1" bind:this={splitWrap} style="--left: {Math.round(splitRatio * 10000) / 100}%">
    <div class="split-left overflow-y-auto">
      <Dashboard />
    </div>
    <!-- eslint-disable-next-line svelte/valid-compile -->
    <div class="split-handle bg-dark-subtle" on:mousedown={startVerticalResizing}></div>
    <div class="split-right overflow-y-auto">
      {#if $chosenClass && $chosenClass.google_doc_url}
        <div class="p-0 w-100 h-100">
          <ClassDoc docUrl={$chosenClass.google_doc_url} />
        </div>
      {:else}
        <AssistantLLM />
      {/if}
    </div>
  </div>

  {#if !showSSH}
    <div class="position-fixed bottom-0 start-50 translate-middle-x" style="z-index: 1050;">
      <button class="h-50 btn btn-secondary custom-rounded-button shadow" on:click={toggleShowSSH}>
        {#if !sshInitialised}
          Open terminal in the lab ↑
        {:else}
          Reopen terminal ↑
        {/if}
      </button>
    </div>
  {/if}
</div>

<!-- Terminal -->
<!-- we use this if statement to lazy-initialise the component  -->
<!-- we use it just once in the beginning to keep alive the existing SSH connection  -->
{#if sshInitialised}
  <div class="row flex-grow-1 mx-0 bg-black {!showSSH ? 'visually-hidden' : ''}" style="height: {sshHeight}vh">
    <!-- eslint-disable-next-line svelte/valid-compile -->
    <div class="bg-secondary" on:mousedown={startSshResizing} style="height: 5px; cursor: row-resize;"></div>

    <div class="mx-1 col px-0" style="height: calc(100% - 5px)">
      <SSH bind:resize={resizeTerminalContentFunc} on:hide={toggleShowSSH} />
    </div>
  </div>
{/if}
