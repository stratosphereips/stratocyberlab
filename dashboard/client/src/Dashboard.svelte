<script>
    import ChallengeDetail from "./ChallengeDetail.svelte";
    import ClassDetail from "./ClassDetail.svelte";
    import Introduction from "./Introduction.svelte";
    import SideNavBar from "./SideNavBar.svelte";

    export let chosenChallenge;
    export let chosenClass;

</script>

<style>
</style>

<div class="d-flex">
    <div class="flex-grow-0">
    <SideNavBar class="mb2" bind:chosenChallenge={chosenChallenge} bind:chosenClass={chosenClass}/>
      </div>
        <div class="ps-5 flex-grow-1">
          {#if chosenChallenge !== undefined}
              <ChallengeDetail bind:challenge="{chosenChallenge}"/>
          {:else if chosenClass !== undefined}
              <ClassDetail bind:curClass="{chosenClass}"/>
          {:else}
              <Introduction/>
          {/if}
      </div>
</div>