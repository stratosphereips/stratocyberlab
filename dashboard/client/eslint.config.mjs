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
        files: ['!src/**/*'],
        languageOptions: {
            globals: {
                ...globals.node,
            },
        },
    }
];
