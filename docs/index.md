---
title: Inicio
hide:
  - navigation
  - toc
---

<main class="home-page">

  <section class="home-hero home-hero-terminal">

    <div class="home-hero-copy">
      <p class="page-kicker">Hola, soy</p>

      <h1>Gabriel Saavedra</h1>

      <p class="home-role">
        Estudiante de sistemas y ciberseguridad
      </p>

      <p class="home-summary">
        Documento las máquinas que resuelvo, las técnicas utilizadas,
        los errores encontrados y el proceso seguido hasta obtener
        acceso y escalar privilegios.
      </p>

      <div class="button-row">
        <a class="button button-light" href="machines/">
          Ver máquinas
        </a>

        <a
          class="button button-outline"
          href="https://github.com/Gaabooox/Machines"
          target="_blank"
          rel="noopener"
        >
          Ver GitHub
        </a>
      </div>
    </div>

    <div class="home-terminal">

      <div class="home-terminal-header">

        <div class="home-terminal-controls">
          <span></span>
          <span></span>
          <span></span>
        </div>

        <p>gabriel@machines:~</p>

      </div>

      <div class="home-terminal-content">

        <p>
          <span class="terminal-command">$</span>
          whoami
        </p>

        <p class="terminal-output">
          Gabriel Saavedra
        </p>

        <p>
          <span class="terminal-command">$</span>
          cat profile.txt
        </p>

        <div class="terminal-profile">
          <span>role:</span>
          <strong>Systems student</strong>

          <span>focus:</span>
          <strong>Cybersecurity enthusiast</strong>

          <span>environment:</span>
          <strong>Linux user</strong>

          <span>content:</span>
          <strong>Machine writeups</strong>
        </div>

        <p class="terminal-last-line">
          <span class="terminal-command">$</span>
          ./solve-machine.sh
          <span class="terminal-cursor">|</span>
        </p>

      </div>

    </div>

  </section>

  <section class="stats-grid" aria-label="Estadísticas del portafolio">

    <article class="stat-card">
      <span class="stat-icon" data-stat-icon="machines"></span>
      <strong id="stat-machines">0</strong>
      <span>Máquinas<br>resueltas</span>
    </article>

    <article class="stat-card">
      <span class="stat-icon" data-stat-icon="platforms"></span>
      <strong id="stat-platforms">0</strong>
      <span>Plataformas</span>
    </article>

    <article class="stat-card">
      <span class="stat-icon" data-stat-icon="linux"></span>
      <strong id="stat-linux">0</strong>
      <span>Máquinas<br>Linux</span>
    </article>

    <article class="stat-card">
      <span class="stat-icon" data-stat-icon="techniques"></span>
      <strong id="stat-techniques">0</strong>
      <span>Técnicas<br>utilizadas</span>
    </article>

  </section>

  <section class="recent-section">

    <div class="section-heading-row">
      <h2>Máquinas recientes</h2>

      <a href="machines/">
        Ver todas
        <span aria-hidden="true">→</span>
      </a>
    </div>

    <div class="recent-grid" id="recent-machines">
      <div class="loading-card">Cargando máquinas...</div>
    </div>

  </section>

</main>