<script>
  import { slide } from 'svelte/transition';
  import CollapsibleSection from './components/CollapsibleSection.svelte';
  import { challenges, classes } from './stores';
  import { chooseChallenge, chooseClass, chosenClass, chosenChallenge } from './routing';

  let visible = true;

  function difficulty_background(d) {
    return d === 'easy' ? 'bg-success' : d === 'medium' ? 'bg-warning' : 'bg-danger';
  }
</script>

<style>
  .sidebar {
    width: 300px;
    position: relative;
    background-color: #f8f9fa;
    border-radius: 8px;
    padding: 1rem;
  }
  .close-btn {
    position: absolute;
    top: 10px;
    right: 10px;
  }
  .toggle-btn {
    padding: 0;
    margin: 0;
    border: none;
    background: none;
    position: absolute;
    left: 0;
    top: 100px;
    transform: translateY(-50%);
    cursor: pointer;
  }
  .toggle-btn:hover {
    background-color: #f8f9fa;
  }
</style>

<div class="d-flex">
  {#if visible}
    <div transition:slide={{ axis: 'x' }} class="sidebar pt-5 flex-shrink-0">
      <button type="button" class="btn-close close-btn" on:click={() => (visible = false)}></button>
      {#if !($challenges.length && $classes.length)}
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      {:else}
        <ul class="list-unstyled">
          <CollapsibleSection id="classesList" label="Classes">
            {#each $classes as c}
              <li class="mb-1">
                <button
                  on:click={() => chooseClass(c.id)}
                  type="button"
                  class="list-group-item list-group-item-action d-flex justify-content-between {$chosenClass === c
                    ? 'fw-bold'
                    : ''}"
                >
                  {c.name}
                </button>
              </li>
            {/each}
          </CollapsibleSection>

          <!-- Challenges List -->
          <CollapsibleSection id="challengeList" label="Challenges">
            {#each $challenges as ch}
              <li class="mb-1">
                <button
                  on:click={() => chooseChallenge(ch.id)}
                  type="button"
                  class="list-group-item list-group-item-action d-flex justify-content-between {$chosenChallenge === ch
                    ? 'fw-bold'
                    : ''}"
                >
                  {ch.name}
                  <span class="badge {difficulty_background(ch.difficulty)} rounded-pill">{ch.difficulty}</span>
                </button>
              </li>
            {/each}
          </CollapsibleSection>
        </ul>
      {/if}
    </div>
  {:else}
    <button class="toggle-btn text-secondary" on:click={() => (visible = true)}>
      <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24">
        <path d="M9 6l6 6-6 6z" fill="#6c757d" />
      </svg>
    </button>
  {/if}
</div>
