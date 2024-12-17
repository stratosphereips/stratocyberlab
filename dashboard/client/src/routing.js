import { derived, readable } from 'svelte/store';
import { campaigns, challenges, classes } from './stores';

export const navigate = (path) => {
  location.hash = path;
};

export const chooseChallenge = (id) => navigate(`challenge/${id}`);

export const chooseClass = (id) => navigate(`class/${id}`);

export const chooseCampaignStep = (campaignId, stepId) => navigate(`campaign/${campaignId}/${stepId}`);

export const chooseCampaignDetail = (campaignId) => navigate(`campaign/${campaignId}`);

export const path = readable(window.location.hash, (set) => {
  const update = () => set(window.location.hash);
  window.addEventListener('hashchange', update);
  return () => window.removeEventListener('hashchange', update);
});

export const chosenChallenge = derived([challenges, path], ([challenges, path]) => {
  const match = path.match(/^#challenge\/(.+)$/);
  if (!match) return null;

  return challenges?.find((chall) => chall.id === match[1]) ?? null;
});

export const chosenClass = derived([classes, path], ([classes, path]) => {
  const match = path.match(/^#class\/(.+)$/);
  if (!match) return null;

  return classes?.find((cls) => cls.id === match[1]) ?? null;
});

export const chosenCampaignStep = derived([campaigns, path], ([campaigns, path]) => {
  const match = path.match(/^#campaign\/(.+)\/(.+)$/);
  if (!match) return null;

  const [, campaignId, stepId] = match;

  const step = campaigns?.find((camp) => camp.id === campaignId)?.steps?.find((step) => step.id === stepId) ?? null;
  return step === null
    ? null
    : {
        ...step,
        campaignId,
      };
});

export const chosenCampaignDetail = derived([campaigns, path], ([campaigns, path]) => {
  const match = path.match(/^#campaign\/(.+)$/);
  if (!match) return null;

  return campaigns?.find((camp) => camp.id === match[1]) ?? null;
});
