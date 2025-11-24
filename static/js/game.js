"use strict";

(function() {
const gameContainer = document.getElementById("game-container");
const attemptsDisplay = document.getElementById("attempts");
const retryButton = document.getElementById("retry-button");
const statusMessage = document.getElementById("game-status");

if (!gameContainer || !attemptsDisplay || !retryButton) return;

const gridSize = 3;
let bugIndex = 0;
let attempts = 0;

const updateAttempts = () => {
    attemptsDisplay.textContent = `Attempts: ${attempts}`;
};

const announce = (message) => {
    if (statusMessage) {
        statusMessage.textContent = message;
    }
};

    const confettiBurst = (cell) => {
        if (window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
            return;
        }
        const burst = document.createElement("div");
        burst.classList.add("confetti");
        for (let i = 0; i < 12; i++) {
            const piece = document.createElement("span");
            piece.style.setProperty("--i", i);
        burst.appendChild(piece);
    }
    cell.appendChild(burst);
    setTimeout(() => {
        burst.remove();
    }, 900);
};

const handleSuccess = (cell) => {
    announce("You found the biscuit! Nice job.");
    cell.classList.add("pulse");
    cell.classList.add("winner");
    confettiBurst(cell);
    setTimeout(() => {
        const homeLink = document.querySelector(".back-home");
        if (homeLink) {
            homeLink.focus();
        }
    }, 600);
};

    const resetGame = () => {
        gameContainer.innerHTML = "";
        attempts = 0;
        updateAttempts();
        announce("");
        bugIndex = Math.floor(Math.random() * (gridSize * gridSize));

        for (let i = 0; i < gridSize * gridSize; i++) {
            const cell = document.createElement("div");
            cell.classList.add("game-cell");
            cell.setAttribute("tabindex", "0");
            cell.setAttribute("role", "gridcell");

            const cover = document.createElement("span");
            cover.classList.add("cover");
            cover.textContent = "?";

            const icon = document.createElement("span");
            icon.classList.add("game-icon");
            icon.textContent = i === bugIndex ? "🍪" : "</>";
            icon.hidden = true;

            const reveal = () => {
                attempts += 1;
                updateAttempts();
                cover.classList.add("is-hidden");
                icon.hidden = false;

                if (i === bugIndex) {
                    handleSuccess(cell);
                } else {
                    cell.classList.add("shake");
                    setTimeout(() => {
                        cell.classList.remove("shake");
                        cover.classList.remove("is-hidden");
                        icon.hidden = true;
                    }, 800);
                }
            };

            cell.addEventListener("click", reveal);
            cell.addEventListener("keydown", (e) => {
                if (e.key === "Enter" || e.key === " ") {
                    e.preventDefault();
                    reveal();
                }
            });

            cell.appendChild(cover);
            cell.appendChild(icon);
            gameContainer.appendChild(cell);
        }
    };

    retryButton.addEventListener("click", resetGame);
    retryButton.addEventListener("keydown", (e) => {
        if (e.key === "Enter" || e.key === " ") {
            e.preventDefault();
            resetGame();
        }
    });

    resetGame();
})();
