"use strict";

(function() {
    const filterButtons = document.querySelectorAll(".filter-btn");
    const creativeCards = Array.from(document.querySelectorAll(".creative-card"));
    const searchInput = document.getElementById("creative-search");
    const sortSelect = document.getElementById("creative-sort");
    const resultsCount = document.getElementById("creative-results-count");
    const resetButton = document.getElementById("creative-reset");
    const resetLinks = document.querySelectorAll("[data-reset-filters]");
    const emptyState = document.getElementById("creative-empty");

    if (!filterButtons.length || !creativeCards.length) return;

    const state = {
        filter: "all",
        query: "",
        sort: "newest"
    };

    const normalize = (value = "") => value.toLowerCase().trim();

    const updateActiveFilter = (button) => {
        filterButtons.forEach((btn) => {
            btn.classList.remove("active");
            btn.setAttribute("aria-pressed", "false");
        });
        button.classList.add("active");
        button.setAttribute("aria-pressed", "true");
    };

    const updateCount = (visible) => {
        if (resultsCount) {
            resultsCount.textContent = `Showing ${visible} piece${visible === 1 ? "" : "s"}`;
        }
        if (emptyState) {
            emptyState.classList.toggle("is-hidden", visible !== 0);
        }
    };

    const applySort = () => {
        const visibleCards = creativeCards.filter((card) => !card.classList.contains("is-hidden"));
        const sortBy = state.sort;

        visibleCards.sort((a, b) => {
            const yearA = parseInt(a.dataset.year, 10) || 0;
            const yearB = parseInt(b.dataset.year, 10) || 0;
            const titleA = a.querySelector(".card-title")?.textContent?.toLowerCase() || "";
            const titleB = b.querySelector(".card-title")?.textContent?.toLowerCase() || "";

            if (sortBy === "oldest") return yearA - yearB;
            if (sortBy === "title") return titleA.localeCompare(titleB, "en");
            return yearB - yearA; // newest
        });

        visibleCards.forEach((card, index) => {
            card.style.order = index;
        });
    };

    const applyFilters = () => {
        const query = normalize(state.query);
        let visible = 0;

        creativeCards.forEach((card) => {
            const category = normalize(card.dataset.category);
            const theme = normalize(card.dataset.theme);
            const searchField = normalize(card.dataset.search);
            const matchesCategory = state.filter === "all" || category === state.filter || theme === state.filter;
            const matchesQuery = !query || searchField.includes(query);
            const isVisible = matchesCategory && matchesQuery;

            card.classList.toggle("is-hidden", !isVisible);
            card.classList.toggle("fade-in", isVisible);
            if (isVisible) visible += 1;
        });

        applySort();
        updateCount(visible);
    };

    const resetFilters = () => {
        state.filter = "all";
        state.query = "";
        state.sort = "newest";
        if (searchInput) searchInput.value = "";
        if (sortSelect) sortSelect.value = "newest";
        updateActiveFilter(filterButtons[0]);
        applyFilters();
    };

    filterButtons.forEach((button) => {
        button.addEventListener("click", () => {
            state.filter = normalize(button.dataset.filter);
            updateActiveFilter(button);
            applyFilters();
        });
    });

    if (searchInput) {
        searchInput.addEventListener("input", (event) => {
            state.query = event.target.value || "";
            applyFilters();
        });
    }

    if (sortSelect) {
        sortSelect.addEventListener("change", (event) => {
            state.sort = event.target.value;
            applySort();
        });
    }

    if (resetButton) {
        resetButton.addEventListener("click", resetFilters);
    }

    if (resetLinks.length) {
        resetLinks.forEach((btn) => btn.addEventListener("click", resetFilters));
    }

    const initCardInteractions = (card) => {
        const readButton = card.querySelector(".read-more-btn");
        const closeButton = card.querySelector(".close-btn");
        const cardInner = card.querySelector(".card-inner");
        if (!readButton || !closeButton || !cardInner) return;

        const openCard = () => {
            cardInner.classList.add("flipped");
            closeButton.focus();
        };

        const closeCard = () => {
            cardInner.classList.remove("flipped");
            readButton.focus();
        };

        readButton.addEventListener("click", (e) => {
            e.preventDefault();
            openCard();
        });

        readButton.addEventListener("keydown", (e) => {
            if (e.key === "Enter" || e.key === " ") {
                e.preventDefault();
                openCard();
            }
        });

        closeButton.addEventListener("click", (e) => {
            e.preventDefault();
            closeCard();
        });

        closeButton.addEventListener("keydown", (e) => {
            if (e.key === "Enter" || e.key === " ") {
                e.preventDefault();
                closeCard();
            }
        });

        document.addEventListener("keyup", (e) => {
            if (e.key === "Escape" && cardInner.classList.contains("flipped")) {
                closeCard();
            }
        });
    };

    creativeCards.forEach((card) => {
        card.classList.remove("is-hidden");
        initCardInteractions(card);
    });

    applyFilters();
})();
