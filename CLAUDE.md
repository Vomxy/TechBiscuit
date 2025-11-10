# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **TheTechBiscuit** (thetechbiscuit.com), a personal blog built with Hugo static site generator. The site is authored by Zack Baxter and focuses on technology, personal projects, and information security topics. Content is written in Obsidian and synced to this Hugo site before being built and deployed to GitHub Pages.

## Build and Deployment Commands

### Local Development
- `hugo server` - Start Hugo development server with live reload
- `hugo server -D` - Start server including draft posts
- `hugo` - Build the site (output goes to `public/` directory)
- `hugo --minify` - Build with minified output (production-ready)

### Publishing Workflow
The primary deployment method uses the automated script:
- `./updateblog.sh` - Complete workflow that:
  1. Syncs posts from Obsidian vault to `content/` directory using rsync
  2. Processes Markdown files with `python3 images.py` to convert Obsidian image links (`[[image.webp]]`) to Hugo-compatible format (`![Image Description](/images/image.webp)`)
  3. Copies images from Obsidian attachments to `static/images/`
  4. Builds the Hugo site
  5. Commits changes with timestamp message
  6. Pushes to GitHub main branch

**Important:** The `updateblog.sh` script requires specific Obsidian vault paths to exist:
- Source: `/home/natefletcher/Documents/TheTechBiscuit Vault/01 - Projects/TheTechBiscuit/blog`
- Attachments: `/home/natefletcher/Documents/TheTechBiscuit Vault/99 - Meta/01 - Attachments`

### GitHub Actions
Pushing to the main branch triggers `.github/workflows/hugo.yml` which:
- Uses Hugo version 0.128.0 (extended)
- Builds with `--minify` flag
- Deploys to GitHub Pages automatically

## Architecture and Structure

### Content Organization
- `content/blog/` - Blog post markdown files with frontmatter
- `content/creative/` - Creative writing section (poetry, wisdom, adventure, resilience)
- Blog posts use naming convention like `001 what-is-techbiscuit.md`, `002 my-digital-toolbox.md`

### Frontmatter Structure

**Blog posts** require YAML frontmatter:
```yaml
title: "Post Title"
date: YYYY-MM-DD
draft: false
summary: "Brief summary"
description: "SEO description"
keywords: "comma, separated, keywords"
og_image: "/images/image-name.jpg"
tags: ["Tag1", "Tag2"]
```

**Creative works** use different frontmatter:
```yaml
title: "Work Title"
author: "Author Name"
category: "poetry|resilience|wisdom|adventure"
theme: "theme name"
year: "YYYY"
description: "Brief description"
lines: ["poem line 1", "poem line 2", ...]
```

### Theme Architecture
- Custom theme: `techbiscuits` located in `themes/techbiscuits/`
- Minimum Hugo version required: 0.41.0

**Key Theme Components:**
- `layouts/_default/baseof.html` - Base wrapper with conditional main element for creative pages
- `layouts/index.html` - Homepage with hero section, recent blogs, and tabbed favorites
- `layouts/_default/single.html` - Blog post template with TOC and related posts
- `layouts/creative/list.html` - Creative gallery with 3D flip cards and category filters
- `layouts/404.html` - Custom 404 page with interactive bug-finding game
- `layouts/partials/header.html` - Sticky header with mobile hamburger menu
- `layouts/partials/footer.html` - Footer with all embedded JavaScript
- `static/css/style.css` - 2,674 lines of comprehensive styling with CSS variables

**CSS Architecture:**
- CSS variables system for colors, spacing, typography, shadows, border-radius
- Primary brand color: `--accent: #e69e56` (burnt orange)
- Responsive breakpoints: 768px (mobile), 480px (small mobile)
- Mobile-first approach with 44px minimum touch targets
- Glassmorphism header with `backdrop-filter: blur(20px)`
- Progress bar that tracks scroll position
- Advanced animations: gradient sweeps, 3D card flips, stagger effects, shimmer loading

### JavaScript Functionality
All JavaScript is embedded in `layouts/partials/footer.html`:

1. **Tab Navigation System** - Accessible tabs with ARIA, keyboard navigation (Arrow keys, Home, End)
2. **Mobile Menu Toggle** - Hamburger menu (☰ ↔ ✕) with click-outside-to-close
3. **Scroll Effects** - Progress bar tracking, header shadow on scroll (debounced 20ms)
4. **Image Loading** - Progressive fade-in with `.loaded` class
5. **Lazy Loading** - IntersectionObserver for `.lazy-load` elements (50px margin)
6. **Stagger Animations** - Blog grid cards animate in sequence on scroll
7. **Smooth Scrolling** - Anchor links with offset for fixed header

