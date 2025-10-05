<script>
  import { marked } from 'marked';

  export let campaign;
</script>

<div>
  <h2>{campaign.name}</h2>
  <!-- eslint-disable-next-line svelte/no-at-html-tags -->
  <div class="me-3">
    {@html marked.parse(campaign.description)}
  </div>
</div>
