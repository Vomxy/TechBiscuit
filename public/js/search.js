"use strict";

(function() {
    const searchInput = document.getElementById("search-input");
    const clearButton = document.getElementById("clear-search");
    const resultsContainer = document.getElementById("search-results");
    const noResults = document.getElementById("no-results");
    const resultsCount = document.getElementById("results-count");
    const tagFiltersContainer = document.getElementById("tag-filters");
    const errorBox = document.getElementById("search-error");

    if (!searchInput || !resultsContainer || !resultsCount) return;

    const state = {
        index: [],
        allTags: new Set(),
        selectedTags: new Set()
    };

    const escapeHTML = (str = "") =>
        str.replace(/[&<>"']/g, (char) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[char] || char));

    const highlight = (text, query) => {
        if (!query) return escapeHTML(text);
        const escapedQuery = query.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
        const regex = new RegExp(`(${escapedQuery})`, "gi");
        return escapeHTML(text).replace(regex, "<mark>$1</mark>");
    };

    const setHidden = (el, hidden) => {
        if (!el) return;
        el.classList.toggle("is-hidden", hidden);
    };

    const formatDate = (dateString) => {
        const date = new Date(dateString);
        return isNaN(date.getTime())
            ? ""
            : date.toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" });
    };

    const updateResultsCount = (count, total) => {
        if (count === total) {
            resultsCount.textContent = `Showing all ${total} posts`;
        } else {
            resultsCount.textContent = `Found ${count} of ${total} posts`;
        }
    };

    const renderTagFilters = () => {
        const sortedTags = Array.from(state.allTags).sort();
        tagFiltersContainer.innerHTML = sortedTags
            .map((tag) => `<button class="tag-filter" data-tag="${tag}" aria-pressed="false">${tag}</button>`)
            .join("");

        tagFiltersContainer.querySelectorAll(".tag-filter").forEach((button) => {
            button.addEventListener("click", () => toggleTagFilter(button));
        });
    };

    const toggleTagFilter = (button) => {
        const tag = button.dataset.tag;
        const isActive = state.selectedTags.has(tag);
        if (isActive) {
            state.selectedTags.delete(tag);
            button.classList.remove("active");
            button.setAttribute("aria-pressed", "false");
        } else {
            state.selectedTags.add(tag);
            button.classList.add("active");
            button.setAttribute("aria-pressed", "true");
        }
        performSearch();
    };

    const displayResults = (results, query) => {
        if (!results.length) {
            setHidden(resultsContainer, true);
            setHidden(noResults, false);
            return;
        }

        setHidden(noResults, true);
        setHidden(resultsContainer, false);

        resultsContainer.innerHTML = results
            .map((post) => {
                const title = highlight(post.title, query);
                const summary = highlight(post.summary || "No summary available", query);
                const date = formatDate(post.date);
                const readingTime = post.readingTime ? `${post.readingTime} min read` : "";
                const tags = Array.isArray(post.tags) ? post.tags.filter(Boolean) : [];
                const tagsMarkup = tags.length
                    ? `<div class="search-result-tags">${tags.map((tag) => `<span class="tag">${escapeHTML(tag)}</span>`).join("")}</div>`
                    : "";

                return `
                <article class="search-result-card">
                    <div class="search-result-badge">
                        <svg class="icon" aria-hidden="true"><use xlink:href="/icons/sprite.svg#search"></use></svg>
                    </div>
                    <div class="search-result-content">
                        <h3 class="search-result-title">
                            <a href="${post.permalink}">${title}</a>
                        </h3>
                        <p class="search-result-summary">${summary}</p>
                        <div class="search-result-meta">
                            <span class="date">${escapeHTML(date)}</span>
                            <span class="reading-time">${escapeHTML(readingTime)}</span>
                        </div>
                        ${tagsMarkup}
                    </div>
                </article>`;
            })
            .join("");
    };

    const performSearch = () => {
        const query = searchInput.value.toLowerCase().trim();
        let results = state.index;

        if (query) {
            results = results.filter((post) => {
                const searchableText = `${post.title} ${post.summary} ${post.content}`.toLowerCase();
                const searchableTags = Array.isArray(post.tags) ? post.tags.join(" ").toLowerCase() : "";
                return searchableText.includes(query) || searchableTags.includes(query);
            });
        }

        if (state.selectedTags.size > 0) {
            results = results.filter((post) => {
                if (!Array.isArray(post.tags)) return false;
                return Array.from(state.selectedTags).some((tag) => post.tags.includes(tag));
            });
        }

        displayResults(results, query);
        updateResultsCount(results.length, state.index.length);
    };

    const loadIndex = () => {
        fetch("/index.json", { cache: "no-store" })
            .then((response) => {
                if (!response.ok) throw new Error(`Status ${response.status}`);
                return response.json();
            })
            .then((data) => {
                state.index = data || [];
                state.index.forEach((post) => {
                    if (Array.isArray(post.tags)) {
                        post.tags.forEach((tag) => tag && state.allTags.add(tag));
                    }
                });
                renderTagFilters();
                displayResults(state.index, "");
                updateResultsCount(state.index.length, state.index.length);
            })
            .catch(() => {
                if (errorBox) {
                    setHidden(errorBox, false);
                }
                resultsCount.textContent = "Error loading search index";
            });
    };

    // Event bindings
    searchInput.addEventListener("input", () => {
        setHidden(clearButton, searchInput.value.length === 0);
        performSearch();
    });

    clearButton?.addEventListener("click", () => {
        searchInput.value = "";
        setHidden(clearButton, true);
        searchInput.focus();
        performSearch();
    });

    // Handle URL query parameter
    const urlParams = new URLSearchParams(window.location.search);
    const urlQuery = urlParams.get("q");
    if (urlQuery) {
        searchInput.value = urlQuery;
        setHidden(clearButton, false);
        searchInput.focus();
    }
    loadIndex();
})();
