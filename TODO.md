# TheTechBiscuit - TODO (Path to 10/10)

Grouped by urgency/impact first, and marked when tasks can be done in parallel with AI coding assistance (Codex/LLM).

## 🔴 Immediate / Launch Blockers
- [x] Harden CSP to drop `unsafe-inline`: move inline scripts to `static/js/`, add nonce for JSON-LD, align script/font hosts.
- [x] Canonical asset alignment: ensure all preloads are used (fonts/css), remove unused kit calls, and whitelist only needed domains.
- [ ] Build guardrails: add `package.json` with `npm run build` (`hugo --minify`) and `npm run test` (link checker + `hugo --minify`), wire into CI. **Skipped for now**
- [x] Content schema hygiene: enforce frontmatter via archetype; audit `content/blog` for missing tags/keywords/og_image and empty arrays.

## 🟠 High Impact (Do Next)
- Dark mode toggle with localStorage + `prefers-color-scheme` fallback; accessible toggle in header. **Deferred (per request)**
- [x] Related posts by shared tags (exclude current, randomize within tag match).
- [x] Blog listing: sort by publish date and add pagination with prev/next rel links and canonical handling.
- [x] Search resilience: debounce, error state for index fetch, no-JS fallback (server list), highlight matches.
- [x] Image pipeline: extend `images.py` for alt placeholders, non-WebP copies, and failures on missing attachments; optional AVIF/WebP generation hook (partial: copy + alt + fail on missing).
- [ ] Performance: inline critical CSS for hero/header, defer non-critical JS, self-host or single-request fonts with `font-display: swap`.
- [ ] Accessibility polish: consistent focus states, tab order through hero CTA, ARIA on search/tag filters, skip-link target on every template.

## 🟡 Medium (Polish & Growth)
- Commenting: add privacy-friendly option (Staticman/Utterances) gated by consent. **Parallel-ready (AI)**.
- Analytics depth: Plausible custom events for nav, hero CTAs, search usage; keep consent key in sync. **Parallel-ready (AI)**.
- Structured data expansion: BreadcrumbList on lists, FAQ/HowTo where applicable. **Parallel-ready (AI)**.
- [x] Creative gallery UX: keyboard flip/close, SR announcements, theme filter chips.
- Visual rhythm: consistent section dividers, reduce inline JS by moving micro-animations to CSS. **Parallel-ready (AI)**.
- [x] 404 game polish: retry UX, scorekeeping, non-blocking for screen readers.

## 🟢 Maintenance / Nice-to-Have
- Regular Hugo bumps and theme `min_version`, documented in `CLAUDE.md`. **Parallel-ready (AI)**.
- Image audit: convert large PNG/JPG to WebP/AVIF, add width/height metadata. **Parallel-ready (AI)**.
- Backups: GH Action/cron to snapshot Obsidian source and `static/images`. **Parallel-ready (AI)**.
- Multi-language scaffold: enable `i18n/`, add language switcher placeholder, ensure hreflang readiness. **Parallel-ready (AI)**.

## Workflow Reminders
- Core commands: `hugo server`, `hugo server -D` (drafts), `hugo --minify`, `./updateblog.sh` (sync/build/commit/push). Update Obsidian paths in scripts before running.
- Test before push: `hugo --minify` and manual checks for home, blog list, single, search, creative, 404 game, consent/analytics.
- Keep changes in theme scope: `themes/techbiscuits/layouts/`, `themes/techbiscuits/static/css/`, and new `static/js/` for extracted scripts. Use ASCII and concise comments.
