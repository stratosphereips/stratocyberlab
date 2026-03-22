<script>
  import { onDestroy } from 'svelte';
  import { isLoading, setPluginRunning } from './stores';

  export let plugin;

  const PLUGIN_UI_START_DELAY_MS = 2500;
  let waitingForIframe = false;
  let iframeDelayTimer;

  function clearIframeDelay() {
    if (iframeDelayTimer) {
      clearTimeout(iframeDelayTimer);
      iframeDelayTimer = null;
    }
    waitingForIframe = false;
  }

  function beginIframeDelay() {
    clearIframeDelay();
    waitingForIframe = true;
    iframeDelayTimer = setTimeout(() => {
      waitingForIframe = false;
      iframeDelayTimer = null;
    }, PLUGIN_UI_START_DELAY_MS);
  }

  onDestroy(() => {
    clearIframeDelay();
  });

  $: if (!plugin.running) {
    clearIframeDelay();
  }

  async function flipActivity() {
    if (!plugin.valid) {
      return;
    }

    isLoading.set(true);
    try {
      const action = plugin.running === true ? 'stop' : 'start';
      const res = await fetch(`/api/plugins/${plugin.id}/${action}`, {
        method: 'POST',
      });

      if (res.status !== 200) {
        throw new Error(`Error: request failed with HTTP status ${res.status}: ${await res.text()}`);
      }

      setPluginRunning(plugin.id, action === 'start');
      if (action === 'start') {
        beginIframeDelay();
      } else {
        clearIframeDelay();
      }
    } catch (err) {
      console.error(err);
      alert(err instanceof Error ? err.message : err);
    }
    isLoading.set(false);
  }
</script>

<style>
  .slow-spinner {
    animation-duration: 1.5s;
  }

  .plugin-frame {
    width: 100%;
    min-height: 620px;
    border: 0;
    display: block;
    background: #fff;
  }
</style>

<div class="mb-3 d-flex justify-content-between align-items-center">
  <div>
    <h4 class="d-inline">{plugin.name}</h4>
    {#if plugin.version}
      <span class="badge text-bg-secondary ms-2">v{plugin.version}</span>
    {/if}
  </div>
</div>

<div class="pt-3 text-muted me-3 mb-3">
  {plugin.description || 'No description provided.'}
</div>

{#if plugin.validation_errors.length > 0}
  <div class="alert alert-danger me-2" role="alert">
    <div class="fw-semibold mb-2">Validation errors</div>
    <ul class="mb-0">
      {#each plugin.validation_errors as error}
        <li>{error}</li>
      {/each}
    </ul>
  </div>
{/if}

{#if plugin.runtime_error}
  <div class="alert alert-warning me-2" role="alert">
    <div class="fw-semibold mb-1">Runtime check failed</div>
    <div>{plugin.runtime_error}</div>
  </div>
{/if}

<div
  class="alert me-2 d-flex justify-content-between align-items-center {plugin.running
    ? 'alert-success'
    : 'alert-light'}"
  role="alert"
>
  <div class="d-flex align-items-center">
    {#if plugin.running}
      <div class="spinner-grow text-success me-2 slow-spinner" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
      <span>The plugin is up and running!</span>
    {:else if plugin.valid}
      <span>The plugin is not running</span>
    {:else}
      <span>This plugin is invalid and cannot be started</span>
    {/if}
  </div>

  <button
    class="btn {!plugin.running ? 'btn-primary' : 'btn-secondary'} ms-auto"
    on:click={flipActivity}
    disabled={!plugin.valid}
  >
    {plugin.running ? 'Stop' : 'Start'}
  </button>
</div>

{#if !plugin.has_ui}
  <div class="alert alert-secondary me-2" role="alert">
    This plugin does not declare a control plane URL so there's no UI embedded.
  </div>
{:else if !plugin.valid}
  <div class="alert alert-secondary me-2" role="alert">
    Plugin's not valid, issues must be resolved before UI can be displayed.
  </div>
{:else if !plugin.running}
  <div class="alert alert-secondary me-2" role="alert">Start the plugin to load its control plane here.</div>
{:else if waitingForIframe}
  <div class="alert alert-secondary me-2" role="alert">
    Plugin started. Waiting a couple of seconds for it to initialise before loading the UI.
  </div>
{:else}
  <div class="card me-2 mb-3">
    <div class="card-header">Plugin UI</div>
    <div class="card-body p-0">
      <iframe class="plugin-frame" src={plugin.proxy_url} title={`${plugin.name} UI`}></iframe>
    </div>
  </div>
{/if}
