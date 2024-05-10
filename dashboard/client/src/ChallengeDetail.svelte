<script>

    export let challenge;


    async function flagSubmit(task){
        console.log(task)

        let payload = {
            "challenge_id": challenge.id,
            "task_id": task.id,
            "flag": task.flag,
        }

        try {
            const res = await fetch(`/api/submit`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload),
            });
            const data = await res.text();

            if (res.status !== 200) {
                throw new String(`Error: request failed with HTTP status ${res.status}: ${res.body}`);
            }

            if (data.includes("Congratulations")) {
                task.solved = true
                challenge.tasks = challenge.tasks; // Reassign to trigger reactivity
            }
            alert(data)

        } catch(err) {
            alert(err)
        }
    }

</script>




<style>
</style>

{#if challenge === undefined}
    <div class="pt-5">
    ⬅ Choose a challenge and happy hacking!
    </div>

{:else}
    <div class="ms-2">
        <h4>{challenge.name}</h4>
        <p class="text-muted" >{challenge.description}</p>
    </div>

    {#each challenge["tasks"] as task}

        <div class="card {task.solved ? 'border-success' : ''} mb-3 me-2">
          <div class="card-header {task.solved ? 'bg-success-subtle' : ''}">
              {task.name}
          </div>
          <div class="card-body">
            <p class="card-text">{task.description}</p>

            <div class="input-group mb-3">
                <span class="input-group-text" id="basic-addon1">Flag: </span>
                <input type="text" bind:value={task.flag} class="form-control">
                <button class="btn btn-outline-secondary" on:click={()=>flagSubmit(task)} type="button">Submit</button>
             </div>

          </div>
        </div>

    {/each}

{/if}
