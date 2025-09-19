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

    <ul class="d-flex flex-column gap-4 text-start mb-4" style="list-style-type: decimal; padding-left: 20px;">
      <li>
        You don't have to use the built-in terminal in this website. You can connect to <b>hackerlab</b> with SSH
        directly from your favourite local terminal:
        <ul>
          <li>You can connect with a command <code>ssh root@127.0.0.1 -p 2222</code></li>
          <li>The user password is <code>ByteThem123</code></li>
        </ul>
      </li>

      <li>
        Your host machine has direct network access only to containers <b>hackerlab</b> and <b>dashboard</b> (this
        website). That means, you have to use hackerlab to access challenge containers. However, You might want to
        access some web services with your browser. To do that, you can proxy the traffic through hackerlab:

        <ul>
          <li>
            In the <b>hackerlab</b>, there is a Python script <code>~/proxy.py</code> that allows you to proxy the
            traffic through hackerlab. Run this script in hackerlab as follows:
            <code>python3 ~/proxy.py TARGET_SERVICE_IP TARGET_PORT</code>.
          </li>
          <li>
            You can then navigate to <a href="http://localhost:2223" target="_blank" rel="noreferrer"
              >http://localhost:2223</a
            > in your current browser to access the target web service!
          </li>
        </ul>
      </li>

      <li class="mb-2">
        Top right corner shows if you are running the latest version of StratoCyberLab. Latest version (main branch)
        from Github is fetched upon every website refresh. Follow the instructions in the pop-up to update to latest
        version.
      </li>
    </ul>

    <p class="fw-bold">Happy hacking!</p>
  </div>
</div>
