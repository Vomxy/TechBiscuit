#!/bin/bash

# ╭──────────────────────────────────────────────────────────╮
# │  VIBE CODING CLI - TechBiscuit Development Tool         │
# │  Rapid prototyping and iteration for Hugo blog          │
# ╰──────────────────────────────────────────────────────────╯

set -e

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Project paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$PROJECT_ROOT/themes/techbiscuits"
VIBE_DIR="$PROJECT_ROOT/vibe-coding"
COMPONENTS_DIR="$VIBE_DIR/components"
PLAYGROUND_DIR="$PROJECT_ROOT/content/vibe"

# ASCII Art Banner
show_banner() {
    echo -e "${PURPLE}"
    cat << "EOF"
    ╦  ╦╦╔╗ ╔═╗  ╔═╗╔═╗╔╦╗╦╔╗╔╔═╗
    ╚╗╔╝║╠╩╗║╣   ║  ║ ║ ║║║║║║ ╦
     ╚╝ ╩╚═╝╚═╝  ╚═╝╚═╝═╩╝╩╝╚╝╚═╝

    🍪 TechBiscuit Development Framework
EOF
    echo -e "${NC}"
}

# Help menu
show_help() {
    show_banner
    echo -e "${BOLD}USAGE:${NC}"
    echo -e "  ./vibe.sh ${CYAN}<command>${NC} [options]"
    echo ""
    echo -e "${BOLD}COMMANDS:${NC}"
    echo ""
    echo -e "  ${GREEN}dev${NC}              Start Hugo development server"
    echo -e "  ${GREEN}dev:drafts${NC}       Start Hugo server with draft posts"
    echo -e "  ${GREEN}dev:playground${NC}   Start server focused on playground content"
    echo ""
    echo -e "  ${GREEN}new:component${NC}    Create a new reusable component"
    echo -e "  ${GREEN}new:shortcode${NC}    Create a new Hugo shortcode"
    echo -e "  ${GREEN}new:page${NC}         Create a new playground test page"
    echo ""
    echo -e "  ${GREEN}playground${NC}       Open the style playground"
    echo -e "  ${GREEN}test${NC}             Quick build test (no minification)"
    echo -e "  ${GREEN}build${NC}            Production build with minification"
    echo ""
    echo -e "  ${GREEN}clean${NC}            Clean build artifacts and caches"
    echo -e "  ${GREEN}refresh${NC}          Clean + rebuild from scratch"
    echo ""
    echo -e "  ${GREEN}sync${NC}             Run the full blog sync workflow"
    echo -e "  ${GREEN}deploy${NC}           Build and deploy to GitHub Pages"
    echo ""
    echo -e "  ${GREEN}components${NC}       List all available components"
    echo -e "  ${GREEN}stats${NC}            Show project statistics"
    echo ""
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo -e "  ./vibe.sh dev              ${CYAN}# Start local development${NC}"
    echo -e "  ./vibe.sh new:component    ${CYAN}# Create new component${NC}"
    echo -e "  ./vibe.sh playground       ${CYAN}# Open style playground${NC}"
    echo ""
}

# Development server commands
cmd_dev() {
    echo -e "${BLUE}🚀 Starting Hugo development server...${NC}"
    hugo server --bind 0.0.0.0 --port 1313 --navigateToChanged
}

cmd_dev_drafts() {
    echo -e "${BLUE}🚀 Starting Hugo server with drafts...${NC}"
    hugo server -D --bind 0.0.0.0 --port 1313 --navigateToChanged
}

cmd_dev_playground() {
    echo -e "${BLUE}🎨 Starting playground mode...${NC}"
    echo -e "${CYAN}Visit: http://localhost:1313/vibe/playground/${NC}"
    hugo server -D --bind 0.0.0.0 --port 1313 --navigateToChanged
}

