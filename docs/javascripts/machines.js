document.addEventListener("DOMContentLoaded", async function () {
    const machinesList = document.getElementById("machines-list");
    const searchInput = document.getElementById("machine-search");
    const visibleCounter = document.getElementById("visible-machines");
    const totalCounter = document.getElementById("total-machines");

    if (!machinesList) {
        return;
    }

    const jsonPath = new URL(
        "../assets/data/machines.json",
        window.location.href
    );

    let machines = [];

    try {
        const response = await fetch(jsonPath);

        if (!response.ok) {
            throw new Error(
                `No se pudo cargar machines.json: ${response.status}`
            );
        }

        machines = await response.json();
    } catch (error) {
        console.error(error);

        machinesList.innerHTML = `
            <div class="machines-error">
                No se pudo cargar el catálogo de máquinas.
            </div>
        `;

        return;
    }

    function createMachineCard(machine) {
        const tags = Array.isArray(machine.tags)
            ? machine.tags.join(" ")
            : "";

        const searchableContent = [
            machine.name,
            machine.platform,
            machine.difficulty,
            machine.operatingSystem,
            tags
        ]
            .join(" ")
            .toLowerCase();

        const initial = machine.name
            ? machine.name.charAt(0).toUpperCase()
            : "?";

        return `
            <a
                class="machine-list-card"
                data-machine="${escapeHtml(searchableContent)}"
                href="../${escapeHtml(machine.path)}"
            >
                <div class="machine-list-icon">
                    ${escapeHtml(initial)}
                </div>

                <div class="machine-list-information">
                    <h2>${escapeHtml(machine.name)}</h2>
                    <p>${escapeHtml(machine.platform)}</p>
                </div>

                <div class="machine-list-details">
                    <span class="difficulty-badge">
                        ${escapeHtml(machine.difficulty)}
                    </span>

                    <small>
                        ${escapeHtml(machine.operatingSystem)}
                    </small>
                </div>

                <span class="machine-list-arrow">›</span>
            </a>
        `;
    }

    function renderMachines(filteredMachines) {
        machinesList.innerHTML = filteredMachines
            .map(createMachineCard)
            .join("");

        if (visibleCounter) {
            visibleCounter.textContent = filteredMachines.length;
        }

        if (totalCounter) {
            totalCounter.textContent = machines.length;
        }
    }

    function filterMachines() {
        const searchValue = searchInput
            ? searchInput.value.toLowerCase().trim()
            : "";

        const filteredMachines = machines.filter(function (machine) {
            const searchableContent = [
                machine.name,
                machine.platform,
                machine.difficulty,
                machine.operatingSystem,
                machine.status,
                ...(machine.tags || [])
            ]
                .join(" ")
                .toLowerCase();

            return searchableContent.includes(searchValue);
        });

        renderMachines(filteredMachines);
    }

    function escapeHtml(value) {
        return String(value)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;");
    }

    renderMachines(machines);

    if (searchInput) {
        searchInput.addEventListener("input", filterMachines);
    }
});