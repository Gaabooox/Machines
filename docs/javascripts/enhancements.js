const UI_SCRIPT_URL = new URL(document.currentScript.src);
const UI_BASE_URL = new URL("../", UI_SCRIPT_URL);
const UI_DATA_URL = new URL("../assets/data/", UI_SCRIPT_URL);

const uiCache = new Map();

function uiLoadJson(fileName) {
  if (!uiCache.has(fileName)) {
    uiCache.set(
      fileName,
      fetch(new URL(fileName, UI_DATA_URL)).then((response) => {
        if (!response.ok) {
          throw new Error(`${fileName}: ${response.status}`);
        }

        return response.json();
      })
    );
  }

  return uiCache.get(fileName);
}

function uiUrl(path) {
  return new URL(path, UI_BASE_URL).href;
}

function uiEscape(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function uiNormalize(value) {
  return String(value ?? "")
    .normalize("NFD")
    .replace(/\p{Diacritic}/gu, "")
    .toLowerCase()
    .trim();
}

function getStoredTheme() {
  const saved = localStorage.getItem("machines-theme");

  if (saved === "light" || saved === "dark") {
    return saved;
  }

  return "dark";
}

function applyTheme(theme) {
  document.documentElement.dataset.siteTheme = theme;
  document.body.dataset.siteTheme = theme;
  localStorage.setItem("machines-theme", theme);

  const button = document.querySelector(".portfolio-theme-toggle");

  if (!button) {
    return;
  }

  const nextTheme = theme === "dark" ? "light" : "dark";
  button.textContent = theme === "dark" ? "☀" : "◐";
  button.setAttribute(
    "aria-label",
    `Cambiar a modo ${nextTheme === "light" ? "claro" : "oscuro"}`
  );
  button.title =
    `Cambiar a modo ${nextTheme === "light" ? "claro" : "oscuro"}`;
}

function setupThemeToggle() {
  const actions = document.querySelector(".site-header-actions");

  if (!actions) {
    applyTheme(getStoredTheme());
    return;
  }

  const button = document.createElement("button");
  button.type = "button";
  button.className =
    "site-icon-button portfolio-theme-toggle";

  actions.append(button);
  applyTheme(getStoredTheme());

  button.addEventListener("click", () => {
    const current =
      document.documentElement.dataset.siteTheme || "dark";

    applyTheme(current === "dark" ? "light" : "dark");
  });
}

function badgeData(text) {
  const value = uiNormalize(text);

  if (
    value.includes("very easy") ||
    value === "easy" ||
    value.includes("medium") ||
    value.includes("hard") ||
    value.includes("insane")
  ) {
    return ["difficulty", "◆"];
  }

  if (value.includes("linux")) {
    return ["os", "◉"];
  }

  if (value.includes("windows")) {
    return ["os", "⊞"];
  }

  if (
    value.includes("dockerlabs") ||
    value.includes("hack the box") ||
    value.includes("hackthebox") ||
    value.includes("tryhackme") ||
    value.includes("vulnhub")
  ) {
    return ["platform", "▣"];
  }

  if (
    value.includes("completada") ||
    value.includes("completado")
  ) {
    return ["status", "✓"];
  }

  return ["generic", "•"];
}

function enhanceBadge(element) {
  if (
    !(element instanceof HTMLElement) ||
    element.dataset.uiBadge === "true"
  ) {
    return;
  }

  const text = element.textContent.trim();

  if (!text) {
    return;
  }

  const [type, glyph] = badgeData(text);

  element.dataset.uiBadge = "true";
  element.classList.add("ui-badge", `ui-badge-${type}`);

  const icon = document.createElement("span");
  icon.className = "ui-badge-glyph";
  icon.textContent = glyph;
  element.prepend(icon);
}

function cleanUnsafeIcons(root = document) {
  root
    .querySelectorAll(
      ".dynamic-badge-icon, .technique-card-heading > span svg, .timeline-marker svg"
    )
    .forEach((element) => element.remove());

  root
    .querySelectorAll(
      ".recent-machine-meta, .machine-row-platform"
    )
    .forEach((element) => {
      element
        .querySelectorAll("svg, .dynamic-badge-icon, .ui-badge-glyph")
        .forEach((icon) => icon.remove());

      element.classList.remove(
        "dynamic-badge",
        "dynamic-badge-platform",
        "ui-badge",
        "ui-badge-platform"
      );

      delete element.dataset.dynamicBadge;
      delete element.dataset.uiBadge;
    });
}

function enhanceBadges(root = document) {
  cleanUnsafeIcons(root);

  root
    .querySelectorAll(
      ".difficulty-badge, .writeup-inline-badges span, .machine-row-details small"
    )
    .forEach(enhanceBadge);
}

function observeContent() {
  enhanceBadges();

  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      mutation.addedNodes.forEach((node) => {
        if (!(node instanceof HTMLElement)) {
          return;
        }

        enhanceBadges(node);
      });
    });
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
}

