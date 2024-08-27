<script>
    import ChallengeDetail from "./ChallengeDetail.svelte";
	import { onMount } from 'svelte';
    import ClassDetail from "./ClassDetail.svelte";
    import Introduction from "./Introduction.svelte";

    let challenges;
    let classes;
    export let chosenChallenge;
    export let chosenClass;

    onMount(async () => {
		await fetchChallenges()
        await fetchClasses()
	});

    const difficultyOrder = { 'easy': 1, 'medium': 2, 'hard': 3 };

    async function fetchChallenges() {
        try {
            const res = await fetch(`/api/challenges`);
            const data = await res.json();

            if (res.status !== 200) {
                throw new String(`Error: request failed with HTTP status ${res.status}: ${res.body}`);
            }

            // sort based on challenges difficulties - first we show easy, then medium and lastly hard
            data.sort((a, b) => {
                return difficultyOrder[a.difficulty] - difficultyOrder[b.difficulty];
            });
            challenges = data


            const res2 = await fetch(`/api/challenges/up`);
            const upChallenges = await res2.json();
            if (res2.status !== 200) {
                throw new String(`Error: request failed with HTTP status ${res2.status}: ${res2.body}`);
            }
            upChallenges.forEach(ch_id => {
                const ch = challenges.find(ch => ch.id === ch_id);
                if (ch) {
                    ch["running"] = true;
                }
            });

        } catch(err) {
            alert(err)
        }
    }

        async function fetchClasses() {
        try {
            const res = await fetch(`/api/classes`);
            const data = await res.json();

            if (res.status !== 200) {
                throw new String(`Error: request failed with HTTP status ${res.status}: ${res.body}`);
            }

            classes = data

            const res2 = await fetch(`/api/classes/up`);
            const upClasses = await res2.json();
            if (res2.status !== 200) {
                throw new String(`Error: request failed with HTTP status ${res2.status}: ${res2.body}`);
            }
            upClasses.forEach(c_id => {
                const c = classes.find(c => c.id === c_id);
                if (c) {
                    c["running"] = true;
                }
            });

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
    <div class="p-3" style="background-color: #f8f9fa; border-radius: 8px;">
      {#if challenges === undefined || classes === undefined}
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      {:else}
        <div class="list-group">
          <button class="list-group-item list-group-item-action d-flex justify-content-between"
                  type="button"
                  data-bs-toggle="collapse"
                  data-bs-target="#classesList"
                  aria-expanded="false"
                  aria-controls="classesList">
            <b>Classes</b>
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
              <path d="M7 10l5 5 5-5z"/>
            </svg>
          </button>

          <div id="classesList" class="collapse">
            {#each classes as c}
              <button
                on:click={() => {chosenClass = c; chosenChallenge = undefined}}
                type="button"
                class="list-group-item list-group-item-action d-flex justify-content-between">
                {c.name}
              </button>
            {/each}
          </div>
        </div>

<!--        <h3>Challenges</h3>-->
        <!-- Challenges List -->
        <div class="pt-2 list-group">
            <div class="list-group-item list-group-item-action d-flex justify-content-between">
              <b>Challenges</b>
            </div>
          {#each challenges as ch}
            <button
              on:click={() => {chosenChallenge = ch; chosenClass = undefined}}
              type="button"
              class="list-group-item list-group-item-action d-flex justify-content-between">
              {ch.name}
              <span class="badge {difficulty_background(ch.difficulty)} rounded-pill">{ch.difficulty}</span>
            </button>
          {/each}
        </div>
      {/if}
    </div>
  </div>

      <div class="col-9">
          {#if chosenChallenge !== undefined}
              <ChallengeDetail bind:challenge="{chosenChallenge}"/>
          {:else if chosenClass !== undefined}
              <ClassDetail bind:curClass="{chosenClass}"/>
          {:else}
              <Introduction/>
          {/if}
      </div>
</div>