<script>
  // removed slide import to kill animations
  import CollapsibleSection from './components/CollapsibleSection.svelte';
  import { challenges, classes, campaigns } from './stores';
  import {
    chooseChallenge,
    chooseClass,
    chosenClass,
    chosenChallenge,
    chooseCampaignDetail
  } from './routing';
  import CampaignStepList from './campaigns/CampaignStepList.svelte';

  // Heroicons (outline)
  import {
    AcademicCap,       // Classes
    PuzzlePiece,       // Challenges
    Flag,              // Campaigns
    ChevronLeft,       // Collapse
    ChevronRight,      // Expand
    InformationCircle  // "Details" badge
  } from 'svelte-heros';

  let visible = true;

  function difficulty_background(d) {
    return d === 'easy' ? 'bg-success'
         : d === 'medium' ? 'bg-warning'
         : 'bg-danger';
  }
</script>

<style>
  .sidebar {
    width: 300px;
    min-width: 300px;
    /*min-height: 100vh;*/
    position: sticky;
    top: 0;
    left: 0;
    z-index: 1020;
  }

  /* perfectly center icons inside square buttons */
  .icon-btn {
    width: 36px;
    height: 36px;
    padding: 0;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    line-height: 1;
  }

  /* small handle that sits on the edge to collapse */
  .collapse-handle {
    position: absolute;
    right: -14px; /* slight peek outside the edge */
    top: 56px;
    border-top-left-radius: .75rem;
    border-bottom-left-radius: .75rem;
  }

  /* when collapsed, a little "peek" button stays on the far left */
  .peek {
    position: fixed;
    left: 0;
    top: 72px;
    z-index: 1021;
    border-top-right-radius: 999px;
    border-bottom-right-radius: 999px;
  }
</style>

<!-- keep first in layout so there’s no gap on the left; no transition => instant toggle -->
<div class="d-flex gap-0 h-100">
  {#if visible}
    <aside class="sidebar bg-light border-end border-1 rounded-0 shadow-sm d-flex flex-column h-100 flex-grow-1">
      <div class="p-3">
        <!-- collapse handle (icon centered) -->
        <button
          type="button"
          class="btn btn-light border shadow-sm icon-btn collapse-handle"
          on:click={() => (visible = false)}
          aria-label="Collapse sidebar"
          title="Hide sidebar"
        >
          <ChevronLeft width="18" height="18" />
        </button>

        {#if !($challenges && $classes)}
          <div class="d-flex align-items-center justify-content-center py-5">
            <div class="spinner-border" role="status">
              <span class="visually-hidden">Loading...</span>
            </div>
          </div>
        {:else}
          <ul class="list-unstyled m-0">
            <!-- Classes -->
            <CollapsibleSection title="Click to expand classes list" id="classesList" label="Classes" icon={AcademicCap}>
              {#each $classes as c}
                <li class="mb-1">
                  <button
                    on:click={() => chooseClass(c.id)}
                    type="button"
                    class="list-group-item list-group-item-action d-flex justify-content-between align-items-center border-0 rounded-2 {($chosenClass === c) ? 'fw-bold' : ''}"
                  >
                    <span title={c.name} class="text-truncate">{c.name}</span>
                  </button>
                </li>
              {/each}
            </CollapsibleSection>

            <!-- Challenges -->
            <CollapsibleSection title="Click to expand challenges list" id="challengeList" label="Challenges" icon={PuzzlePiece}>
              {#each $challenges as ch}
                <li class="mb-1">
                  <button
                    on:click={() => chooseChallenge(ch.id)}
                    type="button"
                    class="list-group-item list-group-item-action d-flex justify-content-between align-items-center border-0 rounded-2 {($chosenChallenge === ch) ? 'fw-bold' : ''}"
                  >
                    <span class="text-truncate">{ch.name}</span>
                    <span class="badge {difficulty_background(ch.difficulty)} rounded-pill text-capitalize">
                      {ch.difficulty}
                    </span>
                  </button>
                </li>
              {/each}
            </CollapsibleSection>

            <!-- Campaigns -->
            {#if $campaigns}
              <CollapsibleSection title="Click to expand campaigns list" id="campaignList" label="Campaigns" icon={Flag}>
                {#each $campaigns as campaign}
                  <CollapsibleSection title="Click to expand campaign' list of missions" id={campaign.id} label={campaign.name} level={2}>
                    <span slot="labelExtra">
                      <button
                        class="btn btn-sm btn-outline-secondary rounded-5 d-inline-flex align-items-center"
                        on:click|stopPropagation={() => chooseCampaignDetail(campaign.id)}
                        title="Show campaign details"
                      >
                        <InformationCircle width="16" height="16" class="me-1" />
                      </button>
                    </span>
                    <CampaignStepList id={campaign.id} />
                  </CollapsibleSection>
                {/each}
              </CollapsibleSection>
            {/if}
          </ul>
        {/if}
      </div>
    </aside>
  {:else}
    <button
      class="peek btn btn-light border shadow-sm icon-btn"
      on:click={() => (visible = true)}
      aria-label="Expand sidebar"
      title="Show sidebar"
      type="button"
    >
      <ChevronRight width="20" height="20" />
    </button>
  {/if}
</div>
