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

    if (
        !machinesCounter &&
        !platformsCounter &&
        !writeupsCounter
    ) {
        return;
    }

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
    } catch (error) {
        console.error(
            "No se pudieron actualizar las estadísticas:",
            error
        );
    }
});