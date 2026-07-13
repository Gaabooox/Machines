const DYNAMIC_SECTIONS_SCRIPT_URL = new URL(
  document.currentScript.src
);

const DYNAMIC_SECTIONS_BASE_URL = new URL(
  "../",
  DYNAMIC_SECTIONS_SCRIPT_URL
);

const DYNAMIC_MACHINES_URL = new URL(
  "../assets/data/machines.json",
  DYNAMIC_SECTIONS_SCRIPT_URL
);

let dynamicMachinesPromise = null;

function loadDynamicMachines() {
  if (!dynamicMachinesPromise) {
    dynamicMachinesPromise = fetch(
      DYNAMIC_MACHINES_URL
    ).then((response) => {
      if (!response.ok) {
        throw new Error(
          `No se pudo cargar machines.json: ${response.status}`
        );
      }

      return response.json();
    });
  }

  return dynamicMachinesPromise;
}

function dynamicEscape(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function dynamicNormalize(value) {
  return String(value ?? "")
    .normalize("NFD")
    .replace(/\p{Diacritic}/gu, "")
    .toLowerCase()
    .trim();
}

function dynamicSlug(value) {
  return dynamicNormalize(value)
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function dynamicPageUrl(path) {
  return new URL(
    String(path ?? "").replace(/^\/+/, ""),
    DYNAMIC_SECTIONS_BASE_URL
  ).href;
}

function machineTags(machine) {
  return Array.isArray(machine.tags)
    ? machine.tags
        .map((tag) => String(tag).trim())
        .filter(Boolean)
    : [];
}

function machineDateValue(machine) {
  const value = String(machine.date ?? "").trim();

  if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return value;
  }

  return "";
}

function formatDynamicDate(value) {
  if (!value) {
    return "Fecha no disponible";
  }

  const date = new Date(`${value}T00:00:00`);

  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return new Intl.DateTimeFormat("es-PE", {
    day: "2-digit",
    month: "long",
    year: "numeric"
  }).format(date);
}

function createDynamicTechniqueCard(technique) {
  const machineLinks = technique.machines
    .map((machine) => `
      <a
        class="pf-tech-machine"
        href="${dynamicPageUrl(machine.path)}"
      >
        <span class="pf-tech-machine-copy">
          <strong>${dynamicEscape(machine.name)}</strong>
          <small>${dynamicEscape(machine.platform)}</small>
        </span>

        <span class="pf-tech-machine-meta">
          <em>${dynamicEscape(machine.difficulty)}</em>
          <i>${dynamicEscape(machine.operatingSystem)}</i>
        </span>
      </a>
    `)
    .join("");

  return `
    <article
      class="pf-tech-card"
      id="${dynamicEscape(technique.slug)}"
      data-search="${dynamicEscape(technique.search)}"
    >
      <header class="pf-tech-card-header">
        <span class="pf-tech-card-mark">#</span>

        <div>
          <h2>${dynamicEscape(technique.name)}</h2>
          <p>${technique.machines.length} máquina(s)</p>
        </div>
      </header>

      <div class="pf-tech-card-machines">
        ${machineLinks}
      </div>
    </article>
  `;
}

async function initDynamicTechniques() {
  const grid = document.querySelector(
    "#dynamic-techniques-grid"
  );

  if (!grid) {
    return;
  }

  const countElement = document.querySelector(
    "#dynamic-techniques-count"
  );

  const usesElement = document.querySelector(
    "#dynamic-techniques-uses"
  );

  const visibleElement = document.querySelector(
    "#dynamic-techniques-visible"
  );

  const input = document.querySelector(
    "#dynamic-techniques-search"
  );

  const emptyElement = document.querySelector(
    "#dynamic-techniques-empty"
  );

  try {
    const machines = await loadDynamicMachines();
    const techniqueMap = new Map();
    let totalUses = 0;

    machines.forEach((machine) => {
      machineTags(machine).forEach((tag) => {
        const key = dynamicNormalize(tag);

        if (!techniqueMap.has(key)) {
          techniqueMap.set(key, {
            name: tag,
            slug: dynamicSlug(tag),
            machines: []
          });
        }

        techniqueMap.get(key).machines.push(machine);
        totalUses += 1;
      });
    });

    const techniques = [...techniqueMap.values()]
      .map((technique) => ({
        ...technique,
        machines: technique.machines.sort((a, b) =>
          String(a.name).localeCompare(
            String(b.name),
            "es"
          )
        ),
        search: dynamicNormalize(
          [
            technique.name,
            ...technique.machines.map(
              (machine) =>
                `${machine.name} ${machine.platform}`
            )
          ].join(" ")
        )
      }))
      .sort((a, b) => {
        const countDifference =
          b.machines.length - a.machines.length;

        if (countDifference !== 0) {
          return countDifference;
        }

        return a.name.localeCompare(b.name, "es");
      });

    if (countElement) {
      countElement.textContent = String(
        techniques.length
      );
    }

    if (usesElement) {
      usesElement.textContent = String(totalUses);
    }

    grid.innerHTML = techniques.length
      ? techniques
          .map(createDynamicTechniqueCard)
          .join("")
      : `
          <p class="pf-empty-state">
            No hay técnicas registradas.
          </p>
        `;

    const cards = [
      ...grid.querySelectorAll(".pf-tech-card")
    ];

    const render = () => {
      const query = dynamicNormalize(
        input?.value ?? ""
      );

      let visible = 0;

      cards.forEach((card) => {
        const matches =
          !query ||
          dynamicNormalize(
            card.dataset.search
          ).includes(query);

        card.hidden = !matches;

        if (matches) {
          visible += 1;
        }
      });

      if (visibleElement) {
        visibleElement.textContent = String(visible);
      }

      if (emptyElement) {
        emptyElement.hidden = visible !== 0;
      }
    };

    input?.addEventListener("input", render);
    render();

    if (window.location.hash) {
      window.setTimeout(() => {
        const target = document.querySelector(
          window.location.hash
        );

        target?.scrollIntoView({
          behavior: "smooth",
          block: "start"
        });
      }, 80);
    }
  }
  catch (error) {
    console.error(error);

    grid.innerHTML = `
      <p class="pf-empty-state">
        No se pudieron cargar las técnicas.
      </p>
    `;
  }
}

function platformMark(name) {
  const words = String(name ?? "")
    .trim()
    .split(/\s+/)
    .filter(Boolean);

  if (!words.length) {
    return "PF";
  }

  if (words.length === 1) {
    return words[0]
      .slice(0, 3)
      .toUpperCase();
  }

  return words
    .slice(0, 3)
    .map((word) => word[0])
    .join("")
    .toUpperCase();
}

function createDynamicPlatformCard(platform) {
  const machines = platform.machines
    .map((machine) => `
      <a href="${dynamicPageUrl(machine.path)}">
        <span>${dynamicEscape(machine.name)}</span>
        <small>${dynamicEscape(machine.difficulty)}</small>
      </a>
    `)
    .join("");

  return `
    <article class="pf-platform-card is-active">
      <header>
        <span class="pf-platform-mark">
          ${dynamicEscape(platform.mark)}
        </span>

        <div>
          <h2>${dynamicEscape(platform.name)}</h2>
          <p>${platform.machines.length} writeup(s)</p>
        </div>
      </header>

      <p class="pf-platform-description">
        Máquinas y laboratorios documentados de
        ${dynamicEscape(platform.name)}.
      </p>

      <div class="pf-platform-machines">
        ${machines}
      </div>
    </article>
  `;
}

async function initDynamicPlatforms() {
  const grid = document.querySelector(
    "#dynamic-platforms-grid"
  );

  if (!grid) {
    return;
  }

  try {
    const machines = await loadDynamicMachines();
    const platformMap = new Map();

    machines.forEach((machine) => {
      const name = String(
        machine.platform ?? "Sin plataforma"
      ).trim();

      const key = String(
        machine.platformSlug ||
        dynamicSlug(name)
      ).trim();

      if (!platformMap.has(key)) {
        platformMap.set(key, {
          name,
          slug: key,
          mark: platformMark(name),
          machines: []
        });
      }

      platformMap.get(key).machines.push(machine);
    });

    const platforms = [...platformMap.values()]
      .map((platform) => ({
        ...platform,
        machines: platform.machines.sort((a, b) =>
          String(a.name).localeCompare(
            String(b.name),
            "es"
          )
        )
      }))
      .sort((a, b) => {
        const countDifference =
          b.machines.length - a.machines.length;

        if (countDifference !== 0) {
          return countDifference;
        }

        return a.name.localeCompare(b.name, "es");
      });

    grid.innerHTML = platforms.length
      ? platforms
          .map(createDynamicPlatformCard)
          .join("")
      : `
          <p class="pf-empty-state">
            No hay plataformas registradas.
          </p>
        `;
  }
  catch (error) {
    console.error(error);

    grid.innerHTML = `
      <p class="pf-empty-state">
        No se pudieron cargar las plataformas.
      </p>
    `;
  }
}

function createDynamicTimelineItem(machine, index) {
  const tags = machineTags(machine)
    .slice(0, 5)
    .map(
      (tag) =>
        `<span>${dynamicEscape(tag)}</span>`
    )
    .join("");

  const date = machineDateValue(machine);

  return `
    <article class="pf-timeline-item">
      <div class="pf-timeline-axis">
        <span>${String(index + 1).padStart(2, "0")}</span>
      </div>

      <div class="pf-timeline-card">
        <div class="pf-timeline-card-top">
          <time datetime="${dynamicEscape(date)}">
            ${dynamicEscape(formatDynamicDate(date))}
          </time>

          <a href="${dynamicPageUrl(machine.path)}">
            Ver writeup
            <span aria-hidden="true">→</span>
          </a>
        </div>

        <h3>${dynamicEscape(machine.name)}</h3>

        <p class="pf-timeline-meta">
          ${dynamicEscape(machine.platform)}
          <span>·</span>
          ${dynamicEscape(machine.difficulty)}
          <span>·</span>
          ${dynamicEscape(machine.operatingSystem)}
        </p>

        <p class="pf-timeline-description">
          ${dynamicEscape(
            machine.summary ||
            `Resolución documentada de ${machine.name}.`
          )}
        </p>

        <div class="pf-timeline-tags">
          ${tags}
        </div>
      </div>
    </article>
  `;
}

async function initDynamicTimeline() {
  const container = document.querySelector(
    "#dynamic-timeline"
  );

  if (!container) {
    return;
  }

  const countElement = document.querySelector(
    "#dynamic-timeline-count"
  );

  const yearsElement = document.querySelector(
    "#dynamic-timeline-years"
  );

  try {
    const machines = await loadDynamicMachines();

    const sortedMachines = [...machines].sort(
      (a, b) => {
        const dateA =
          machineDateValue(a) || "0000-00-00";

        const dateB =
          machineDateValue(b) || "0000-00-00";

        const dateDifference =
          dateB.localeCompare(dateA);

        if (dateDifference !== 0) {
          return dateDifference;
        }

        return String(a.name).localeCompare(
          String(b.name),
          "es"
        );
      }
    );

    const yearMap = new Map();

    sortedMachines.forEach((machine) => {
      const date = machineDateValue(machine);
      const year = date
        ? date.slice(0, 4)
        : "Sin fecha";

      if (!yearMap.has(year)) {
        yearMap.set(year, []);
      }

      yearMap.get(year).push(machine);
    });

    const years = [...yearMap.keys()];

    if (countElement) {
      countElement.textContent = String(
        sortedMachines.length
      );
    }

    if (yearsElement) {
      yearsElement.textContent = String(
        years.length
      );
    }

    container.innerHTML = years.length
      ? years
          .map((year) => {
            const yearMachines =
              yearMap.get(year) ?? [];

            return `
              <section class="pf-timeline-year">
                <header>
                  <h2>${dynamicEscape(year)}</h2>
                  <span>
                    ${yearMachines.length} máquina(s)
                  </span>
                </header>

                <div class="pf-timeline-list">
                  ${yearMachines
                    .map(createDynamicTimelineItem)
                    .join("")}
                </div>
              </section>
            `;
          })
          .join("")
      : `
          <p class="pf-empty-state">
            No hay máquinas registradas.
          </p>
        `;
  }
  catch (error) {
    console.error(error);

    container.innerHTML = `
      <p class="pf-empty-state">
        No se pudo cargar la línea temporal.
      </p>
    `;
  }
}

document.addEventListener("DOMContentLoaded", () => {
  initDynamicTechniques();
  initDynamicPlatforms();
  initDynamicTimeline();
});