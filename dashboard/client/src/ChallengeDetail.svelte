<script>
    import { isLoading } from './stores';

    export let challenge;

    async function flagSubmit(task){
        console.log(task)

        let payload = {
            "challenge_id": challenge.id,
            "task_id": task.id,
            "flag": task.flag,
        }

        try {
            const res = await fetch(`/api/challenges/submit`, {
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

    async function flipActivity(){
        isLoading.set(true);
        try {
            let payload = {
                "challenge_id": challenge.id
            }
            const action = challenge.running === true ? "stop" : "start"
            const res = await fetch(`/api/challenges/${action}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload),
            });
            if (res.status !== 200) {
                throw new String(`Error: request failed with HTTP status ${res.status}: ${res.body}`);
            }

            challenge.running = action === "start"

        } catch(err) {
            alert(err)
        }
        isLoading.set(false);
    }

</script>




<style>
    .slow-spinner {
        animation-duration: 1.5s;
    }
</style>

<div class="pt-4 ms-2 d-flex justify-content-between align-items-center">
    <div>
        <h4 class="d-inline">{challenge.name}</h4>
    </div>
</div>
<p class="pt-3 text-muted">{challenge.description}</p>

<div class="alert me-2 d-flex justify-content-between align-items-center {challenge.running ? 'alert-success' : 'alert-light'}" role="alert">
    <div class="d-flex align-items-center">
        {#if challenge.running}
        <div class="spinner-grow text-success me-2 slow-spinner" role="status">
            <span class="visually-hidden">Loading...</span>
        </div>
        <span>The challenge is up and running!</span>
        {:else}
        <span>The challenge is not running</span>
        {/if}
    </div>

    <button class="btn {!challenge.running ? 'btn-primary' : 'btn-secondary'} ms-auto" on:click={flipActivity}>
        {challenge.running ? 'Stop' : 'Start'}
    </button>
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
            <input disabled={!challenge.running} type="text" bind:value={task.flag} class="form-control">
            <button disabled={!challenge.running} class="btn btn-outline-secondary" on:click={()=>flagSubmit(task)} type="button">Submit</button>
         </div>

      </div>
    </div>

{/each}
