const SITE_SCRIPT_URL = new URL(document.currentScript.src);
const BASE_URL = new URL("../", SITE_SCRIPT_URL);
const DATA_URL = new URL("../assets/data/machines.json", SITE_SCRIPT_URL);
const SKULL_URL = new URL("../assets/images/skull-mark.svg", SITE_SCRIPT_URL);
const LINUX_ICON_URL = new URL("../assets/images/linux-machine.svg", SITE_SCRIPT_URL);

let machineDataPromise = null;

function loadMachines() {
  if (!machineDataPromise) {
    machineDataPromise = fetch(DATA_URL)
      .then((response) => {
        if (!response.ok) {
          throw new Error(`No se pudo cargar machines.json: ${response.status}`);
        }

        return response.json();
      });
  }

  return machineDataPromise;
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function svgIcon(name) {
  const icons = {
    search: `
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <path d="m21 21-4.35-4.35m2.35-5.65a8 8 0 1 1-16 0 8 8 0 0 1 16 0Z"
          fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
      </svg>
    `,
    github: `
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <path d="M12 .7a11.6 11.6 0 0 0-3.7 22.6c.6.1.8-.3.8-.6v-2.3c-3.4.7-4.1-1.4-4.1-1.4-.5-1.4-1.4-1.8-1.4-1.8-1.1-.8.1-.8.1-.8 1.3.1 1.9 1.3 1.9 1.3 1.1 1.9 2.9 1.4 3.6 1.1.1-.8.4-1.4.8-1.7-2.7-.3-5.5-1.3-5.5-5.9 0-1.3.5-2.4 1.2-3.2-.1-.3-.5-1.6.1-3.2 0 0 1-.3 3.3 1.2a11.3 11.3 0 0 1 6 0C16.6 4.5 17.6 4.8 17.6 4.8c.6 1.6.2 2.9.1 3.2.8.8 1.2 1.9 1.2 3.2 0 4.6-2.8 5.6-5.5 5.9.5.4.9 1.2.9 2.3v3.3c0 .3.2.7.8.6A11.6 11.6 0 0 0 12 .7Z"/>
      </svg>
    `,
    menu: `
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <path d="M4 7h16M4 12h16M4 17h16"
          fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
      </svg>
    `,
    contrast: `
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <circle cx="12" cy="12" r="8"/>
        <path d="M12 4v16"/>
      </svg>
    `,
    machines: `
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <path d="M4 5h16v11H4zM8 20h8M12 16v4"/>
      </svg>
    `,
    platforms: `
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <path d="M5 7h14v10H5zM2 10h3M19 10h3M9 4v3M15 4v3M9 17v3M15 17v3"/>
      </svg>
    `,
    linux: `
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <path d="M8 19c-2-1-3-3-3-6 0-5 3-9 7-9s7 4 7 9c0 3-1 5-3 6M8 19h8M9 9h.01M15 9h.01M10 13h4"/>
      </svg>
    `,
    techniques: `
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <path d="m5 5 14 14M15 5l4 4-3 3M5 15l4 4 3-3M9 3 3 9l4 4 6-6zM15 11l6 6-4 4-6-6z"/>
      </svg>
    `
  };

  return icons[name] ?? "";
}

function pagePath(path) {
  return new URL(path, BASE_URL).href;
}

function initHeader() {
  const headerInner = document.querySelector(".md-header__inner");

  if (!headerInner) {
    return;
  }

  const currentPath = window.location.pathname.toLowerCase();

  const navItems = [
    { label: "Inicio", path: "" },
    { label: "Máquinas", path: "machines/" },
    { label: "Plataformas", path: "platforms/" },
    { label: "Sobre mí", path: "about/" }
  ];

  const navHtml = navItems
    .map((item) => {
      const target = new URL(item.path, BASE_URL);
      const targetPath = target.pathname.toLowerCase();

      const isActive =
        item.path === ""
          ? currentPath === targetPath
          : currentPath.startsWith(targetPath);

      return `
        <a class="${isActive ? "is-active" : ""}" href="${target.href}">
          ${escapeHtml(item.label)}
        </a>
      `;
    })
    .join("");

  headerInner.innerHTML = `
    <div class="site-header-shell">
      <a class="site-brand" href="${BASE_URL.href}">
        <img src="${SKULL_URL.href}" alt="">
        <span>MACHINES</span>
      </a>

      <nav class="site-nav" id="site-nav" aria-label="Navegación principal">
        ${navHtml}
      </nav>

      <div class="site-header-actions">
        <label
          class="site-icon-button"
          for="__search"
          aria-label="Buscar en el sitio"
          title="Buscar"
        >
          ${svgIcon("search")}
        </label>

        <a
          class="site-icon-button github-header-link"
          href="https://github.com/Gaabooox/Machines"
          target="_blank"
          rel="noopener"
          aria-label="Abrir GitHub"
          title="GitHub"
        >
          ${svgIcon("github")}
        </a>

        <button
          class="site-icon-button contrast-button"
          type="button"
          aria-label="Alternar contraste"
          title="Alternar contraste"
        >
          ${svgIcon("contrast")}
        </button>

        <button
          class="mobile-menu-button"
          type="button"
          aria-controls="site-nav"
          aria-expanded="false"
          aria-label="Abrir menú"
        >
          ${svgIcon("menu")}
        </button>
      </div>
    </div>
  `;

  const navigation = headerInner.querySelector("#site-nav");
  const menuButton = headerInner.querySelector(".mobile-menu-button");
  const contrastButton = headerInner.querySelector(".contrast-button");

  menuButton?.addEventListener("click", () => {
    const isOpen = navigation.classList.toggle("is-open");
    menuButton.setAttribute("aria-expanded", String(isOpen));
  });

  contrastButton?.addEventListener("click", () => {
    document.body.classList.toggle("high-contrast");
  });

  navigation?.addEventListener("click", () => {
    navigation.classList.remove("is-open");
    menuButton?.setAttribute("aria-expanded", "false");
  });
}

function fillStatIcons() {
  document.querySelectorAll("[data-stat-icon]").forEach((element) => {
    element.innerHTML = svgIcon(element.dataset.statIcon);
  });
}

function createRecentCard(machine) {
  return `
    <a class="recent-machine-card" href="${pagePath(machine.path)}">
      <img class="machine-avatar" src="${LINUX_ICON_URL.href}" alt="">
      <div>
        <h3>${escapeHtml(machine.name)}</h3>
        <span class="difficulty-badge">${escapeHtml(machine.difficulty)}</span>
        <p class="recent-machine-meta">${escapeHtml(machine.platform)}</p>
      </div>
    </a>
  `;
}

async function initHome() {
  const recentContainer = document.querySelector("#recent-machines");

  if (!recentContainer) {
    return;
  }

  try {
    const machines = await loadMachines();

    const platforms = new Set(
      machines.map((machine) => machine.platformSlug || machine.platform)
    );

    const linuxMachines = machines.filter(
      (machine) => String(machine.operatingSystem).toLowerCase() === "linux"
    );

    const techniques = new Set(
      machines.flatMap((machine) => Array.isArray(machine.tags) ? machine.tags : [])
    );

    document.querySelector("#stat-machines").textContent = machines.length;
    document.querySelector("#stat-platforms").textContent = platforms.size;
    document.querySelector("#stat-linux").textContent = linuxMachines.length;
    document.querySelector("#stat-techniques").textContent = techniques.size;

    recentContainer.innerHTML = machines
      .slice(-4)
      .reverse()
      .map(createRecentCard)
      .join("");
  } catch (error) {
    console.error(error);
    recentContainer.innerHTML = `
      <div class="empty-state">No se pudieron cargar las máquinas recientes.</div>
    `;
  }
}

function addSelectOptions(select, values, labelFunction = (value) => value) {
  [...new Set(values.filter(Boolean))]
    .sort((a, b) => String(a).localeCompare(String(b)))
    .forEach((value) => {
      const option = document.createElement("option");
      option.value = String(value);
      option.textContent = labelFunction(value);
      select.appendChild(option);
    });
}

function createMachineRow(machine) {
  return `
    <a class="machine-row" href="${pagePath(machine.path)}">
      <img class="machine-avatar" src="${LINUX_ICON_URL.href}" alt="">

      <div>
        <h2>${escapeHtml(machine.name)}</h2>
        <p class="machine-row-platform">${escapeHtml(machine.platform)}</p>
      </div>

      <div class="machine-row-details">
        <span class="difficulty-badge">${escapeHtml(machine.difficulty)}</span>
        <small>${escapeHtml(machine.operatingSystem)}</small>
      </div>

      <span class="machine-row-arrow" aria-hidden="true">›</span>
    </a>
  `;
}

async function initMachinesCatalog() {
  const list = document.querySelector("#machines-list");

  if (!list) {
    return;
  }

  const platformFilter = document.querySelector("#platform-filter");
  const difficultyFilter = document.querySelector("#difficulty-filter");
  const osFilter = document.querySelector("#os-filter");
  const searchInput = document.querySelector("#machine-search");
  const visibleCounter = document.querySelector("#visible-machines");
  const totalCounter = document.querySelector("#total-machines");

  try {
    const machines = await loadMachines();

    addSelectOptions(
      platformFilter,
      machines.map((machine) => machine.platform)
    );

    addSelectOptions(
      difficultyFilter,
      machines.map((machine) => machine.difficulty)
    );

    addSelectOptions(
      osFilter,
      machines.map((machine) => machine.operatingSystem)
    );

    const requestedPlatform = new URLSearchParams(
      window.location.search
    ).get("platform");

    if (requestedPlatform) {
      const matchingMachine = machines.find(
        (machine) => machine.platformSlug === requestedPlatform
      );

      if (matchingMachine) {
        platformFilter.value = matchingMachine.platform;
      }
    }

    totalCounter.textContent = machines.length;

    const render = () => {
      const platformValue = platformFilter.value;
      const difficultyValue = difficultyFilter.value;
      const osValue = osFilter.value;
      const searchValue = searchInput.value.trim().toLowerCase();

      const filtered = machines.filter((machine) => {
        const matchesPlatform =
          !platformValue || machine.platform === platformValue;

        const matchesDifficulty =
          !difficultyValue || machine.difficulty === difficultyValue;

        const matchesOs =
          !osValue || machine.operatingSystem === osValue;

        const searchable = [
          machine.name,
          machine.platform,
          machine.difficulty,
          machine.operatingSystem,
          machine.summary,
          ...(machine.tags || [])
        ]
          .join(" ")
          .toLowerCase();

        const matchesSearch =
          !searchValue || searchable.includes(searchValue);

        return (
          matchesPlatform &&
          matchesDifficulty &&
          matchesOs &&
          matchesSearch
        );
      });

      visibleCounter.textContent = filtered.length;

      list.innerHTML = filtered.length
        ? filtered.map(createMachineRow).join("")
        : `<div class="empty-state">No se encontraron máquinas con esos filtros.</div>`;
    };

    [platformFilter, difficultyFilter, osFilter].forEach((control) => {
      control.addEventListener("change", render);
    });

    searchInput.addEventListener("input", render);
    render();
  } catch (error) {
    console.error(error);
    list.innerHTML = `
      <div class="empty-state">No se pudo cargar el catálogo.</div>
    `;
  }
}

async function initPlatforms() {
  const grid = document.querySelector("#platform-grid");

  if (!grid) {
    return;
  }

  try {
    const machines = await loadMachines();

    const platformMap = new Map();

    machines.forEach((machine) => {
      const key = machine.platformSlug || machine.platform;

      if (!platformMap.has(key)) {
        platformMap.set(key, {
          name: machine.platform,
          count: 0
        });
      }

      platformMap.get(key).count += 1;
    });

    const plannedPlatforms = [
      { key: "dockerlabs", name: "DockerLabs" },
      { key: "hackthebox", name: "Hack The Box" },
      { key: "tryhackme", name: "TryHackMe" }
    ];

    grid.innerHTML = plannedPlatforms
      .map((platform) => {
        const data = platformMap.get(platform.key);
        const count = data?.count ?? 0;
        const enabled = count > 0;

        return `
          <a
            class="platform-card ${enabled ? "" : "is-disabled"}"
            href="${enabled ? pagePath(`machines/?platform=${platform.key}`) : "#"}"
            ${enabled ? "" : 'aria-disabled="true"'}
          >
            <strong>${count}</strong>
            <h2>${escapeHtml(platform.name)}</h2>
            <p>
              ${enabled
                ? `${count} writeup${count === 1 ? "" : "s"} publicado${count === 1 ? "" : "s"}.`
                : "Se añadirá contenido próximamente."}
            </p>
          </a>
        `;
      })
      .join("");
  } catch (error) {
    console.error(error);
    grid.innerHTML = `<div class="empty-state">No se pudieron cargar las plataformas.</div>`;
  }
}

function ensureHeadingIds(headings) {
  headings.forEach((heading, index) => {
    if (!heading.id) {
      heading.id = `section-${index + 1}`;
    }
  });
}

function initWriteup() {
  const intro = document.querySelector(".writeup-intro");

  if (!intro) {
    return;
  }

  document.body.classList.add("page-writeup");

  const contentInner = document.querySelector(".md-content__inner");

  if (!contentInner) {
    return;
  }

  const children = [...contentInner.children];
  const center = document.createElement("article");
  center.className = "writeup-center";

  children.forEach((child) => center.appendChild(child));

  const headings = [...center.querySelectorAll("h2, h3")];
  ensureHeadingIds(headings);

  const leftNavigation = document.createElement("aside");
  leftNavigation.className = "writeup-left-nav";
  leftNavigation.innerHTML = `
    <h2>En esta página</h2>
    <nav>
      ${headings
        .map((heading) => `
          <a
            class="level-${heading.tagName === "H3" ? "3" : "2"}"
            href="#${escapeHtml(heading.id)}"
          >
            ${escapeHtml(heading.textContent.trim())}
          </a>
        `)
        .join("")}
    </nav>
  `;

  const techniques = String(intro.dataset.techniques || "")
    .split("|")
    .map((value) => value.trim())
    .filter(Boolean);

  const infoRows = [
    ["Plataforma", intro.dataset.platform],
    ["Dificultad", intro.dataset.difficulty, true],
    ["Sistema", intro.dataset.os],
    ["Acceso inicial", intro.dataset.access],
    ["Escalada", intro.dataset.escalation],
    ["Estado", intro.dataset.status]
  ];

  const rightSidebar = document.createElement("aside");
  rightSidebar.className = "writeup-right-sidebar";
  rightSidebar.innerHTML = `
    <section class="machine-info-card">
      <h2>Información</h2>

      ${infoRows
        .map(([label, value, green]) => `
          <div class="machine-info-row">
            <span>${escapeHtml(label)}</span>
            <strong class="${green ? "green-value" : ""}">
              ${escapeHtml(value || "—")}
            </strong>
          </div>
        `)
        .join("")}
    </section>

    <section class="techniques-card">
      <h2>Técnicas</h2>

      <div class="technique-list">
        ${techniques
          .map((technique) => `<span>${escapeHtml(technique)}</span>`)
          .join("")}
      </div>
    </section>
  `;

  const layout = document.createElement("div");
  layout.className = "writeup-layout-grid";
  layout.append(leftNavigation, center, rightSidebar);
  contentInner.appendChild(layout);

  const links = [...leftNavigation.querySelectorAll("a")];
  const headingById = new Map(headings.map((heading) => [heading.id, heading]));

  links.forEach((link) => {
    link.addEventListener("click", () => {
      links.forEach((item) => item.classList.remove("is-active"));
      link.classList.add("is-active");
    });
  });

  const observer = new IntersectionObserver(
    (entries) => {
      const visible = entries
        .filter((entry) => entry.isIntersecting)
        .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);

      if (!visible.length) {
        return;
      }

      const activeId = visible[0].target.id;

      links.forEach((link) => {
        link.classList.toggle(
          "is-active",
          link.getAttribute("href") === `#${activeId}`
        );
      });
    },
    {
      rootMargin: "-15% 0px -72% 0px",
      threshold: 0
    }
  );

  headingById.forEach((heading) => observer.observe(heading));
}

document.addEventListener("DOMContentLoaded", () => {
  initHeader();
  fillStatIcons();
  initHome();
  initMachinesCatalog();
  initPlatforms();
  initWriteup();
});


