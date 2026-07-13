---
title: Todas las máquinas
hide:
  - navigation
  - toc
---

<div class="machines-page">

  <header class="machines-page-header">
    <p class="section-eyebrow">Portafolio técnico</p>
    <h1>Todas las máquinas</h1>

    <p>
      Catálogo de máquinas resueltas y documentadas durante mi
      aprendizaje de ciberseguridad.
    </p>
  </header>

  <section class="machines-toolbar">

    <div class="machines-filter">
      <span>Plataforma</span>
      <strong>DockerLabs</strong>
    </div>

    <div class="machines-filter">
      <span>Dificultad</span>
      <strong>Very Easy</strong>
    </div>

    <div class="machines-filter">
      <span>Sistema</span>
      <strong>Linux</strong>
    </div>

    <div class="machines-search">
      <span>⌕</span>
      <input
        type="search"
        id="machine-search"
        placeholder="Buscar máquina..."
        autocomplete="off"
      >
    </div>

  </section>

  <section class="all-machines-list" id="machines-list">

    <a
      class="machine-list-card"
      data-machine="borazuwarahctf dockerlabs linux nmap ssh esteganografia"
      href="../dockerlabs/very-easy/borazuwarahctf/"
    >
      <div class="machine-list-icon">B</div>

      <div class="machine-list-information">
        <h2>BorazuwarahCTF</h2>
        <p>DockerLabs</p>
      </div>

      <div class="machine-list-details">
        <span class="difficulty-badge">Very Easy</span>
        <small>Linux</small>
      </div>

      <span class="machine-list-arrow">›</span>
    </a>

    <a
      class="machine-list-card"
      data-machine="breakmyssh dockerlabs linux nmap ssh hydra fuerza bruta"
      href="../dockerlabs/very-easy/breakmyssh/"
    >
      <div class="machine-list-icon">B</div>

      <div class="machine-list-information">
        <h2>BreakMySsh</h2>
        <p>DockerLabs</p>
      </div>

      <div class="machine-list-details">
        <span class="difficulty-badge">Very Easy</span>
        <small>Linux</small>
      </div>

      <span class="machine-list-arrow">›</span>
    </a>

    <a
      class="machine-list-card"
      data-machine="firsthacking dockerlabs linux reconocimiento enumeracion"
      href="../dockerlabs/very-easy/firsthacking/"
    >
      <div class="machine-list-icon">F</div>

      <div class="machine-list-information">
        <h2>FirstHacking</h2>
        <p>DockerLabs</p>
      </div>

      <div class="machine-list-details">
        <span class="difficulty-badge">Very Easy</span>
        <small>Linux</small>
      </div>

      <span class="machine-list-arrow">›</span>
    </a>

    <a
      class="machine-list-card"
      data-machine="hedgehog dockerlabs linux nmap escalada privilegios"
      href="../dockerlabs/very-easy/hedgehog/"
    >
      <div class="machine-list-icon">H</div>

      <div class="machine-list-information">
        <h2>HedgeHog</h2>
        <p>DockerLabs</p>
      </div>

      <div class="machine-list-details">
        <span class="difficulty-badge">Very Easy</span>
        <small>Linux</small>
      </div>

      <span class="machine-list-arrow">›</span>
    </a>

    <a
      class="machine-list-card"
      data-machine="trust dockerlabs linux ssh enumeracion"
      href="../dockerlabs/very-easy/trust/"
    >
      <div class="machine-list-icon">T</div>

      <div class="machine-list-information">
        <h2>Trust</h2>
        <p>DockerLabs</p>
      </div>

      <div class="machine-list-details">
        <span class="difficulty-badge">Very Easy</span>
        <small>Linux</small>
      </div>

      <span class="machine-list-arrow">›</span>
    </a>

    <a
      class="machine-list-card"
      data-machine="vacaciones dockerlabs linux nmap web escalada privilegios"
      href="../dockerlabs/very-easy/vacaciones/"
    >
      <div class="machine-list-icon">V</div>

      <div class="machine-list-information">
        <h2>Vacaciones</h2>
        <p>DockerLabs</p>
      </div>

      <div class="machine-list-details">
        <span class="difficulty-badge">Very Easy</span>
        <small>Linux</small>
      </div>

      <span class="machine-list-arrow">›</span>
    </a>

  </section>

  <p class="machines-result-count">
    Mostrando <strong id="visible-machines">6</strong> de 6 máquinas
  </p>

</div>

<script>
document.addEventListener("DOMContentLoaded", function () {
    const searchInput = document.getElementById("machine-search");
    const machineCards = document.querySelectorAll(".machine-list-card");
    const visibleCounter = document.getElementById("visible-machines");

    if (!searchInput || !visibleCounter) {
        return;
    }

    searchInput.addEventListener("input", function () {
        const searchValue = this.value.toLowerCase().trim();
        let visibleMachines = 0;

        machineCards.forEach(function (card) {
            const searchableContent =
                card.dataset.machine.toLowerCase() +
                " " +
                card.textContent.toLowerCase();

            const shouldShow = searchableContent.includes(searchValue);

            card.hidden = !shouldShow;

            if (shouldShow) {
                visibleMachines++;
            }
        });

        visibleCounter.textContent = visibleMachines;
    });
});
</script>
