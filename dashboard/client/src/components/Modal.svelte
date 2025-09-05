<script>
  import { createEventDispatcher, onDestroy } from 'svelte';

  export let open = false;
  export let title = '';
  export let size = 'md'; // 'sm' | 'md' | 'lg' | 'xl'
  export let closeOnEsc = true;
  export let closeOnBackdrop = true;

  const dispatch = createEventDispatcher();
  let modalEl;
  let lastFocused;

  function close() {
    dispatch('close');
  }

  function handleKeydown(e) {
    if (e.key === 'Escape' && closeOnEsc) {
      e.stopPropagation();
      close();
    }
  }

  function onBackdrop(e) {
    if (closeOnBackdrop && e.target === e.currentTarget) close();
  }

  $: {
    if (open) {
      lastFocused = document.activeElement;
      document.body.classList.add('modal-open');
      document.body.style.overflow = 'hidden';
      setTimeout(() => modalEl?.focus(), 0);
    } else {
      document.body.classList.remove('modal-open');
      document.body.style.overflow = '';
      if (lastFocused?.focus) setTimeout(() => lastFocused.focus(), 0);
    }
  }

  onDestroy(() => {
    document.body.classList.remove('modal-open');
    document.body.style.overflow = '';
  });

  const sizeClass = size === 'sm' ? 'modal-sm' : size === 'lg' ? 'modal-lg' : size === 'xl' ? 'modal-xl' : '';
</script>

{#if open}
  <div class="modal-backdrop fade show"></div>

  <!-- eslint-disable-next-line svelte/valid-compile -->
  <div
    class="modal fade show"
    style="display:block"
    tabindex="-1"
    role="dialog"
    aria-modal="true"
    aria-labelledby={title ? 'modal-title' : undefined}
    on:click={onBackdrop}
    on:keydown={handleKeydown}
  >
    <div class={'modal-dialog modal-dialog-centered ' + sizeClass} role="document">
      <div class="modal-content" bind:this={modalEl}>
        {#if title}
          <div class="modal-header">
            <h5 class="modal-title" id="modal-title">{title}</h5>
            <button type="button" class="btn-close" aria-label="Close" on:click={close}></button>
          </div>
        {/if}

        <div class="modal-body">
          <slot />
        </div>

        <div class="modal-footer">
          <slot name="footer">
            <button type="button" class="btn btn-outline-secondary w-auto" on:click={close}>Close</button>
          </slot>
        </div>
      </div>
    </div>
  </div>
{/if}
