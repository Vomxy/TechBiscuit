"use strict";

(function() {
    const debounce = (func, delay = 100) => {
        let timer;
        return (...args) => {
            clearTimeout(timer);
            timer = setTimeout(() => func.apply(null, args), delay);
        };
    };

    const loadAnalytics = (() => {
        let loaded = false;
        return () => {
            if (loaded) return;
            loaded = true;
            const script = document.createElement("script");
            script.defer = true;
            script.dataset.domain = "www.thetechbiscuit.com";
            script.src = "https://plausible.io/js/script.js";
            document.head.appendChild(script);
        };
    })();

    const initCookieBanner = () => {
        const banner = document.getElementById("cookie-consent-banner");
        if (!banner) return;

        const acceptBtn = document.getElementById("accept-cookies");
        const declineBtn = document.getElementById("decline-cookies");
        const consentGiven = localStorage.getItem("cookieConsent");

        if (!consentGiven) {
            banner.classList.remove("is-hidden");
        } else if (consentGiven === "accepted") {
            loadAnalytics();
        }

        acceptBtn?.addEventListener("click", () => {
            localStorage.setItem("cookieConsent", "accepted");
            banner.classList.add("is-hidden");
            loadAnalytics();
        });

        declineBtn?.addEventListener("click", () => {
            localStorage.setItem("cookieConsent", "declined");
            banner.classList.add("is-hidden");
        });
    };

    const initTabs = () => {
        const tabLinks = document.querySelectorAll(".tab-link");
        const tabContents = document.querySelectorAll(".tab-content");
        if (!tabLinks.length || !tabContents.length) return;

        const openTab = (tabName) => {
            tabContents.forEach((content) => {
                content.classList.remove("active-tab");
                content.style.display = "none";
                content.setAttribute("aria-hidden", "true");
            });

            tabLinks.forEach((link) => {
                link.classList.remove("active");
                link.setAttribute("aria-selected", "false");
                link.setAttribute("tabindex", "-1");
            });

            const selectedTab = document.getElementById(tabName);
            const selectedLink = document.querySelector(`[data-tab="${tabName}"]`);

            if (selectedTab) {
                selectedTab.style.display = "block";
                selectedTab.setAttribute("aria-hidden", "false");
                setTimeout(() => selectedTab.classList.add("active-tab"), 10);
            }

            if (selectedLink) {
                selectedLink.classList.add("active");
                selectedLink.setAttribute("aria-selected", "true");
                selectedLink.setAttribute("tabindex", "0");
                selectedLink.focus();
            }
        };

        tabLinks.forEach((link) => {
            link.addEventListener("click", (e) => {
                e.preventDefault();
                openTab(link.dataset.tab);
            });

            link.addEventListener("keydown", (e) => {
                const currentIndex = Array.from(tabLinks).indexOf(link);
                let targetIndex;

                if (e.key === "ArrowRight" || e.key === "ArrowDown") {
                    e.preventDefault();
                    targetIndex = (currentIndex + 1) % tabLinks.length;
                } else if (e.key === "ArrowLeft" || e.key === "ArrowUp") {
                    e.preventDefault();
                    targetIndex = (currentIndex - 1 + tabLinks.length) % tabLinks.length;
                } else if (e.key === "Home") {
                    e.preventDefault();
                    targetIndex = 0;
                } else if (e.key === "End") {
                    e.preventDefault();
                    targetIndex = tabLinks.length - 1;
                }

                if (targetIndex !== undefined) {
                    openTab(tabLinks[targetIndex].dataset.tab);
                }
            });
        });

        const firstTab = tabLinks[0].dataset.tab;
        if (firstTab) openTab(firstTab);
    };

    const initSmoothScroll = () => {
        document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
            anchor.addEventListener("click", (e) => {
                const target = document.querySelector(anchor.getAttribute("href"));
                if (!target) return;
                e.preventDefault();
                target.scrollIntoView({ behavior: "smooth" });
                target.style.scrollMarginTop = `${(document.querySelector("header")?.offsetHeight || 0) + 10}px`;
            });
        });
    };

    const initProgressBar = () => {
        const progressBar = document.getElementById("progress-bar");
        const header = document.querySelector("header");
        if (!progressBar || !header) return;

        const adjust = () => {
            progressBar.style.top = `${header.offsetHeight}px`;
        };

        const update = () => {
            const scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
            const scrollHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
            const scrolledPercentage = scrollHeight > 0 ? (scrollTop / scrollHeight) * 100 : 0;
            progressBar.style.width = `${scrolledPercentage}%`;
        };

        window.addEventListener("load", () => {
            adjust();
            update();
            progressBar.style.opacity = "1";
        });
        window.addEventListener("resize", debounce(adjust, 100));
        window.addEventListener("scroll", debounce(update, 20));
    };

    const initHeaderScrollEffect = () => {
        const siteHeader = document.querySelector(".site-header");
        if (!siteHeader) return;
        window.addEventListener("scroll", debounce(() => {
            const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
            if (scrollTop > 50) {
                siteHeader.classList.add("scrolled");
            } else {
                siteHeader.classList.remove("scrolled");
            }
        }, 20));
    };

    const initImageLoading = () => {
        document.querySelectorAll("img").forEach((img) => {
            const markLoaded = () => img.classList.add("loaded");
            if (img.complete) {
                markLoaded();
            } else {
                img.addEventListener("load", markLoaded);
                img.addEventListener("error", markLoaded);
            }
        });
    };

    const initLazyLoad = () => {
        if (!("IntersectionObserver" in window)) return;
        const lazyElements = document.querySelectorAll(".lazy-load");
        if (!lazyElements.length) return;

        const lazyLoadObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    entry.target.classList.add("visible");
                    observer.unobserve(entry.target);
                }
            });
        }, { rootMargin: "50px" });

        lazyElements.forEach((el) => lazyLoadObserver.observe(el));
    };

    const initStagger = () => {
        if (!("IntersectionObserver" in window)) return;
        const blogGrid = document.querySelector(".blog-grid");
        if (!blogGrid) return;

        const staggerObserver = new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    entry.target.classList.add("stagger-animation");
                }
            });
        }, { threshold: 0.1 });

        staggerObserver.observe(blogGrid);
    };

    const markContentLoaded = () => {
        const contentContainer = document.querySelector(".content-container");
        if (contentContainer) {
            window.addEventListener("load", () => {
                contentContainer.classList.add("content-loaded");
            });
        }
    };

    const initMobileMenu = () => {
        const mobileMenuToggle = document.querySelector(".mobile-menu-toggle");
        const mainNav = document.querySelector(".main-nav");
        const navLinks = document.querySelectorAll(".nav-link");
        if (!mobileMenuToggle || !mainNav) return;

        const menuIcon = mobileMenuToggle.querySelector(".menu-icon");
        const closeMenu = () => {
            mainNav.classList.remove("active");
            mobileMenuToggle.setAttribute("aria-expanded", "false");
            if (menuIcon) menuIcon.textContent = "☰";
        };

        mobileMenuToggle.addEventListener("click", () => {
            const isExpanded = mainNav.classList.toggle("active");
            mobileMenuToggle.setAttribute("aria-expanded", String(isExpanded));
            if (menuIcon) menuIcon.textContent = isExpanded ? "✕" : "☰";
        });

        navLinks.forEach((link) => {
            link.addEventListener("click", () => {
                if (window.innerWidth <= 768) {
                    closeMenu();
                }
            });
        });

        document.addEventListener("click", (event) => {
            if (window.innerWidth <= 768 && !event.target.closest(".site-header") && mainNav.classList.contains("active")) {
                closeMenu();
            }
        });

        window.addEventListener("resize", debounce(() => {
            if (window.innerWidth > 768) {
                closeMenu();
            }
        }, 100));
    };

    document.addEventListener("DOMContentLoaded", () => {
        initCookieBanner();
        initTabs();
        initSmoothScroll();
        initProgressBar();
        initHeaderScrollEffect();
        initImageLoading();
        initLazyLoad();
        initStagger();
        markContentLoaded();
        initMobileMenu();
    });
})();
