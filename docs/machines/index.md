---
title: Todas las máquinas
hide:
  - navigation
  - toc
---

<main class="machines-page">

  <header class="page-heading">
    <h1>Todas las máquinas</h1>
    <p>Explora todos los laboratorios que he resuelto y documentado.</p>
  </header>

  <section class="machine-filters" aria-label="Filtros del catálogo">

    <label class="select-control">
      <span class="sr-only">Plataforma</span>
      <select id="platform-filter">
        <option value="">Todas las plataformas</option>
      </select>
    </label>

    <label class="select-control">
      <span class="sr-only">Dificultad</span>
      <select id="difficulty-filter">
        <option value="">Todas las dificultades</option>
      </select>
    </label>

    <label class="select-control">
      <span class="sr-only">Sistema operativo</span>
      <select id="os-filter">
        <option value="">Todos los sistemas</option>
      </select>
    </label>

    <label class="catalog-search">
      <span class="catalog-search-icon" aria-hidden="true"></span>
      <input
        id="machine-search"
        type="search"
        placeholder="Buscar máquinas..."
        autocomplete="off"
      >
    </label>

  </section>

  <section class="machine-list" id="machines-list">
    <div class="loading-card">Cargando máquinas...</div>
  </section>

  <p class="result-count">
    Mostrando
    <strong id="visible-machines">0</strong>
    de
    <strong id="total-machines">0</strong>
    máquinas
  </p>

</main>