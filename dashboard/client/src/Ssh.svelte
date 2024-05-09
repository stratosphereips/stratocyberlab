<script>
    import {onDestroy, onMount} from 'svelte';
    import { createEventDispatcher } from 'svelte'

    import {Terminal} from '@xterm/xterm'
    import {FitAddon} from '@xterm/addon-fit';
    import '@xterm/xterm/css/xterm.css';
    import {io} from 'socket.io-client';

    const dispatch = createEventDispatcher()

    let terminalContainer;
    let terminal;
    let ws;


    onMount(() => {
        terminal = new Terminal({
            cursorBlink: true,
        });
        const fitAddon = new FitAddon();
        terminal.loadAddon(fitAddon);
        terminal.open(terminalContainer);
        fitAddon.fit();

        function emitTerminalSize() {
            socket.emit('ssh_resize', {
                "cols": terminal.cols,
                "rows": terminal.rows
            });
        }

        // Whenever resize happens, we dynamically resize size of terminal
        // and send the information to the server as-well
        window.addEventListener('resize', () => {
            fitAddon.fit()
            emitTerminalSize()
        });

        const socket = io(`ws://${window.location.host}`, {
            path: '/socket.io',
            transports: ['websocket']
        });

        socket.on('connect', () => {
            emitTerminalSize()
        });

        socket.on('ssh_output', (data) => {
            terminal.write(data);
        });

        terminal.onData(data => {
            socket.emit('ssh_input', data);
        });
    });


  onDestroy(() => {
    if (terminal) {
      terminal.dispose();
    }
    if (ws) {
      ws.close();
    }
  });

  function hide(){
      dispatch("hide")
  }

</script>

<style>
    .close-button {
        position: absolute;
        right: 10px;
        top: 10px;
        opacity: 0.5;
        transition: opacity 0.3s ease;
    }

    .close-button:hover {
        opacity: 1;
    }
</style>


<div style="position: relative;" class="h-100">
    <div bind:this={terminalContainer} class="h-100"></div>
    <button class="btn btn-danger close-button" on:click={hide}>
        X
    </button>
</div>