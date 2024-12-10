<script>
  import { onMount } from 'svelte';
  import { slide } from 'svelte/transition';
  import CollapsibleSection from './components/CollapsibleSection.svelte';

  let challenges;
  let classes;
  let visible = true;
  export let chosenChallenge;
  export let chosenClass;

  onMount(async () => {
    fetchChallenges().then();
    fetchClasses().then();
  });

  const difficultyOrder = { easy: 1, medium: 2, hard: 3 };

  async function fetchChallenges() {
    try {
      const res = await fetch(`/api/challenges`);
      const data = await res.json();

      if (res.status !== 200) {
        throw new Error(`Error: request failed with HTTP status ${res.status}: ${await res.text()}`);
      }

      // sort based on challenges difficulties - first we show easy, then medium and lastly hard
      data.sort((a, b) => {
        return difficultyOrder[a.difficulty] - difficultyOrder[b.difficulty];
      });
      challenges = data;

      const res2 = await fetch(`/api/challenges/up`);
      const upChallenges = await res2.json();
      if (res2.status !== 200) {
        throw new Error(`Error: request failed with HTTP status ${res2.status}: ${res2.body}`);
      }
      upChallenges.forEach((ch_id) => {
        const ch = challenges.find((ch) => ch.id === ch_id);
        if (ch) {
          ch['running'] = true;
        }
      });
    } catch (err) {
      console.error(err);
      alert(err instanceof Error ? err.message : err);
    }
  }

  async function fetchClasses() {
    try {
      const res = await fetch(`/api/classes`);
      const data = await res.json();

      if (res.status !== 200) {
        throw new Error(`Error: request failed with HTTP status ${res.status}: ${await res.text()}`);
      }

      classes = data;

      const res2 = await fetch(`/api/classes/up`);
      const upClasses = await res2.json();
      if (res2.status !== 200) {
        throw new Error(`Error: request failed with HTTP status ${res2.status}: ${res2.body}`);
      }
      upClasses.forEach((c_id) => {
        const c = classes.find((c) => c.id === c_id);
        if (c) {
          c['running'] = true;
        }
      });
    } catch (err) {
      console.error(err);
      alert(err instanceof Error ? err.message : err);
    }
  }

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
      {#if challenges === undefined || classes === undefined}
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      {:else}
        <ul class="list-unstyled">
          <CollapsibleSection id="classesList" label="Classes">
            {#each classes as c}
              <li class="mb-1">
                <button
                  on:click={() => {
                    chosenClass = c;
                    chosenChallenge = undefined;
                  }}
                  type="button"
                  class="list-group-item list-group-item-action d-flex justify-content-between {chosenClass === c
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
            {#each challenges as ch}
              <li class="mb-1">
                <button
                  on:click={() => {
                    chosenChallenge = ch;
                    chosenClass = undefined;
                  }}
                  type="button"
                  class="list-group-item list-group-item-action d-flex justify-content-between {chosenChallenge === ch
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
