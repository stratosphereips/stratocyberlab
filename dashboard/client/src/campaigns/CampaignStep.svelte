<script>
  import ChallengeDetail from '../ChallengeDetail.svelte';
  import { marked } from 'marked';

  export let step;
</script>

<div>
  {#if step.type === 'page'}
    <!-- eslint-disable-next-line svelte/no-at-html-tags -->
    {@html marked.parse(step.content)}
  {:else}
    <ChallengeDetail challenge={step} />
  {/if}
</div>
