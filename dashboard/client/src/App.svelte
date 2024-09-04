<script>
  import Dashboard from "./Dashboard.svelte";
  import AssistantLLM from "./AssistantLLM.svelte";
  import LoadingOverlay from './LoadingOverlay.svelte';
  import SSH from "./Ssh.svelte";
  import {onMount} from "svelte";

  let showSSH = false
  let sshInitialised = false

  let sshHeight = 50
  let isSshResizing = false;
  $: dashboardHeight = showSSH ? 100 - sshHeight : 100

  let chosenChallenge;
  let chosenClass;

  let resizeTerminalContentFunc;

  onMount(() => {
    window.addEventListener("mousemove", resizeSSH);
    window.addEventListener("mouseup", stopSshResizing);
  });

  function toggleShowSSH() {
    sshInitialised = true
    showSSH = !showSSH
  }

  function handleBrandClick() {
    chosenChallenge = undefined
    chosenClass = undefined
  }

  function startSshResizing() {
    isSshResizing = true
  }

  function stopSshResizing() {
    isSshResizing = false
  }

  function resizeSSH(e) {
    if (!isSshResizing) {
      return
    }
    const totalHeight = window.innerHeight;
    const newHeight = 100 - ((e.clientY / totalHeight) * 100);
    if (newHeight >= 10 && newHeight <= 90) {
      sshHeight = newHeight;
      resizeTerminalContentFunc()
    }
  }


</script>
<style>
  .custom-rounded-button {
    border-radius: 20px 20px 0 0;
  }
</style>

<LoadingOverlay/>
<div class="container-fluid p-0 d-flex flex-column" style="height: {dashboardHeight}vh; overflow-y: auto;">
  <!-- Navbar -->
  <nav class="navbar navbar-expand-lg navbar-light bg-light mb-2">
    <div class="container-fluid">
      <a href="#" class="navbar-brand ms-2" on:click|preventDefault="{handleBrandClick}">
        <img src="/media/logo.png" alt="Logo" width="30" height="30" class="d-inline-block align-top">
        StratoCyberLab
      </a>
    </div>
  </nav>

  <!-- Main dashboard content -->
  <div class="row flex-grow-1 m-1">
      <div class="col-8">
        <Dashboard bind:chosenChallenge={chosenChallenge} bind:chosenClass={chosenClass} />
      </div>
      <div class="col-4 {showSSH ? '' : 'h-75'}">
        <AssistantLLM/>
      </div>
  </div>

  <!-- Bottom button to open/close terminal -->
  {#if !showSSH}
  <button class="btn btn-secondary me-auto ms-auto custom-rounded-button" on:click="{toggleShowSSH}">
    {#if !sshInitialised}
    Open terminal in the lab ↑
    {:else}
    Reopen terminal ↑
    {/if}
  </button>
  {/if}
</div>

<!-- Terminal -->
<!-- we use this if statement to lazy-initialise the component  -->
<!-- we use it just once in the beginning to keep alive the existing SSH connection  -->
{#if sshInitialised}
<div class="row flex-grow-1 mx-0 bg-black {!showSSH ? 'visually-hidden' : ''}" style="height: {sshHeight}vh">
  <div class="bg-secondary" on:mousedown={startSshResizing} style="height: 5px; cursor: row-resize;"></div>

  <div class="mx-1 col px-0" style="height: calc(100% - 5px)">
    <SSH bind:resize={resizeTerminalContentFunc} on:hide={toggleShowSSH} />
  </div>
</div>
{/if}
