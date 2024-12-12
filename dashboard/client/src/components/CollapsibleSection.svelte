<script>
  import { onMount } from 'svelte';
  import { storageBackedWritable } from '../stores';

  export let id;
  export let label;
  export let level = 1;

  let buttonClass = {
    1: 'btn-lg',
    2: '',
    3: 'btn-sm',
  }[level ?? 1];

  let expanded = false;
  const collapseStore = storageBackedWritable(`scl.collapse.${id}`, 'false');
  const unsubscribe = collapseStore.subscribe((value) => {
    expanded = value === 'true';
  });

  onMount(() => {
    const setExpandedFalse = (e) => {
      e.stopPropagation();
      $collapseStore = 'false';
    };
    const setExpandedTrue = (e) => {
      e.stopPropagation();
      $collapseStore = 'true';
    };
    const element = document.querySelector(`#${id}-collapse`);

    element.addEventListener('hidden.bs.collapse', setExpandedFalse);
    element.addEventListener('shown.bs.collapse', setExpandedTrue);

    return () => {
      unsubscribe();
      element.removeEventListener('hidden.bs.collapse', setExpandedFalse);
      element.removeEventListener('shown.bs.collapse', setExpandedTrue);
    };
  });
</script>

<style>
  :global(.btn-toggle[aria-expanded='true']::before) {
    transform: rotate(90deg);
  }
  .btn-toggle::before {
    width: 1.25em;
    line-height: 0;
    content: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='rgba%280,0,0,.5%29' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M5 14l6-6-6-6'/%3e%3c/svg%3e");
    transition: transform 0.35s ease;
    transform-origin: 0.5em 50%;
  }
</style>

<li class="mb-1">
  <div class="d-flex justify-content-between">
    <button
      id="{id}-header"
      class="btn {buttonClass} btn-toggle d-inline-flex align-items-center rounded p-0 {!expanded ? 'collapsed' : ''}"
      type="button"
      data-bs-toggle="collapse"
      data-bs-target="#{id}-collapse"
      aria-expanded={expanded ? 'true' : 'false'}
      aria-controls="{id}-collapse"
    >
      {label ?? ''}
    </button>
    <slot name="labelExtra" />
  </div>
  <div class="collapse {expanded ? 'show' : ''}" aria-labelledby="{id}-header" id="{id}-collapse">
    <ul class="list-unstyled ms-3">
      <slot />
    </ul>
  </div>
</li>
