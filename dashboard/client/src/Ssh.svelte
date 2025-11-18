<script>
  import { onDestroy, onMount } from 'svelte';
  import { createEventDispatcher } from 'svelte';

  import { Terminal } from '@xterm/xterm';
  import { FitAddon } from '@xterm/addon-fit';
  import '@xterm/xterm/css/xterm.css';
  import { io } from 'socket.io-client';

  const dispatch = createEventDispatcher();

  let terminalContainer;
  let terminal;
  let ws;
  let showThemeMenu = false;
  let themeMenuRef;
  let gearButtonRef;

  export let resize;

  const DEFAULT_THEME_KEY = 'default';
  const THEME_STORAGE_KEY = 'ssh-terminal-theme';
  const terminalThemes = {
    [DEFAULT_THEME_KEY]: {
      label: 'Classic',
      theme: {
        foreground: '#ffffff',
        background: '#000000',
        cursor: '#ffffff',
        cursorAccent: '#000000',
        selection: '#ffffff22',
        black: '#000000',
        red: '#cd3131',
        green: '#0dbc79',
        yellow: '#e5e510',
        blue: '#2472c8',
        magenta: '#bc3fbc',
        cyan: '#11a8cd',
        white: '#e5e5e5',
        brightBlack: '#666666',
        brightRed: '#f14c4c',
        brightGreen: '#23d18b',
        brightYellow: '#f5f543',
        brightBlue: '#3b8eea',
        brightMagenta: '#d670d6',
        brightCyan: '#29b8db',
        brightWhite: '#e5e5e5',
      },
    },
    highContrast: {
      label: 'High Contrast',
      theme: {
        foreground: '#ffff00',
        background: '#000000',
        cursor: '#ffff00',
        cursorAccent: '#000000',
        black: '#000000',
        red: '#ff5555',
        green: '#55ff55',
        yellow: '#ffff55',
        blue: '#5555ff',
        magenta: '#ff55ff',
        cyan: '#55ffff',
        white: '#ffffff',
        brightBlack: '#7f7f7f',
        brightRed: '#ff6e67',
        brightGreen: '#5af78e',
        brightYellow: '#f4f99d',
        brightBlue: '#57c7ff',
        brightMagenta: '#ff6ac1',
        brightCyan: '#9aedfe',
        brightWhite: '#f1f1f0',
      },
    },
    solarizedDark: {
      label: 'Solarized Dark',
      theme: {
        foreground: '#eee8d5',
        background: '#002b36',
        cursor: '#eee8d5',
        cursorAccent: '#002b36',
        selection: '#93a1a144',
        black: '#073642',
        red: '#dc322f',
        green: '#859900',
        yellow: '#b58900',
        blue: '#268bd2',
        magenta: '#d33682',
        cyan: '#2aa198',
        white: '#eee8d5',
        brightBlack: '#002b36',
        brightRed: '#cb4b16',
        brightGreen: '#586e75',
        brightYellow: '#657b83',
        brightBlue: '#839496',
        brightMagenta: '#6c71c4',
        brightCyan: '#93a1a1',
        brightWhite: '#fdf6e3',
      },
    },
    solarizedLight: {
      label: 'Solarized Light',
      theme: {
        foreground: '#657b83',
        background: '#fdf6e3',
        cursor: '#657b83',
        cursorAccent: '#fdf6e3',
        selection: '#657b8333',
        black: '#073642',
        red: '#dc322f',
        green: '#859900',
        yellow: '#b58900',
        blue: '#268bd2',
        magenta: '#d33682',
        cyan: '#2aa198',
        white: '#eee8d5',
        brightBlack: '#002b36',
        brightRed: '#cb4b16',
        brightGreen: '#586e75',
        brightYellow: '#657b83',
        brightBlue: '#839496',
        brightMagenta: '#6c71c4',
        brightCyan: '#93a1a1',
        brightWhite: '#fdf6e3',
      },
    },
  };
  const themeOptions = Object.entries(terminalThemes);
  let selectedThemeKey = DEFAULT_THEME_KEY;

  function getSavedThemeKey() {
    if (typeof window === 'undefined') {
      return DEFAULT_THEME_KEY;
    }
    const stored = window.localStorage.getItem(THEME_STORAGE_KEY);
    if (stored && terminalThemes[stored]) {
      return stored;
    }
    return DEFAULT_THEME_KEY;
  }

  function persistThemeKey(key) {
    if (typeof window === 'undefined') {
      return;
    }
    window.localStorage.setItem(THEME_STORAGE_KEY, key);
  }

  function applyTheme(themeKey) {
    if (!terminal) {
      return;
    }
    const theme = terminalThemes[themeKey]?.theme || terminalThemes[DEFAULT_THEME_KEY].theme;
    terminal.options.theme = theme;
    if (terminal.rows > 0) {
      terminal.refresh(0, terminal.rows - 1);
    }
  }

  function setTheme(themeKey) {
    if (!terminalThemes[themeKey]) {
      return;
    }
    selectedThemeKey = themeKey;
    persistThemeKey(themeKey);
    applyTheme(themeKey);
  }

  function handleThemeChange(event) {
    setTheme(event.target.value);
    closeThemeMenu();
  }

  function toggleThemeMenu() {
    showThemeMenu = !showThemeMenu;
  }

  function closeThemeMenu() {
    showThemeMenu = false;
  }

  onMount(() => {
    const handleOutsideClick = (event) => {
      if (
        showThemeMenu &&
        themeMenuRef &&
        !themeMenuRef.contains(event.target) &&
        gearButtonRef &&
        !gearButtonRef.contains(event.target)
      ) {
        closeThemeMenu();
      }
    };
    document.addEventListener('mousedown', handleOutsideClick);
    document.addEventListener('touchstart', handleOutsideClick);

    selectedThemeKey = getSavedThemeKey();
    terminal = new Terminal({
      cursorBlink: true,
      theme: terminalThemes[selectedThemeKey].theme,
    });
    const fitAddon = new FitAddon();
    terminal.loadAddon(fitAddon);
    terminal.open(terminalContainer);
    fitAddon.fit();

    function emitTerminalSize() {
      socket.emit('ssh_resize', {
        cols: terminal.cols,
        rows: terminal.rows,
      });
    }

    resize = function () {
      fitAddon.fit();
      emitTerminalSize();
    };

    // Whenever resize happens, we dynamically resize size of terminal
    // and send the information to the server as-well
    window.addEventListener('resize', () => {
      resize();
    });

    const socket = io(`ws://${window.location.host}:8080/`, {
      path: '/socket.io',
      transports: ['websocket'],
    });

    socket.on('connect', () => {
      emitTerminalSize();
    });

    socket.on('ssh_output', (data) => {
      const decoder = new TextDecoder('utf-8');
      const text = decoder.decode(data);
      terminal.write(text);
    });

    terminal.onData((data) => {
      socket.emit('ssh_input', data);
    });
    return () => {
      document.removeEventListener('mousedown', handleOutsideClick);
      document.removeEventListener('touchstart', handleOutsideClick);
    };
  });

  onDestroy(() => {
    if (terminal) {
      terminal.dispose();
    }
    if (ws) {
      ws.close();
    }
  });

  function hide() {
    dispatch('hide');
  }
