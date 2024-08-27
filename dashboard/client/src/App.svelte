<script>
  import Dashboard from "./Dashboard.svelte";
  import AssistantLLM from "./AssistantLLM.svelte";
  import LoadingOverlay from './LoadingOverlay.svelte';
  import SSH from "./Ssh.svelte";

  let showSSH = false
  let sshInitialised = false

  let chosenChallenge;
  let chosenClass;

  function toggleShowSSH() {
    sshInitialised = true
    showSSH = !showSSH
  }

  function handleBrandClick() {
    chosenChallenge = undefined
    chosenClass = undefined
  }

</script>
<style>
  .custom-rounded-button {
    border-radius: 20px 20px 0 0;
  }
</style>

  <LoadingOverlay />
  <div class="container-fluid p-0 d-flex flex-column vh-100">

    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-light bg-light mb-2">
      <div class="container-fluid">
        <a href="#" class="navbar-brand ms-2" on:click|preventDefault="{handleBrandClick}">
          <img src="/media/logo.png" alt="Logo" width="30" height="30" class="d-inline-block align-top">
          StratoCyberLab
        </a>
      </div>
    </nav>



  <div class="row flex-grow-1 {showSSH ? 'vh-100' : ''}  m-1">

      <div class="col-8">
        <Dashboard bind:chosenChallenge={chosenChallenge} bind:chosenClass={chosenClass} />
      </div>
      <div class="col-4 {showSSH ? '' : 'h-75'}">
        <AssistantLLM/>
      </div>

  </div>


  {#if !showSSH}
  <button class="btn btn-secondary me-auto ms-auto custom-rounded-button" on:click="{toggleShowSSH}">    {#if !sshInitialised}
    Open terminal in the lab ↑
    {:else}
    Reopen terminal ↑
    {/if}
  </button>
  {/if}


  {#if sshInitialised}
  <!-- we use this if statement to lazy-initialise the component  -->
  <!-- we use it just once in the beginning to keep the existing SSH connection  -->

    <div class="row flex-grow-1 mx-0 bg-black {showSSH ? 'vh-100' : 'visually-hidden'}">
    <div class="col px-0">
      <SSH on:hide={toggleShowSSH} />
    </div>
  </div>
  {/if}

</div>