# Component creation
cmd_new_component() {
    echo -e "${PURPLE}✨ Creating new component...${NC}"
    read -p "Component name (e.g., card, button, hero): " component_name

    if [ -z "$component_name" ]; then
        echo -e "${RED}❌ Component name required${NC}"
        exit 1
    fi

    # Create component directory
    COMP_DIR="$COMPONENTS_DIR/templates/$component_name"
    mkdir -p "$COMP_DIR"

    # Create component files
    cat > "$COMP_DIR/template.html" << 'EOF'
<!-- Component: ${component_name} -->
<div class="component-${component_name}">
    <!-- Add your component HTML here -->
    <div class="component-content">
        {{ .Inner }}
    </div>
</div>
EOF

    cat > "$COMP_DIR/styles.css" << 'EOF'
/* Component: ${component_name} */
.component-${component_name} {
    /* Base styles */
    display: block;
    padding: var(--spacing-md);
    border-radius: var(--border-radius-md);
    background: var(--background);
}

.component-${component_name} .component-content {
    /* Content styles */
}

/* Hover/Active states */
.component-${component_name}:hover {
    transform: translateY(-2px);
    transition: transform 0.2s ease;
}

/* Responsive */
@media (max-width: 768px) {
    .component-${component_name} {
        padding: var(--spacing-sm);
    }
}
EOF

    cat > "$COMP_DIR/README.md" << EOF
# $component_name Component

## Usage

\`\`\`html
<!-- Include in your template -->
{{ partial "components/${component_name}.html" . }}
\`\`\`

## Props

- Add props documentation here

## Examples

Add usage examples here

## Notes

Created: $(date +%Y-%m-%d)
EOF

    echo -e "${GREEN}✅ Component created at: $COMP_DIR${NC}"
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  1. Edit template.html for markup"
    echo -e "  2. Add styles to styles.css"
    echo -e "  3. Copy to theme partials when ready"
}

cmd_new_shortcode() {
    echo -e "${PURPLE}✨ Creating new shortcode...${NC}"
    read -p "Shortcode name (e.g., callout, video, gallery): " shortcode_name

    if [ -z "$shortcode_name" ]; then
        echo -e "${RED}❌ Shortcode name required${NC}"
        exit 1
    fi

    read -p "Description: " description

    SHORTCODE_DIR="$THEME_DIR/layouts/shortcodes"
    mkdir -p "$SHORTCODE_DIR"

    cat > "$SHORTCODE_DIR/${shortcode_name}.html" << 'EOF'
{{/*
    Shortcode: ${shortcode_name}
    Description: ${description}
    Usage: {{< ${shortcode_name} param="value" >}}content{{< /${shortcode_name} >}}
*/}}

<div class="shortcode-${shortcode_name}">
    {{- if .Get "param" -}}
        <!-- Use param: {{ .Get "param" }} -->
    {{- end -}}

    {{- with .Inner -}}
        {{ . | markdownify }}
    {{- end -}}
</div>
EOF

    echo -e "${GREEN}✅ Shortcode created: ${shortcode_name}.html${NC}"
    echo -e "${CYAN}Location: $SHORTCODE_DIR/${shortcode_name}.html${NC}"
    echo -e "${YELLOW}Remember to add corresponding CSS styles!${NC}"
}

cmd_new_page() {
    echo -e "${PURPLE}✨ Creating new playground page...${NC}"
    read -p "Page name (e.g., test-cards, experiment-layout): " page_name

    if [ -z "$page_name" ]; then
        echo -e "${RED}❌ Page name required${NC}"
        exit 1
    fi

    mkdir -p "$PLAYGROUND_DIR"

    cat > "$PLAYGROUND_DIR/${page_name}.md" << EOF
---
title: "${page_name}"
date: $(date +%Y-%m-%d)
draft: true
layout: "single"
---

# Vibe Coding: ${page_name}

Test your components and experiments here!

## Component Test

Add your experimental code below:

---

**Created:** $(date +"%Y-%m-%d %H:%M:%S")
EOF

    echo -e "${GREEN}✅ Playground page created${NC}"
    echo -e "${CYAN}Location: $PLAYGROUND_DIR/${page_name}.md${NC}"
    echo -e "${YELLOW}Start dev server to view: ./vibe.sh dev:playground${NC}"
    echo -e "${YELLOW}URL: http://localhost:1313/vibe/${page_name}/${NC}"
}

# Playground
cmd_playground() {
    echo -e "${PURPLE}🎨 Opening Style Playground...${NC}"

    PLAYGROUND_FILE="$PLAYGROUND_DIR/playground.md"
    mkdir -p "$PLAYGROUND_DIR"

    if [ ! -f "$PLAYGROUND_FILE" ]; then
        cat > "$PLAYGROUND_FILE" << 'EOF'
---
title: "Style Playground"
date: 2024-01-01
draft: true
layout: "single"
---

<style>
/* Experiment with styles here - changes reflect immediately! */
.vibe-test {
    padding: 2rem;
    background: linear-gradient(135deg, var(--accent) 0%, #ff6b6b 100%);
    border-radius: var(--border-radius-lg);
    color: white;
    text-align: center;
    margin: 2rem 0;
    box-shadow: var(--shadow-lg);
    transition: all 0.3s ease;
}

.vibe-test:hover {
    transform: translateY(-5px) scale(1.02);
    box-shadow: var(--shadow-xl);
}

.vibe-card-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
    margin: 2rem 0;
}

.vibe-card {
    padding: 1.5rem;
    background: white;
    border-radius: var(--border-radius-md);
    box-shadow: var(--shadow-md);
    border-left: 4px solid var(--accent);
}
</style>

# 🎨 Vibe Coding Style Playground

Experiment with CSS, HTML, and components here. Changes reload instantly!

<div class="vibe-test">
    <h2>✨ This is your canvas</h2>
    <p>Edit the styles above and see changes in real-time</p>
</div>

## Component Grid Test

<div class="vibe-card-grid">
    <div class="vibe-card">
        <h3>Card 1</h3>
        <p>Test your card styles</p>
    </div>
    <div class="vibe-card">
        <h3>Card 2</h3>
        <p>Experiment with layouts</p>
    </div>
    <div class="vibe-card">
        <h3>Card 3</h3>
        <p>Rapid iteration FTW</p>
    </div>
</div>

## Color Palette Test

<div style="display: flex; gap: 1rem; margin: 2rem 0;">
    <div style="width: 100px; height: 100px; background: var(--accent); border-radius: 8px;"></div>
    <div style="width: 100px; height: 100px; background: var(--text); border-radius: 8px;"></div>
    <div style="width: 100px; height: 100px; background: var(--background); border: 2px solid var(--text); border-radius: 8px;"></div>
</div>

## Quick Tips

1. Edit styles in the `<style>` block above
2. Add HTML/markdown below
3. Server auto-reloads on save
4. Copy working code to your theme

---

**Vibe on! 🍪**
EOF
    fi

    echo -e "${GREEN}✅ Playground ready!${NC}"
    echo -e "${CYAN}Starting dev server...${NC}"
    echo ""
    echo -e "${YELLOW}📍 Playground URL: http://localhost:1313/vibe/playground/${NC}"
    echo -e "${YELLOW}📝 Edit: $PLAYGROUND_FILE${NC}"
    echo ""
    cmd_dev_drafts
}

# Build commands
cmd_test() {
    echo -e "${BLUE}🧪 Running quick build test...${NC}"
    hugo --quiet
    echo -e "${GREEN}✅ Build successful!${NC}"
}

cmd_build() {
    echo -e "${BLUE}🏗️  Production build...${NC}"
    hugo --minify
    echo -e "${GREEN}✅ Production build complete!${NC}"
    echo -e "${CYAN}Output: $PROJECT_ROOT/public/${NC}"
}

# Clean commands
cmd_clean() {
    echo -e "${YELLOW}🧹 Cleaning build artifacts...${NC}"
    rm -rf public resources .hugo_build.lock
    echo -e "${GREEN}✅ Clean complete!${NC}"
}

cmd_refresh() {
    echo -e "${YELLOW}🔄 Full refresh...${NC}"
    cmd_clean
    cmd_build
    echo -e "${GREEN}✅ Refresh complete!${NC}"
}

# Sync and deploy
cmd_sync() {
    echo -e "${BLUE}🔄 Running blog sync workflow...${NC}"
    if [ -f "$PROJECT_ROOT/updateblog.sh" ]; then
        bash "$PROJECT_ROOT/updateblog.sh"
    else
        echo -e "${RED}❌ updateblog.sh not found${NC}"
        exit 1
    fi
}

cmd_deploy() {
    echo -e "${BLUE}🚀 Deploying to GitHub Pages...${NC}"
    cmd_build

    read -p "Commit message (default: 'Deploy updates'): " commit_msg
    commit_msg=${commit_msg:-"Deploy updates"}

    git add .
    git commit -m "$commit_msg"
    git push

    echo -e "${GREEN}✅ Deployed!${NC}"
}

# Info commands
cmd_components() {
    echo -e "${PURPLE}📦 Available Components:${NC}"
    echo ""

    if [ -d "$COMPONENTS_DIR/templates" ]; then
        for comp in "$COMPONENTS_DIR/templates"/*; do
            if [ -d "$comp" ]; then
                comp_name=$(basename "$comp")
                echo -e "  ${GREEN}●${NC} $comp_name"
                if [ -f "$comp/README.md" ]; then
                    desc=$(head -n 3 "$comp/README.md" | tail -n 1)
                    echo -e "    ${CYAN}$desc${NC}"
                fi
            fi
        done
    fi

    echo ""
    echo -e "${PURPLE}🔧 Hugo Shortcodes:${NC}"
    echo ""

    SHORTCODE_DIR="$THEME_DIR/layouts/shortcodes"
    if [ -d "$SHORTCODE_DIR" ]; then
        for shortcode in "$SHORTCODE_DIR"/*.html; do
            if [ -f "$shortcode" ]; then
                shortcode_name=$(basename "$shortcode" .html)
                echo -e "  ${GREEN}{{<${NC} $shortcode_name ${GREEN}>}}${NC}"
            fi
        done
    fi
}

cmd_stats() {
    echo -e "${PURPLE}📊 TechBiscuit Statistics:${NC}"
    echo ""

    blog_posts=$(find content/blog -name "*.md" 2>/dev/null | wc -l)
    creative_posts=$(find content/creative -name "*.md" 2>/dev/null | wc -l)
    css_lines=$(wc -l "$THEME_DIR/static/css/style.css" 2>/dev/null | awk '{print $1}')
    layouts=$(find "$THEME_DIR/layouts" -name "*.html" 2>/dev/null | wc -l)

    echo -e "  Blog Posts:      ${GREEN}$blog_posts${NC}"
    echo -e "  Creative Works:  ${GREEN}$creative_posts${NC}"
    echo -e "  CSS Lines:       ${GREEN}$css_lines${NC}"
    echo -e "  Layout Files:    ${GREEN}$layouts${NC}"
    echo ""

    if [ -d "$PLAYGROUND_DIR" ]; then
        playground_pages=$(find "$PLAYGROUND_DIR" -name "*.md" 2>/dev/null | wc -l)
        echo -e "  Playground Pages: ${CYAN}$playground_pages${NC}"
    fi
}

# Main command router
main() {
    # Create vibe directories if they don't exist
    mkdir -p "$VIBE_DIR"/{components/{templates,shortcodes,snippets},scripts,docs}

    case "${1:-help}" in
        dev)
            cmd_dev
            ;;
        dev:drafts)
            cmd_dev_drafts
            ;;
        dev:playground)
            cmd_dev_playground
            ;;
        new:component)
            cmd_new_component
            ;;
        new:shortcode)
            cmd_new_shortcode
            ;;
        new:page)
            cmd_new_page
            ;;
        playground)
            cmd_playground
            ;;
        test)
            cmd_test
            ;;
        build)
            cmd_build
            ;;
        clean)
            cmd_clean
            ;;
        refresh)
            cmd_refresh
            ;;
        sync)
            cmd_sync
            ;;
        deploy)
            cmd_deploy
            ;;
        components)
            cmd_components
            ;;
        stats)
            cmd_stats
            ;;
        help|--help|-h|*)
            show_help
            ;;
    esac
}

# Run main with all arguments
main "$@"
