<script>
    import { isLoading } from './stores';

    export let curClass;

    async function flipActivity(){
        isLoading.set(true);
        try {
            let payload = {
                "id": curClass.id
            }
            const action = curClass.running === true ? "stop" : "start"
            const res = await fetch(`/api/classes/${action}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload),
            });
            if (res.status !== 200) {
                throw new String(`Error: request failed with HTTP status ${res.status}: ${res.body}`);
            }

            curClass.running = action === "start"

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
        <h4 class="d-inline">{curClass.name}</h4>
    </div>
</div>
<p class="pt-3 text-muted">{curClass.description}</p>

{#if curClass.dir}
<div class="alert me-2 d-flex justify-content-between align-items-center {curClass.running ? 'alert-success' : 'alert-light'}" role="alert">
    <div class="d-flex align-items-center">
        {#if curClass.running}
        <div class="spinner-grow text-success me-2 slow-spinner" role="status">
            <span class="visually-hidden">Loading...</span>
        </div>
        <span>The class is up and running!</span>
        {:else}
        <span>The class is not running</span>
        {/if}
    </div>

    <button class="btn {!curClass.running ? 'btn-primary' : 'btn-secondary'} ms-auto" on:click={flipActivity}>
        {curClass.running ? 'Stop' : 'Start'}
    </button>
</div>
{/if}
