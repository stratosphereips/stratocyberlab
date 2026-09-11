import { get, writable } from 'svelte/store';
import { fetchSingleCampaign } from './fetch';

export const isLoading = writable(false);

export const classes = writable(null);
export const challenges = writable(null);
export const campaigns = writable(null);
export const plugins = writable(null);
export const dashboardReset = writable(null);

// Clear only progress in already-loaded views; runtime status and browser state stay intact.
export async function clearProgress() {
  const ids = [...loadedCampaignIds, ...loadingCampaigns.keys()];
  progressGeneration += 1;
  loadedCampaignIds.clear();
  loadingCampaigns.clear();
  const clearTasks = (tasks) => tasks?.map((task) => ({ ...task, solved: false, flag: null }));
  challenges.update((items) => items?.map((item) => ({ ...item, tasks: clearTasks(item.tasks) })) ?? null);
  campaigns.update((items) => items?.map((item) => ({
    ...item,
    steps: undefined,
  })) ?? null);
  await Promise.all(ids.map(loadSingleCampaign));
}

export const storageBackedWritable = (key, defaultData) => {
  const store = writable(localStorage.getItem(key) ?? defaultData);
  const { set: rawSet, subscribe } = store;

  const set = (value) => {
    localStorage.setItem(key, value);
    rawSet(value);
  };

  return {
    set,
    subscribe,
    update: (setter) => set(setter(get(store))),
  };
};

// remember which campaigns we've already loaded
const loadedCampaignIds = new Set();
const loadingCampaigns = new Map();
let progressGeneration = 0;

export const loadSingleCampaign = async (id) => {
  if (!get(campaigns)) return;
  if (loadedCampaignIds.has(id)) return;
  if (loadingCampaigns.has(id)) return loadingCampaigns.get(id);
  const generation = progressGeneration;
  const pending = (async () => {
    try {
      const campaign = await fetchSingleCampaign(id);
      if (!campaign || generation !== progressGeneration) return;
      loadedCampaignIds.add(id);
      campaigns.update((old) => old?.map((item) => item.id === id ? { ...item, ...campaign } : item) ?? null);
    } finally {
      if (generation === progressGeneration) loadingCampaigns.delete(id);
    }
  })();
  loadingCampaigns.set(id, pending);
  return pending;
};

export const setChallengeRunning = (challengeId, campaignId, running) => {
  if (campaignId) {
    campaigns.update((campaigns) => {
      if (!campaigns) return campaigns;

      campaigns.find((camp) => camp.id === campaignId).steps.find((chall) => chall.id === challengeId).running =
        running;
      return campaigns;
    });
  } else {
    challenges.update((challs) => {
      if (!challs) return challs;

      challs.find((chall) => chall.id === challengeId).running = running;
      return challs;
    });
  }
};

export const setPluginRunning = (pluginId, running) => {
  plugins.update((items) => {
    if (!items) return items;

    const plugin = items.find((item) => item.id === pluginId);
    if (!plugin) return items;
    plugin.running = running;
    plugin.runtime_error = '';
    return items;
  });
};
