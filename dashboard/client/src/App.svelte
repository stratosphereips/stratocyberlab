<script>
  import { slide } from 'svelte/transition';
  import Challenges from "./Challenges.svelte";
  import AssistantLLM from "./AssistantLLM.svelte";
  import SSH from "./Ssh.svelte";

  let showSSH = false
  let sshInitialised = false

  function toggleShowSSH() {
    sshInitialised = true
    showSSH = !showSSH
  }



</script>

<style>
</style>


  <div class="container-fluid p-0 d-flex flex-column vh-100">

    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-light bg-light mb-2">
      <div class="container-fluid">
        <span class="navbar-brand" >
          <img src="/media/logo.png" alt="Logo" width="30" height="30" class="d-inline-block align-top">
          StratoCyberRange
        </span>
      </div>
    </nav>



  <div class="row flex-grow-1 m-1">

      <div class="col-8">
        <Challenges/>
      </div>
      <div class="col-4 border border-3 rounded border-dark">
        <AssistantLLM/>
      </div>

  </div>


  {#if !showSSH}
  <button class="rounded-pill btn btn-primary me-auto ms-auto" on:click="{toggleShowSSH}">
    {#if !sshInitialised}
    Connect to lab via SSH ↑
    {:else}
    Reopen SSH ↑
    {/if}
  </button>
  {/if}


  {#if sshInitialised}
  <!-- we use this if statement to lazy-initialise the component  -->
  <!-- we use it just once in the beginning to keep the existing SSH connection  -->

    <div class="row flex-grow-1 mx-0 {showSSH ? '' : 'visually-hidden'}">
    <div class="col px-0 bg-black text-white">
      <SSH on:hide={toggleShowSSH} />
    </div>
  </div>
  {/if}

</div>

