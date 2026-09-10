<script>
  import { contextStats } from './terminalContext.js';

  export let context;
  export let expanded = false;
  $: stats = contextStats(context);
</script>

<details class="terminal-context border rounded p-2 mt-2 text-body bg-light" open={expanded}>
  <summary class="small">
    Terminal context · {stats.lines}
    {stats.lines === 1 ? 'line' : 'lines'} · {stats.bytes.toLocaleString()} bytes
  </summary>
  <div class="small text-muted mt-2">
    Captured {new Date(context.captured_at).toLocaleString()}
    {#if context.truncated}
      · Older output omitted{/if}
  </div>
  <pre class="small mb-0 mt-2">{context.text}</pre>
</details>

<style>
  .terminal-context {
    min-width: 0;
  }
  summary {
    cursor: pointer;
  }
  pre {
    white-space: pre-wrap;
    overflow-wrap: anywhere;
    max-height: 18rem;
    overflow-y: auto;
  }
</style>
