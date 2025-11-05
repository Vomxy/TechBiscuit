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
- `content/creative/` - Creative writing section
- Blog posts use naming convention like `001 what-is-techbiscuit.md`, `002 my-digital-toolbox.md`

### Frontmatter Structure
Posts require YAML frontmatter with:
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

### Theme
- Custom theme: `techbiscuits` located in `themes/techbiscuits/`
- Theme structure follows standard Hugo conventions with layouts and static assets
- Minimum Hugo version required: 0.41.0

### Image Handling
Images are stored in `static/images/` and referenced in Markdown as `/images/filename.webp`. The `images.py` script handles conversion from Obsidian's wiki-link format to Hugo's Markdown image syntax, including URL-encoding spaces as `%20`.

### Configuration
Site configuration in `config.toml`:
- Base URL: https://www.thetechbiscuit.com
- Permalink structure: `/blog/:filename/`
- Content directory: `content`
- Theme: `techbiscuits`

## Development Workflow

When adding or editing blog posts:
1. Content is typically authored in Obsidian, not directly in this repository
2. The sync and build process is handled by `updateblog.sh`
3. Images should be in WebP format and placed in the Obsidian attachments folder
4. Use Obsidian's `[[image.webp]]` syntax; it will be converted automatically

When working directly on the Hugo site:
1. Edit files in `content/`, `themes/`, or `static/` as needed
2. Test locally with `hugo server`
3. Build with `hugo` to verify output
4. Commit and push to deploy via GitHub Actions

## Important File Locations
- Site config: `config.toml`
- Blog posts: `content/blog/*.md`
- Static assets: `static/images/`, `static/css/`, etc.
- Custom theme: `themes/techbiscuits/`
- Sync script: `updateblog.sh`
- Image processor: `images.py`
- GitHub workflow: `.github/workflows/hugo.yml`
