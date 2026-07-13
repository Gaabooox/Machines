const homeScriptUrl = new URL(document.currentScript.src);

const machinesJsonUrl = new URL(
    "../assets/data/machines.json",
    homeScriptUrl
);


document.addEventListener("DOMContentLoaded", async function () {
    const machinesCounter = document.getElementById(
        "home-machines-count"
    );

    const platformsCounter = document.getElementById(
        "home-platforms-count"
    );

    const writeupsCounter = document.getElementById(
        "home-writeups-count"
    );

    const recentMachinesContainer = document.querySelector(
        ".machines-grid"
    );

    const platformIndicator = document.querySelector(
        ".section-counter"
    );


    try {
        const response = await fetch(machinesJsonUrl);

        if (!response.ok) {
            throw new Error(
                `No se pudo cargar machines.json: ${response.status}`
            );
        }

        const machines = await response.json();

        const platforms = new Set(
            machines.map(function (machine) {
                return machine.platformSlug || machine.platform;
            })
        );

        const completedWriteups = machines.filter(function (machine) {
            return machine.status === "Completada";
        });


        if (machinesCounter) {
            machinesCounter.textContent = machines.length;
        }

        if (platformsCounter) {
            platformsCounter.textContent = platforms.size;
        }

        if (writeupsCounter) {
            writeupsCounter.textContent = completedWriteups.length;
        }


        if (platformIndicator) {
            const platformNames = [
                ...new Set(
                    machines.map(function (machine) {
                        return machine.platform;
                    })
                )
            ];

            platformIndicator.textContent = platformNames.join(" · ");
        }


        if (recentMachinesContainer) {
            const recentMachines = machines
                .slice(-4)
                .reverse();

            recentMachinesContainer.innerHTML = recentMachines
                .map(createRecentMachineCard)
                .join("");
        }
    } catch (error) {
        console.error(
            "No se pudo actualizar la portada:",
            error
        );
    }
});


function createRecentMachineCard(machine) {
    const initial = machine.name
        ? machine.name.charAt(0).toUpperCase()
        : "?";

    const tags = Array.isArray(machine.tags)
        ? machine.tags.slice(0, 3)
        : [];

    const tagsHtml = tags
        .map(function (tag) {
            return `<span>${escapeHtml(tag)}</span>`;
        })
        .join("");

    return `
        <a
            class="machine-card"
            href="${escapeHtml(machine.path)}"
        >
            <div class="machine-card-header">
                <div class="machine-icon">
                    ${escapeHtml(initial)}
                </div>

                <span class="difficulty-badge">
                    ${escapeHtml(machine.difficulty)}
                </span>
            </div>

            <h3>${escapeHtml(machine.name)}</h3>

            <p>
                ${escapeHtml(machine.platform)}
                ·
                ${escapeHtml(machine.operatingSystem)}
            </p>

            <div class="machine-tags">
                ${tagsHtml}
            </div>
        </a>
    `;
}


function escapeHtml(value) {
    return String(value)
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;")
        .replaceAll("'", "&#039;");
}