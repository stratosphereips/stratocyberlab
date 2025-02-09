<script>
  import { onMount } from 'svelte';
  import { campaigns, loadSingleCampaign } from '../stores';
  import { chooseCampaignStep, chosenCampaignStep } from '../routing';
  import { derived } from 'svelte/store';

  export let id;

  let root;
  let campaign = derived([campaigns], ([campaigns]) => campaigns?.find((camp) => camp.id === id));

  const load = () => loadSingleCampaign(id).then();

  onMount(() => {
    const parentCollapse = root.parentElement.parentElement;

    // lazy-load on expand
    parentCollapse.addEventListener('shown.bs.collapse', load);

    // if already expanded (e.g. from localstorage)
    if (parentCollapse.classList.contains('show')) {
      load();
    }

    return () => parentCollapse.removeEventListener('shown.bs.collapse', load);
  });
</script>

<div bind:this={root}>
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
