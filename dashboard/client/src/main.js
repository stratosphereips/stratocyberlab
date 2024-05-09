import App from './App.svelte';

import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap/dist/js/bootstrap.min.js'

let app;

app = new App({
    target: document.getElementById('main'),
    props: {
    }
});

export default app;
