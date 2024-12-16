import { get, writable } from 'svelte/store';

export const isLoading = writable(false);

export const classes = writable(null);
export const challenges = writable(null);

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
