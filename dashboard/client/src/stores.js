import { get, writable } from 'svelte/store';
import { fetchSingleCampaign } from './fetch';

export const isLoading = writable(false);

export const classes = writable(null);
export const challenges = writable(null);
export const campaigns = writable(null);

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

export const loadSingleCampaign = async (id) => {
  if (loadedCampaignIds.has(id)) return;

  const campaign = await fetchSingleCampaign(id);
  campaigns.update((old) => {
    const neu = old === null ? [] : [...old];
    const index = neu.findIndex((camp) => camp.id === campaign.id);
    neu[index] = {
      ...neu[index],
      ...campaign,
    };
    return neu;
  });
  loadedCampaignIds.add(id);
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
