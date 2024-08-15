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
</style>

<div class="ms-2 d-flex justify-content-between align-items-center">
    <div>
        <h4 class="d-inline">{curClass.name}</h4>
    </div>
    {#if curClass.dir}
    <div>
        <span class="badge bg-{curClass.running ? 'success' : 'secondary'} ms-2">
            {curClass.running ? 'Active' : 'Inactive'}
        </span>
        <button class="btn btn-info btn-sm ms-2" on:click={flipActivity}>
            {curClass.running ? 'Stop' : 'Start'}
        </button>
    </div>
    {/if}
</div>
<p class="text-muted">{curClass.description}</p>
