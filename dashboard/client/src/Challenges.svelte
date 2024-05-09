<script>
    import ChallengeDetail from "./ChallengeDetail.svelte";
	import { onMount } from 'svelte';

    let challenges;
    let chosenChallenge;

    onMount(async () => {
		fetchChallenges()
	});


    async function fetchChallenges() {
        try {
            const res = await fetch(`/api/challenges`);
            const data = await res.json();

            if (res.status !== 200) {
                throw new String(`Error: request failed with HTTP status ${res.status}: ${res.body}`);
            }

            challenges = data

        } catch(err) {
            alert(err)
        }
    }

    function difficulty_background(d){
        return d === "easy" ? "bg-success" : d === "medium" ? "bg-warning" : "bg-danger";
    }
</script>

<style>
</style>

<div class="row">
      <div class="col-3 mb-2">
          <h2>Challenges </h2>
          {#if challenges === undefined}
          <div class="spinner-border" role="status">
                <span class="visually-hidden">Loading...</span>
          </div>
          {:else}
              <div class="list-group">
                {#each challenges as ch}
                  <button on:click={() => {chosenChallenge = ch}}
                          type="button" class="list-group-item list-group-item-action d-flex justify-content-between">
                      {ch.name} <span class="badge {difficulty_background(ch.difficulty)} rounded-pill">{ch.difficulty}</span>
                  </button>
                {/each}
              </div>
          {/if}
      </div>
      <div class="col-9">
          <ChallengeDetail challenge="{chosenChallenge}"/>
      </div>
</div>