function createSearchModal() {
  const modal = document.createElement("div");
  modal.className = "ui-search-modal";
  modal.hidden = true;

  modal.innerHTML = `
    <div class="ui-search-backdrop"></div>

    <section
      class="ui-search-dialog"
      role="dialog"
      aria-modal="true"
      aria-label="Búsqueda global"
    >
      <div class="ui-search-field">
        <span aria-hidden="true"></span>

        <input
          id="ui-search-input"
          type="search"
          placeholder="Buscar máquinas, técnicas o comandos..."
          autocomplete="off"
        >

        <kbd>Esc</kbd>
      </div>

      <div
        class="ui-search-results"
        id="ui-search-results"
      >
        <p class="ui-search-message">
          Escribe para buscar en todo el portafolio.
        </p>
      </div>
    </section>
  `;

  document.body.appendChild(modal);
  return modal;
}

function resultTypeLabel(type) {
  return {
    machine: "Máquina",
    technique: "Técnica",
    command: "Comando"
  }[type] ?? "Resultado";
}

function resultTypeGlyph(type) {
  return {
    machine: "M",
    technique: "T",
    command: ">"
  }[type] ?? "•";
}

function resultScore(entry, tokens) {
  const title = uiNormalize(entry.title);
  const subtitle = uiNormalize(entry.subtitle);
  const content = uiNormalize(entry.content);
  const keywords = uiNormalize(entry.keywords);

  let score = 0;

  tokens.forEach((token) => {
    if (title === token) {
      score += 80;
    } else if (title.startsWith(token)) {
      score += 45;
    } else if (title.includes(token)) {
      score += 30;
    }

    if (subtitle.includes(token)) {
      score += 12;
    }

    if (keywords.includes(token)) {
      score += 10;
    }

    if (content.includes(token)) {
      score += 5;
    }
  });

  return score;
}

function renderSearchResults(container, entries, query) {
  const tokens = uiNormalize(query)
    .split(/\s+/)
    .filter(Boolean);

  if (!tokens.length) {
    container.innerHTML = `
      <p class="ui-search-message">
        Escribe para buscar en todo el portafolio.
      </p>
    `;
    return;
  }

  const matches = entries
    .map((entry) => ({
      entry,
      score: resultScore(entry, tokens)
    }))
    .filter((item) => item.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, 24);

  if (!matches.length) {
    container.innerHTML = `
      <p class="ui-search-message">
        No se encontraron resultados.
      </p>
    `;
    return;
  }

  container.innerHTML = matches
    .map(({ entry }) => `
      <a class="ui-search-result" href="${uiUrl(entry.url)}">
        <span class="ui-search-result-glyph">
          ${resultTypeGlyph(entry.type)}
        </span>

        <span class="ui-search-result-copy">
          <strong>${uiEscape(entry.title)}</strong>
          <small>${uiEscape(entry.subtitle)}</small>
          <span>
            ${uiEscape(String(entry.content ?? "").slice(0, 155))}
          </span>
        </span>

        <em>${resultTypeLabel(entry.type)}</em>
      </a>
    `)
    .join("");
}

async function setupGlobalSearch() {
  const actions = document.querySelector(".site-header-actions");

  if (!actions) {
    return;
  }

  const button = document.createElement("button");
  button.type = "button";
  button.className =
    "site-icon-button portfolio-global-search-button";
  button.textContent = "⌕";
  button.setAttribute(
    "aria-label",
    "Abrir búsqueda global"
  );
  button.title = "Búsqueda global (Ctrl+K)";

  if (!actions.querySelector(".portfolio-global-search-button")) {
    actions.prepend(button);
  }

  const finalButton =
    actions.querySelector(".portfolio-global-search-button");

  const modal = createSearchModal();
  const input = modal.querySelector("#ui-search-input");
  const results = modal.querySelector("#ui-search-results");
  const backdrop = modal.querySelector(".ui-search-backdrop");

  let entries = [];

  async function openSearch() {
    modal.hidden = false;
    document.body.classList.add("ui-search-open");

    if (!entries.length) {
      try {
        entries = await uiLoadJson("search-index.json");
      } catch (error) {
        console.error(error);
        results.innerHTML = `
          <p class="ui-search-message">
            No se pudo cargar el índice.
          </p>
        `;
      }
    }

    window.setTimeout(() => input.focus(), 20);
  }

  function closeSearch() {
    modal.hidden = true;
    document.body.classList.remove("ui-search-open");
  }

  finalButton?.addEventListener("click", openSearch);
  backdrop.addEventListener("click", closeSearch);

  input.addEventListener("input", () => {
    renderSearchResults(results, entries, input.value);
  });

  document.addEventListener("keydown", (event) => {
    const target = event.target;
    const typing =
      target instanceof HTMLInputElement ||
      target instanceof HTMLTextAreaElement ||
      target?.isContentEditable;

    if (
      (event.ctrlKey || event.metaKey) &&
      event.key.toLowerCase() === "k"
    ) {
      event.preventDefault();
      openSearch();
      return;
    }

    if (
      event.key === "/" &&
      !typing &&
      modal.hidden
    ) {
      event.preventDefault();
      openSearch();
      return;
    }

    if (event.key === "Escape" && !modal.hidden) {
      closeSearch();
    }
  });
}

document.addEventListener("DOMContentLoaded", () => {
  setupThemeToggle();
  setupGlobalSearch();
  observeContent();
});