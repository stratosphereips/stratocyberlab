import App from './App.svelte';
import { mount } from 'svelte';

import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap/dist/js/bootstrap.min.js';

const app = mount(App, {
  target: document.getElementById('main'),
  props: {},
});

export default app;