**404 Game** (`layouts/partials/game.html`):
- 3x3 grid memory game to find the "cookie bite" among "code" icons
- Keyboard support, shake/pulse animations

**Creative Gallery Filters**:
- JavaScript-based category/theme filtering
- Card flip animations on click

### Image Handling Pipeline
Images flow through multiple stages:

1. **In Obsidian:** Use wiki-link syntax `[[image.webp]]`
2. **Processing (`images.py`):** Regex converts to `![Image Description](/images/image.webp)` with space → `%20` encoding
3. **Storage:** Images copied from Obsidian attachments to `static/images/`
4. **Rendering:** Custom `layouts/_default/_markup/render-image.html` adds `loading="lazy"`
5. **Display:** All images served from `/images/` URL path

**Logo Assets:**
- SVG: `/static/images/logo.svg` (main), `/static/images/favicon.svg`
- PNG: `logo-192.png`, `logo-180.png`, `logo-512.png`, `logo-1024.png`
- Social card: `social-card.png` (1200x630 for Open Graph)

### Configuration
Site configuration in `config.toml`:
- Base URL: https://www.thetechbiscuit.com
- Permalink structure: `/blog/:filename/`
- Content directory: `content`
- Theme: `techbiscuits`
- Author: Zack Baxter
- Twitter handle: @onlytechbiscuit

### SEO & Metadata
Head partial includes:
- Open Graph tags (article type for blog with publish time & tags)
- Twitter Card meta (summary_large_image)
- Canonical URLs
- Theme color: `#e69e56`
- Multiple favicon formats (SVG, PNG 192x192, Apple touch icon)

## Development Workflow

### Adding Blog Posts (via Obsidian)
1. Write content in Obsidian vault at `/home/natefletcher/Documents/TheTechBiscuit Vault/01 - Projects/TheTechBiscuit/blog`
2. Use wiki-link syntax for images: `[[image.webp]]`
3. Place images in Obsidian attachments folder: `/home/natefletcher/Documents/TheTechBiscuit Vault/99 - Meta/01 - Attachments`
4. Run `./updateblog.sh` to sync, process, build, commit, and deploy

### Working Directly on Theme/Styles
1. Edit files in `themes/techbiscuits/` (layouts, CSS, partials)
2. Test locally: `hugo server` (live reload at http://localhost:1313)
3. CSS is at `themes/techbiscuits/static/css/style.css` (2,674 lines)
4. JavaScript is embedded in `layouts/partials/footer.html`
5. Mobile menu toggle button is in `layouts/partials/header.html`

### Testing Mobile Responsiveness
- Primary breakpoint: 768px (mobile navigation, single-column layout)
- Small mobile: 480px (reduced font sizes, tighter spacing)
- Test mobile menu: hamburger button shows below 768px
- Touch targets meet 44px minimum for accessibility

### Modifying Homepage Sections
- **Hero section:** `layouts/index.html` lines 2-23
- **Recent blogs grid:** `layouts/index.html` lines 30-54
- **Favorites tabs:** `layouts/index.html` lines 64-153
  - Books tab content: lines 69-84
  - Websites/Tools tab: lines 86-119
  - Podcasts tab: lines 121-152

### CSS Variable System
All theme colors, spacing, and styles use CSS variables defined in `style.css` lines 149-208:
```css
:root {
  --accent: #e69e56;          /* Brand orange */
  --background: #f5f5f5;       /* Light grey */
  --text: #333333;             /* Dark grey text */
  --footer-bg: #0d131a;        /* Dark footer */
  --spacing-sm: 1rem;          /* Base spacing unit */
  --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.1);
  /* ... many more */
}
```

When changing colors, update CSS variables instead of hardcoded values.

### Accessibility Notes
- All interactive elements have ARIA labels
- Tab navigation uses proper ARIA roles
- Mobile menu has `aria-expanded` attribute
- Images have alt text via custom render hook
- Focus states use `outline: 2px solid var(--accent)`
- Keyboard navigation supported (tabs, 404 game)

## Important File Locations
- Site config: `config.toml`
- Blog posts: `content/blog/*.md`
- Creative works: `content/creative/*.md`
- Theme layouts: `themes/techbiscuits/layouts/`
- Main CSS: `themes/techbiscuits/static/css/style.css`
- Theme images: `themes/techbiscuits/static/images/`
- Content images: `static/images/`
- Sync script: `updateblog.sh`
- Image processor: `images.py`
- GitHub workflow: `.github/workflows/hugo.yml`
- Issues log: `ISSUES_FOUND.md` (analysis document)
