<script>
  import { storageBackedWritable } from '../stores';

  export let id;
  export let label;
  export let level = 1;
  export let icon = null; // a Heroicons Svelte component (e.g., AcademicCap)
  export let title = "Click to expand/collapse"

  let buttonClass = { 1: 'btn-lg', 2: '', 3: 'btn-sm' }[level ?? 1];

  let expanded = false;
  const collapseStore = storageBackedWritable(`scl.collapse.${id}`, 'false');
  collapseStore.subscribe((value) => (expanded = value === 'true'));

  // Toggle only if the click didn't come from labelExtra
  function onHeaderClick(e) {
    if (e.target.closest('[data-label-extra]')) return;
    $collapseStore = expanded ? 'false' : 'true';
  }

  function onHeaderKey(e) {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      onHeaderClick(e);
    }
  }
</script>

<style>
  :global(.btn-toggle[aria-expanded='true'] .chev) { transform: rotate(90deg); }
  .chev { transition: transform .25s ease; }

  .btn-toggle:hover {
    background-color: var(--bs-gray-200);
    box-shadow: inset 0 0 0 1px var(--bs-border-color);
  }
  .btn-toggle:focus-visible {
    outline: 2px solid var(--bs-primary);
    outline-offset: 2px;
  }
</style>

<li class="mb-2">
  <div
    id="{id}-header"
    role="button"
    tabindex="0"
    class="btn {buttonClass} btn-toggle w-100 text-start d-inline-flex align-items-center gap-2 px-2 py-2"
    aria-expanded={expanded ? 'true' : 'false'}
    aria-controls="{id}-panel"
    title={title}
    on:click={onHeaderClick}
    on:keydown={onHeaderKey}
  >
    {#if icon}
      <svelte:component this={icon} width="18" height="18" />
    {/if}
    <span class="flex-grow-1">{label ?? ''}</span>
    <slot name="labelExtra" />

    <!-- chevron -->
    <svg class="chev" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16">
      <path fill="none" stroke="rgba(0,0,0,.55)" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 14l6-6-6-6" />
    </svg>
  </div>

  {#if expanded}
  <div id="{id}-panel" aria-labelledby="{id}-header">
    <ul class="list-unstyled ms-2 my-2">
      <slot />
    </ul>
  </div>
  {/if}
</li>
