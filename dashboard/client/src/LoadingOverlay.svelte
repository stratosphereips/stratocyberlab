<script>
  import { isLoading } from './stores';
  import { onMount } from 'svelte';
  import { fade } from 'svelte/transition';

  let loading = false;

  const unsubscribe = isLoading.subscribe(value => {
    loading = value;
  });

  onMount(() => {
    return () => {
      unsubscribe();
    };
  });
</script>

<style>
  .overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
  }

  .spinner-border {
    width: 3rem;
    height: 3rem;
    border-width: 0.3em;
  }
</style>

{#if loading}
  <div class="overlay" transition:fade>
    <div class="spinner-border text-light" role="status">
    </div>
  </div>
{/if}