<script>
  import ChallengeDetail from './ChallengeDetail.svelte';
  import ClassDetail from './ClassDetail.svelte';
  import Introduction from './Introduction.svelte';
  import SideNavBar from './SideNavBar.svelte';
  import { chosenChallenge, chosenClass, chosenCampaignDetail, chosenCampaignStep } from './routing';
  import CampaignStep from './campaigns/CampaignStep.svelte';
  import CampaignDetail from './campaigns/CampaignDetail.svelte';
</script>

<style>
</style>

<div class="d-flex">
  <div class="flex-grow-0">
    <SideNavBar />
  </div>
  <div class="ps-5 flex-grow-1">
    {#if $chosenChallenge}
      <ChallengeDetail challenge={$chosenChallenge} />
    {:else if $chosenClass}
      <ClassDetail curClass={$chosenClass} />
    {:else if $chosenCampaignDetail}
      <CampaignDetail campaign={$chosenCampaignDetail} />
    {:else if $chosenCampaignStep}
      <CampaignStep step={$chosenCampaignStep} />
    {:else}
      <Introduction />
    {/if}
  </div>
</div>
