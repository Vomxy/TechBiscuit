# TheTechBiscuit - Todo List

This file tracks ongoing and planned tasks for the website development and maintenance.

## ✅ Completed Tasks

- [x] HUGO-001: Update Hugo to latest extended version (theme min_version set to 0.128.0)
- [x] SEO-001: Rename blog post files to SEO-friendly slugs (removed spaces, used hyphens)
- [x] CSS-001: Split style.css into modular files (base.css and components.css)
- [x] IMG-001: Enhance image handling (added sizes attribute for responsive images)
- [x] BUILD-001: Test Hugo build after changes (successful build with 39 pages)

## 🔴 High Priority Groups

### SEC-001: Security & Privacy Enhancements (Implement together for comprehensive protection)
- [x] SEC-001: Add CSP headers and monitoring
- [x] SEC-002: Implement privacy-focused analytics (GDPR compliant)
- [x] SEC-003: Add cookie consent banner with minimal tracking

### UX-001: User Experience Improvements (Core UI features that can be developed in parallel)
- [ ] UX-001: Implement search feature with filters
- [ ] UX-002: Add dark mode toggle with localStorage persistence (dark mode default)
- [ ] UX-004: Add commenting system (e.g., via Disqus or static)
- [ ] UX-005: Polish accessibility (keyboard navigation, focus indicators)

## 🟡 Medium Priority Groups

### PERF-001: Performance Optimizations (Optimize load times and user experience)
- [ ] PERF-001: Add critical CSS inlining, preload fonts, service worker
- [ ] PERF-002: Implement skeleton loaders and lazy loading

### SEO-001: SEO Enhancements (Improve discoverability)
- [ ] SEO-002: Add structured data, breadcrumb navigation, sitemap submission
- [ ] SEO-003: Enhance meta tags and Open Graph images

### ANALYTICS-001: Analytics Implementation (Monitor user engagement)
- [ ] ANALYTICS-001: Set up Google Analytics 4 with privacy controls

## 🟢 Low Priority Groups

### DEV-001: Development Experience (Improve workflow)
- [ ] DEV-001: Add package.json with scripts and automated testing
- [ ] SCRIPT-001: Improve automation scripts (updateblog.sh and images.py)

### SCALE-001: Scalability Features (Prepare for growth)
- [ ] SCALE-001: Implement pagination for blog posts
- [ ] SCALE-002: Add multi-language support

### CONTENT-001: Content Management (Streamline content creation)
- [ ] CONTENT-002: Fill empty frontmatter fields in posts
- [ ] CONTENT-003: Add content scheduling and draft previews

### MAINT-001: Maintenance Tasks (Ongoing upkeep)
- [ ] MAINT-001: Regularly update Hugo to latest version
- [ ] MAINT-002: Review and optimize images (WebP/AVIF conversion)
- [ ] MAINT-003: Test mobile responsiveness on new devices
- [ ] MAINT-004: Audit for broken links and accessibility issues
- [ ] MAINT-005: Backup Obsidian vault and sync paths

## 📝 Notes

- Obsidian sync paths: Source `/home/natefletcher/Documents/TheTechBiscuit Vault/01 - Projects/TheTechBiscuit/blog`, Attachments `/home/natefletcher/Documents/TheTechBiscuit Vault/99 - Meta/01 - Attachments`
- Build command: `hugo --minify`
- Deploy via: `./updateblog.sh` or GitHub Actions
- Theme: Custom `techbiscuits` with CSS variables system

## 🚀 Deployment Checklist

Before deploying updates:
- [ ] Run `hugo --minify` for production build
- [ ] Test all links and functionality
- [ ] Check mobile responsiveness
- [ ] Verify images load correctly
- [ ] Push to main branch for automatic deployment
