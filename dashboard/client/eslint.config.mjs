import eslintPluginSvelte from 'eslint-plugin-svelte';
import js from '@eslint/js';
import globals from 'globals';

export default [
    {
        languageOptions: {
            globals: {
                ...globals.browser,
            },
        },
    },
    js.configs.recommended,
    {
        rules: {
            'no-throw-literal': 'error',
        }
    },
    ...eslintPluginSvelte.configs['flat/recommended'],
    {
        rules: {
            // Preserve the lint policy from eslint-plugin-svelte 2.x. Existing
            // list rendering and trusted campaign HTML are intentional.
            'svelte/no-at-html-tags': 'off',
            'svelte/require-each-key': 'off',
        },
    },
    {
        files: ['!src/**/*'],
        languageOptions: {
            globals: {
                ...globals.node,
            },
        },
    }
];
