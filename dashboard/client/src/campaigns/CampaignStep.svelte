<script>
  import ChallengeDetail from '../ChallengeDetail.svelte';
  import { marked } from 'marked';

  export let step;
</script>

<div>
  {#if step.type === 'page'}
    <!-- eslint-disable-next-line svelte/no-at-html-tags -->
    <div class="me-3">
      {@html marked.parse(step.content)}
    </div>
  {:else}
    <ChallengeDetail challenge={step} />
  {/if}
</div>
