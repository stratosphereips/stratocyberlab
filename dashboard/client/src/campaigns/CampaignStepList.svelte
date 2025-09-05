<script>
  import { onMount } from 'svelte';
  import { campaigns, loadSingleCampaign } from '../stores';
  import { chooseCampaignStep, chosenCampaignStep } from '../routing';
  import { derived } from 'svelte/store';

  export let id;

  let campaign = derived([campaigns], ([campaigns]) => campaigns?.find((camp) => camp.id === id));

  const load = () => loadSingleCampaign(id).then();

  onMount(load);
</script>

<div>
  {#if $campaign && $campaign.steps}
    {#each $campaign.steps as step}
      <li class="mb-1">
        <button
          on:click={() => chooseCampaignStep($campaign.id, step.id)}
          type="button"
          class="list-group-item list-group-item-action d-flex justify-content-between {$chosenCampaignStep?.campaignId ===
            $campaign.id && $chosenCampaignStep?.id === step.id
            ? 'fw-bold'
            : ''}"
        >
          {step.name}
        </button>
      </li>
    {/each}
  {:else}Loading...{/if}
</div>
