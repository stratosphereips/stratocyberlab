<script>
  import { Sparkles } from 'svelte-heros';
</script>

<div class="d-flex justify-content-center pt-5">
  <div class="shadow p-3 mb-5 bg-body rounded text-center" style="max-width: 700px;">
    <h4 class="mb-3 gap-1">
      <Sparkles />
      <span>Tips & Tricks</span>
      <Sparkles />
    </h4>

    <ol class="d-flex flex-column gap-4 text-start mb-4 ps-4">
      <li>
        The built-in terminal is optional. You can connect to <strong>HackerLab</strong> from a terminal on your host
        computer instead:
        <ul class="mt-2">
          <li>Run <code>ssh root@127.0.0.1 -p 2222</code>.</li>
          <li>When asked, enter the password <code>ByteThem123</code>.</li>
        </ul>
      </li>

      <li>
        Exercise services are normally available only inside the private lab network. If an exercise contains a web
        service that you want to open in your normal browser, send the browser traffic through HackerLab:

        <ul class="mt-2">
          <li>
            In the HackerLab terminal, run
            <code>python3 ~/proxy.py TARGET_SERVICE_IP TARGET_PORT</code>. Replace the target address and port with the
            values from the exercise.
          </li>
          <li>
            While the proxy is running, open <a href="http://localhost:2223" target="_blank" rel="noreferrer"
              >http://localhost:2223</a
            > in your browser.
          </li>
        </ul>
      </li>
    </ol>

    <p class="fw-bold">Happy hacking!</p>
  </div>
</div>