</script>

<style>
  .terminal-button {
    position: absolute;
    top: 0;
    opacity: 0.5;
    transition: opacity 0.3s ease;
    border-radius: 0 0 5px 5px;
    z-index: 5;
  }

  .terminal-button:hover {
    opacity: 1;
  }

  .theme-button {
    right: 55px;
  }

  .close-button {
    right: 10px;
  }

  .theme-dropdown {
    position: absolute;
    right: 10px;
    top: 45px;
    min-width: 200px;
    z-index: 5;
  }
</style>

<div style="position: relative;" class="h-100">
  <div bind:this={terminalContainer} class="h-100"></div>
  <button
    class="btn btn-secondary btn-sm terminal-button theme-button"
    type="button"
    bind:this={gearButtonRef}
    aria-haspopup="true"
    aria-expanded={showThemeMenu}
    aria-controls="terminal-theme-select"
    on:click={toggleThemeMenu}
  >
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <path
        d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Zm6.19-4.5a4.86 4.86 0 0 0 0-1l2-1.55a.38.38 0 0 0 .09-.49l-1.9-3.29a.38.38 0 0 0-.46-.17l-2.35.94a7.23 7.23 0 0 0-1.73-1l-.36-2.5a.38.38 0 0 0-.38-.32h-3.8a.38.38 0 0 0-.38.32l-.36 2.5a7.19 7.19 0 0 0-1.74 1l-2.34-.94a.38.38 0 0 0-.47.17L3.7 7.47a.38.38 0 0 0 .09.49l2 1.54a5.15 5.15 0 0 0 0 1l-2 1.55a.38.38 0 0 0-.09.49l1.9 3.29a.38.38 0 0 0 .46.18l2.35-1a7.29 7.29 0 0 0 1.74 1l.36 2.5a.38.38 0 0 0 .38.32h3.8a.38.38 0 0 0 .38-.32l.36-2.5a7.19 7.19 0 0 0 1.74-1l2.35 1a.38.38 0 0 0 .46-.18l1.9-3.29a.38.38 0 0 0-.09-.49l-2-1.55Z"
        fill="currentColor"
      />
    </svg>
    <span class="visually-hidden">Terminal appearance</span>
  </button>
  <button class="btn btn-secondary btn-sm terminal-button close-button" on:click={hide}>
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <line x1="6" y1="12" x2="18" y2="12" stroke="white" stroke-width="2" stroke-linecap="round" />
    </svg>
  </button>

  {#if showThemeMenu}
    <div class="dropdown-menu show theme-dropdown shadow p-3" bind:this={themeMenuRef}>
      <label for="terminal-theme-select" class="form-label mb-1 small fw-semibold">Terminal theme</label>
      <select
        id="terminal-theme-select"
        class="form-select form-select-sm"
        bind:value={selectedThemeKey}
        on:change={handleThemeChange}
        aria-label="Change terminal theme"
      >
        {#each themeOptions as [key, option]}
          <option value={key}>{option.label}</option>
        {/each}
      </select>
    </div>
  {/if}
</div>
