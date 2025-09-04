<script>
import VersionStatus from "./components/VersionStatus.svelte";
import {navigate} from "./routing";

function handleBrandClick() {
    navigate('');
}

</script>

<nav aria-label="Top" class="bg-light border-bottom mb-2">
<div class="container-fluid py-2">
  <div class="d-flex align-items-center justify-content-between">

    <!-- Left: brand -->
    <a
      href="/#"
      class="d-inline-flex align-items-center text-body text-decoration-none ms-2"
      on:click|preventDefault={handleBrandClick}
    >
      <img
        src="/media/logo.png"
        alt="Logo"
        width="30"
        height="30"
        class="me-2"
      />
      <span class="fw-semibold">StratoCyberLab</span>
    </a>

    <!-- Right: status + (optional) toggle -->
    <div class="d-inline-flex align-items-center gap-2">
      <VersionStatus />
    </div>

  </div>
</div>
</nav>