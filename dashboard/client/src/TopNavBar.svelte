<script>
  import VersionStatus from './components/VersionStatus.svelte';
  import { navigate } from './routing';
  import { Sparkles } from 'svelte-heros';

  function handleBrandClick() {
    navigate('');
  }
</script>

<nav aria-label="Top" class="bg-light border-bottom">
  <div class="container-fluid py-2">
    <div class="d-flex align-items-center justify-content-between">
      <!-- Left: brand -->
      <a
        href="/#"
        class="d-inline-flex align-items-center text-body text-decoration-none ms-2"
        on:click|preventDefault={handleBrandClick}
      >
        <img src="/media/logo.png" alt="Logo" width="30" height="30" class="me-2" />
        <span class="fw-semibold">StratoCyberLab</span>
      </a>

      <!-- Right: tips + divider + version -->
      <div class="d-inline-flex align-items-center gap-2">
        <a type="button" class="btn tips-btn d-inline-flex align-items-center gap-2 px-3 py-1" href="#tips-and-tricks">
          <Sparkles width="18" height="18" aria-hidden="true" />
          <span>Tips &amp; Tricks</span>
        </a>

        <!-- slim divider -->
        <div class="vr opacity-50"></div>

        <VersionStatus />
      </div>
    </div>
  </div>
</nav>
