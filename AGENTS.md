# Repository Guidelines

## Project Structure & Modules
- Hugo root: `config.toml`, `content/` (blog, creative), `static/` (site assets, images, JS, icons), `layouts/` (project overrides).
- Theme: `themes/techbiscuits/` with `layouts/` (templates/partials), `static/css/` (base.css, components.css), `static/images/`, and SVG sprite at `static/icons/sprite.svg`.
- Automation: `updateblog.sh` (sync from Obsidian, process images, build, commit, push) and `images.py` (wiki-link image conversion).
- CI/CD: `.github/workflows/hugo.yml` builds with Hugo extended; output in `public/`.

## Build, Test, and Development Commands
- `hugo server` — run local dev server with live reload.
- `hugo server -D` — include drafts.
- `hugo --minify` — production build to `public/`.
- `./updateblog.sh` — sync from Obsidian, process images, build, commit (timestamp), push.
> Update paths in scripts if your Obsidian vault differs.

## Coding Style & Naming
- Templates: Go templates; reuse partials/blocks under `themes/techbiscuits/layouts/partials/`.
- CSS: Keep edits in `themes/techbiscuits/static/css/`; use provided CSS variables, gradients, and utility classes. Avoid inline styles.
- Content: blog filenames numeric-prefix + slug (`content/blog/00x-title.md`); frontmatter must include `title`, `date`, `summary`, `description`, `keywords`, `og_image`, `tags`.
- Icons: prefer the SVG sprite (`/icons/sprite.svg#id`); avoid external icon kits.
- ASCII only; comments brief and purposeful.

## Testing Guidelines
- No automated tests; primary check is a clean Hugo build. Run `hugo --minify` before pushing.
- Manual spot checks: home hero/CTAs, blog list + pagination, single post hero/TOC/related, search (success/error/no-JS), creative filters/flip, 404 game and consent banner/analytics.

## Commit & PR Guidelines
- Commits: short, imperative (e.g., “Refine hero buttons”). The automation script uses “New Blog Post on <timestamp>”.
- PRs: describe scope and risk; note build status (`hugo --minify`); include before/after screenshots for visual changes; link issues when applicable. Call out CSP/analytics changes explicitly.

## Security & Configuration
- CSP is in `layouts/partials/head.html`; keep hosts aligned with actual assets and the SVG sprite. Remove unused externals.
- Cookie/analytics consent lives in `baseof.html` + `/js/main.js`; keep storage keys consistent.
- Custom domain via `CNAME`; ensure `baseURL` in `config.toml` matches deployment.
