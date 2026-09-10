<script>
  import { BookOpen } from 'svelte-heros';
</script>

<style>
  .page-card {
    max-width: 860px;
  }

  .flow {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr) auto minmax(0, 1fr);
    align-items: stretch;
    gap: 0.75rem;
  }

  .flow-step {
    display: flex;
    flex-direction: column;
    justify-content: center;
    min-height: 105px;
  }

  .flow-arrow {
    align-self: center;
    color: var(--bs-secondary-color);
    font-size: 1.5rem;
  }

  summary {
    cursor: pointer;
  }

  @media (max-width: 767.98px) {
    .flow {
      grid-template-columns: 1fr;
    }

    .flow-arrow {
      transform: rotate(90deg);
    }
  }
</style>

<div class="d-flex justify-content-center pt-5">
  <article class="page-card shadow p-4 mb-5 bg-body rounded">
    <header class="text-center mb-5">
      <h3 class="d-flex align-items-center justify-content-center gap-2 mb-2">
        <BookOpen aria-hidden="true" />
        <span>How StratoCyberLab works</span>
      </h3>
    </header>

    <section class="mb-5">
      <h4>First, what is a cyber range?</h4>
      <p>
        A cyber range is a practice environment for cybersecurity. StratoCyberLab runs locally on your
        computer. It's a system where you can inspect, attack, defend and learn.
      </p>
      <p class="mb-0">
        Most parts run in <strong>Docker containers</strong>. A container is a small, separated environment with its own
        programs and network connection. Some exercise containers are intentionally vulnerable because finding and
        understanding the weakness is part of the lesson.
      </p>
    </section>

    <section class="mb-5">
      <h4 class="mb-3">The main parts</h4>
      <dl class="row mb-0">
        <dt class="col-md-3">Dashboard</dt>
        <dd class="col-md-9">
          The web page you are using now. It shows the learning content, allows starting services and has a built-in shell to Hackerlab.
        </dd>

        <dt class="col-md-3">HackerLab</dt>
        <dd class="col-md-9">
          Your lab workstation. The terminal at the bottom connects to this container. Use Hackerlab to learn and solve challenges.
        </dd>

        <dt class="col-md-3">Exercise services</dt>
        <dd class="col-md-9">
          The target containers for a challenge, campaign, or class. An environment may contain a web server, a
          database, another computer, or a network of more systems.
        </dd>

        <dt class="col-md-3">AI Assistant</dt>
        <dd class="col-md-9 mb-0">
          The optional local service using local Ollama container - the data stays yours.
        </dd>
      </dl>
    </section>

    <section class="mb-5">
      <h4>What happens when you try to solve a challenge?</h4>
      <ol class="ps-4 d-flex flex-column gap-2">
        <li>You choose a challenge and press its start button.</li>
        <li>The Dashboard asks Docker to create and start the challenge containers.</li>
        <li>The new containers join a network shared with your Hackerlab.</li>
        <li>You use HackerLab to connect to the target service and investigate it.</li>
        <li>You find a flag and submit it in the Dashboard. The Dashboard checks your answer.</li>
        <li>When you stop the challenge, Docker removes its running containers.</li>
      </ol>
      <p class="mb-0">
        Starting an environment may take a moment. Docker may need to build or download an image the first time.
      </p>
    </section>

    <section class="mb-5">
      <h4 class="mb-3">What can you open from the left menu?</h4>
      <dl class="row mb-0">
        <dt class="col-md-3">Challenges</dt>
        <dd class="col-md-9">Standalone Capture the Flag exercises. Each task asks you to find and submit a flag.</dd>

        <dt class="col-md-3">Campaigns</dt>
        <dd class="col-md-9">A set of challenges with a story. You advance in a story by solving the challenges.</dd>

        <dt class="col-md-3">Classes</dt>
        <dd class="col-md-9">Educational materials for <a href="https://cybersecurity.bsy.fel.cvut.cz/" target="_blank">Introduction to security</a> course with its optional environment to play with.</dd>

        <dt class="col-md-3">Plugins</dt>
        <dd class="col-md-9 mb-0">Optional third-party applications that add features to StratoCyberLab. Use only plugins from sources you fully trust.</dd>
      </dl>
      <div class="alert alert-warning mb-0 mt-3" role="note">
        <strong>Keep the SCL private.</strong> Do not expose it to the internet. Exercise services can be unsafe on purpose.
        Only install plugins that you trust, because a plugin may have powerful access to Docker and your host computer.
      </div>
    </section>

    <section class="mb-4">
      <h4>Useful beginner terms</h4>
      <div class="d-flex flex-column gap-2">
        <details class="border rounded p-3">
          <summary class="fw-semibold">Host, container, and image</summary>
          <p class="mt-3 mb-0">
            The <strong>host</strong> is your real computer. A <strong>container</strong> is a running, separated
            environment on that computer. An <strong>image</strong> is the saved template Docker uses to create a container.
          </p>
        </details>

        <details class="border rounded p-3">
          <summary class="fw-semibold">IP address and port</summary>
          <p class="mt-3 mb-0">
            An <strong>IP address</strong> identifies a device or container on a network. A <strong>port</strong>
            identifies a service on it, such as a website or SSH server. Sometimes, exercise instructions tell you which address and
            port to use.
          </p>
        </details>

        <details class="border rounded p-3">
          <summary class="fw-semibold">Flag</summary>
          <p class="mt-3 mb-0">
            A flag is a short secret string that proves you completed a task. Unless an exercise says otherwise,
            StratoCyberLab flags look like <code>BSY&#123;...&#125;</code>.
          </p>
        </details>
      </div>
    </section>

    <footer class="text-center border-top pt-4">
      <p class="mb-2">Ready to try it?</p>
      <a class="btn btn-primary me-1" href="#challenge/hello-world">Open Hello World challenge</a>
      <a class="btn btn-outline-secondary" href="#tips-and-tricks">Read Tips &amp; Tricks</a>
    </footer>
  </article>
</div>
