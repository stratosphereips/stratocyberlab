import { writable } from 'svelte/store';

export const isLoading = writable(false);

export const classes = writable([]);
export const challenges = writable([]);
