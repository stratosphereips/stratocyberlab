<script>
    import ChallengeDetail from "./ChallengeDetail.svelte";
	import { onMount } from 'svelte';
    import ClassDetail from "./ClassDetail.svelte";

    let challenges;
    let classes;
    let chosenChallenge;
    let chosenClass;

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
          {#if challenges === undefined || classes === undefined}
          <div class="spinner-border" role="status">
                <span class="visually-hidden">Loading...</span>
          </div>
          {:else}
              <h3>Classes</h3>
              <div class="list-group">
                {#each classes as c}
                  <button on:click={() => {chosenClass = c; chosenChallenge = undefined}}
                          type="button" class="list-group-item list-group-item-action d-flex justify-content-between">
                      {c.name}
                  </button>
                {/each}
              </div>

              <h3>Challenges</h3>
              <div class="list-group">
                {#each challenges as ch}
                  <button on:click={() => {chosenChallenge = ch; chosenClass = undefined}}
                          type="button" class="list-group-item list-group-item-action d-flex justify-content-between">
                      {ch.name} <span class="badge {difficulty_background(ch.difficulty)} rounded-pill">{ch.difficulty}</span>
                  </button>
                {/each}
              </div>
          {/if}
      </div>

      <div class="col-9">
          {#if chosenChallenge !== undefined}
              <ChallengeDetail bind:challenge="{chosenChallenge}"/>
          {:else if chosenClass !== undefined}
              <ClassDetail bind:curClass="{chosenClass}"/>
          {:else}
            <div class="pt-5">
                ⬅ Choose a challenge or class and happy hacking!
            </div>
          {/if}
      </div>
</div>
