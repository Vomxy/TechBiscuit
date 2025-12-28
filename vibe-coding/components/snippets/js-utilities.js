// ============================================
// VIBE CODING: JavaScript Utility Snippets
// Quick copy-paste functions for rapid dev
// ============================================

// ----------------
// Intersection Observer (Lazy Load / Reveal)
// ----------------
function initIntersectionObserver(selector = '.reveal', options = {}) {
    const defaultOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.1,
        ...options
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, defaultOptions);

    document.querySelectorAll(selector).forEach(el => observer.observe(el));
}

// Usage: initIntersectionObserver('.reveal');

// ----------------
// Debounce Function
// ----------------
function debounce(func, wait = 300) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Usage: window.addEventListener('resize', debounce(() => console.log('Resized!'), 300));

// ----------------
// Throttle Function
// ----------------
function throttle(func, limit = 100) {
    let inThrottle;
    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// Usage: window.addEventListener('scroll', throttle(() => console.log('Scrolling!'), 100));

// ----------------
// Smooth Scroll to Element
// ----------------
function smoothScrollTo(selector, offset = 0) {
    const element = document.querySelector(selector);
    if (!element) return;

    const elementPosition = element.getBoundingClientRect().top + window.pageYOffset;
    const offsetPosition = elementPosition - offset;

    window.scrollTo({
        top: offsetPosition,
        behavior: 'smooth'
    });
}

// Usage: smoothScrollTo('#section', 80);

// ----------------
// Copy to Clipboard
// ----------------
async function copyToClipboard(text) {
    try {
        await navigator.clipboard.writeText(text);
        return true;
    } catch (err) {
        console.error('Failed to copy:', err);
        return false;
    }
}

// Usage: await copyToClipboard('Hello World');

// ----------------
// Local Storage Helper
// ----------------
const storage = {
    set: (key, value) => {
        try {
            localStorage.setItem(key, JSON.stringify(value));
            return true;
        } catch (e) {
            console.error('Storage error:', e);
            return false;
        }
    },
    get: (key, defaultValue = null) => {
        try {
            const item = localStorage.getItem(key);
            return item ? JSON.parse(item) : defaultValue;
        } catch (e) {
            console.error('Storage error:', e);
            return defaultValue;
        }
    },
    remove: (key) => localStorage.removeItem(key),
    clear: () => localStorage.clear()
};

// Usage: storage.set('theme', 'dark'); const theme = storage.get('theme');

// ----------------
// DOM Ready Helper
// ----------------
function ready(fn) {
    if (document.readyState !== 'loading') {
        fn();
    } else {
        document.addEventListener('DOMContentLoaded', fn);
    }
}

// Usage: ready(() => console.log('DOM is ready!'));

// ----------------
// Query Selector Helpers
// ----------------
const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => [...document.querySelectorAll(selector)];

// Usage: const header = $('.header'); const items = $$('.item');

// ----------------
// Toggle Class
// ----------------
function toggleClass(selector, className) {
    const elements = typeof selector === 'string' ? $$(selector) : [selector];
    elements.forEach(el => el?.classList.toggle(className));
}

// Usage: toggleClass('.menu', 'open');

// ----------------
// Animation Frame Loop
// ----------------
function animate(callback, duration = null) {
    const startTime = performance.now();

    function loop(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = duration ? Math.min(elapsed / duration, 1) : elapsed;

        callback(progress, elapsed);

        if (!duration || progress < 1) {
            requestAnimationFrame(loop);
        }
    }

    requestAnimationFrame(loop);
}

// Usage: animate((progress) => console.log(progress), 1000);

// ----------------
// Random Number
// ----------------
const random = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;

// Usage: const dice = random(1, 6);

// ----------------
// Shuffle Array
// ----------------
function shuffle(array) {
    const arr = [...array];
    for (let i = arr.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
}

// Usage: const shuffled = shuffle([1, 2, 3, 4, 5]);

// ----------------
// Format Date
// ----------------
function formatDate(date, format = 'short') {
    const d = new Date(date);
    const formats = {
        short: { month: 'short', day: 'numeric', year: 'numeric' },
        long: { month: 'long', day: 'numeric', year: 'numeric' },
        time: { hour: '2-digit', minute: '2-digit' }
    };
    return new Intl.DateTimeFormat('en-US', formats[format] || formats.short).format(d);
}

// Usage: formatDate(new Date(), 'long');

// ----------------
// Wait/Sleep Function
// ----------------
const wait = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Usage: await wait(1000); // Wait 1 second

// ----------------
// Fetch with Timeout
// ----------------
async function fetchWithTimeout(url, options = {}, timeout = 5000) {
    const controller = new AbortController();
    const id = setTimeout(() => controller.abort(), timeout);

    try {
        const response = await fetch(url, {
            ...options,
            signal: controller.signal
        });
        clearTimeout(id);
        return response;
    } catch (error) {
        clearTimeout(id);
        throw error;
    }
}

// Usage: const response = await fetchWithTimeout('/api/data', {}, 3000);

// ----------------
// Create Element Helper
// ----------------
function createElement(tag, props = {}, children = []) {
    const element = document.createElement(tag);

    Object.entries(props).forEach(([key, value]) => {
        if (key === 'class') {
            element.className = value;
        } else if (key === 'style' && typeof value === 'object') {
            Object.assign(element.style, value);
        } else if (key.startsWith('on')) {
            element.addEventListener(key.slice(2).toLowerCase(), value);
        } else {
            element.setAttribute(key, value);
        }
    });

    children.forEach(child => {
        element.appendChild(
            typeof child === 'string' ? document.createTextNode(child) : child
        );
    });

    return element;
}

// Usage: const div = createElement('div', { class: 'card', id: 'test' }, ['Hello!']);

// ----------------
// Mobile Detection
// ----------------
const isMobile = () => /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);

// Usage: if (isMobile()) { /* mobile-specific code */ }

// ----------------
// Screen Size Checker
// ----------------
const screenSize = {
    isMobile: () => window.innerWidth < 768,
    isTablet: () => window.innerWidth >= 768 && window.innerWidth < 1024,
    isDesktop: () => window.innerWidth >= 1024
};

// Usage: if (screenSize.isMobile()) { /* mobile layout */ }

// ----------------
// Export all utilities
// ----------------
export {
    initIntersectionObserver,
    debounce,
    throttle,
    smoothScrollTo,
    copyToClipboard,
    storage,
    ready,
    $,
    $$,
    toggleClass,
    animate,
    random,
    shuffle,
    formatDate,
    wait,
    fetchWithTimeout,
    createElement,
    isMobile,
    screenSize
};
