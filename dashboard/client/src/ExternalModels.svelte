<script>
  export let models = [];
  export let currentExternalId = null;
  export let onSelect;
  export let onChange;
  export let waitingForReply = false;

  // Examples only: users can enter any model ID supported by their endpoint.
  const providers = {
    einfra: {
      label: 'CESNET / e-INFRA CZ',
      url: 'https://llm.ai.e-infra.cz/v1',
      models: ['mini', 'deepseek', 'gpt-oss-120b'],
    },
    openai: {
      label: 'OpenAI',
      url: 'https://api.openai.com/v1',
      models: ['gpt-4.1-mini', 'gpt-4.1'],
    },
    anthropic: {
      label: 'Anthropic',
      url: 'https://api.anthropic.com/v1',
      models: ['claude-haiku-4-5-20251001', 'claude-sonnet-5', 'claude-opus-5'],
    },
    custom: { label: 'Custom', url: '', models: [] },
  };

  let expanded = false;
  let editingId = null;
  let provider = 'custom';
  let baseUrl = '';
  let apiKey = '';
  let model = '';
  let saving = false;
  let error = '';

  function resetForm() {
    editingId = null;
    provider = 'custom';
    baseUrl = '';
    apiKey = '';
    model = '';
    error = '';
    expanded = false;
  }

  function chooseProvider(id) {
    provider = id;
    baseUrl = providers[id].url;
    model = '';
    apiKey = '';
  }

  function editModel(item) {
    editingId = item.id;
    provider = item.provider;
    baseUrl = item.base_url;
    model = item.model;
    apiKey = '';
    error = '';
    expanded = true;
  }

  async function saveModel() {
    if (saving) return;
    saving = true;
    error = '';
    try {
      const response = await fetch(`/api/llm/external-models${editingId ? `/${editingId}` : ''}`, {
        method: editingId ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ provider, base_url: baseUrl, api_key: apiKey, model }),
      });
      if (!response.ok) throw new Error(await response.text());
      resetForm();
      await onChange();
    } catch (err) {
      error = err.message || 'Could not save the external model.';
    } finally {
      saving = false;
    }
  }

  async function removeModel(item) {
    if (!confirm(`Remove external model "${item.model}"?`)) return;
    error = '';
    try {
      const response = await fetch(`/api/llm/external-models/${item.id}`, { method: 'DELETE' });
      if (!response.ok) throw new Error(await response.text());
      if (editingId === item.id) resetForm();
      await onChange();
    } catch (err) {
      error = err.message || 'Could not remove the external model.';
    }
  }
</script>

<section aria-labelledby="external-models-title">
  <h5 id="external-models-title">External models</h5>
  <p class="text-muted small">Connect a model through an OpenAI-compatible API.</p>
  {#if models.length === 0}
    <p class="text-muted">No external models configured yet.</p>
  {:else}
    <div class="list-group mb-3">
      {#each models as item (item.id)}
        <div class="list-group-item d-flex flex-wrap align-items-center justify-content-between gap-2">
          <div class="text-break">
            <div class="fw-semibold">{item.model}</div>
            <small class="text-muted">{providers[item.provider]?.label || 'Custom'} · {item.base_url}</small>
          </div>
          <div class="d-flex gap-2">
            <button
              class:btn-outline-success={currentExternalId === item.id}
              class:btn-outline-secondary={currentExternalId !== item.id}
              class="btn btn-sm"
              disabled={currentExternalId === item.id || waitingForReply || saving}
              on:click={() => onSelect(item.model, item.id)}
              >{currentExternalId === item.id ? 'Selected' : 'Use this'}</button
            >
            <button
              class="btn btn-sm btn-outline-secondary"
              disabled={saving || waitingForReply}
              on:click={() => editModel(item)}>Edit</button
            >
            <button
              class="btn btn-sm btn-outline-danger"
              disabled={saving || waitingForReply}
              on:click={() => removeModel(item)}>Remove</button
            >
          </div>
        </div>
      {/each}
    </div>
  {/if}

  <button
    class="btn btn-sm btn-outline-primary"
    aria-expanded={expanded}
    aria-controls="external-model-form"
    disabled={saving}
    on:click={() => {
      const open = !expanded;
      resetForm();
      expanded = open;
    }}
    ><span aria-hidden="true">{expanded ? '−' : '+'}</span>
    {expanded ? 'Close configuration' : 'Add external model'}</button
  >

  {#if error}<div class="alert alert-danger mt-3" role="alert">{error}</div>{/if}

  {#if expanded}
    <form id="external-model-form" class="border rounded bg-light p-3 mt-3" on:submit|preventDefault={saveModel}>
      <fieldset disabled={saving || waitingForReply}>
        <legend class="h6">{editingId ? 'Edit external model' : 'Add external model'}</legend>
        <div class="d-flex flex-wrap gap-2 mb-3" aria-label="Provider presets">
          {#each Object.entries(providers) as [id, preset]}
            <button
              type="button"
              class="btn btn-sm"
              class:btn-primary={provider === id}
              class:btn-outline-secondary={provider !== id}
              aria-pressed={provider === id}
              on:click={() => chooseProvider(id)}>{preset.label}</button
            >
          {/each}
        </div>
        <div class="mb-3">
          <label for="external-base-url" class="form-label">OpenAI-compatible API URL</label>
          <input
            id="external-base-url"
            class="form-control"
            type="url"
            required
            placeholder="https://example.com/v1"
            bind:value={baseUrl}
            on:input={() => {
              provider = 'custom';
            }}
          />
          <div class="form-text">Enter the base URL, including /v1 if needed. Do not append /chat/completions.</div>
        </div>
        <div class="mb-3">
          <label for="external-api-key" class="form-label">API key</label>
          <input
            id="external-api-key"
            class="form-control"
            type="password"
            autocomplete="new-password"
            required={!editingId}
            bind:value={apiKey}
            placeholder={editingId ? 'Leave blank to keep the saved key' : 'Paste your API key'}
          />
          <div class="form-text">
            {editingId
              ? 'The saved key is never displayed. Enter a new key to replace it.'
              : 'The key will not be displayed after saving.'}
          </div>
        </div>
        <div class="mb-3">
          <label for="external-model-id" class="form-label">Model</label>
          <input
            id="external-model-id"
            class="form-control"
            required
            bind:value={model}
            placeholder="Enter a model ID or choose an example below"
          />
          {#if providers[provider]?.models.length}
            <div class="d-flex flex-wrap gap-2 mt-2">
              {#each providers[provider].models as example}
                <button class="btn btn-sm btn-outline-secondary" type="button" on:click={() => (model = example)}
                  >{example}</button
                >
              {/each}
            </div>
            <div class="form-text">Example model IDs; availability depends on your provider and account.</div>
          {/if}
        </div>
        <button class="btn btn-primary" type="submit">{saving ? 'Saving…' : 'Save model'}</button>
        <button class="btn btn-outline-secondary ms-2" type="button" on:click={resetForm}>Cancel</button>
      </fieldset>
    </form>
  {/if}
</section>
