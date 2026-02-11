#!/bin/bash
set -euo pipefail

# ============================================================================
# YK-Boilerplate — New Project Generator
# Creates a new iOS project from this template with your custom configuration.
# Single environment — no dev/staging/prod separation.
#
# Usage:
#   Local:  bash create-project.sh
#   Remote: bash <(curl -fsSL https://raw.githubusercontent.com/ersel95/boilerplate/main/create-project.sh)
# ============================================================================

REPO_URL="https://github.com/ersel95/boilerplate.git"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

TEMPLATE_DIR=""
CLONED_TEMP_DIR=""

# ── Resolve template directory ──────────────────────────────────────────────

resolve_template_dir() {
    # Check if running from within the template repo (local mode)
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null || echo ".")" && pwd)"

    if [ -f "$script_dir/project.yml" ] && [ -d "$script_dir/YK-Boilerplate" ]; then
        TEMPLATE_DIR="$script_dir"
        echo -e "${CYAN}Using local template: $TEMPLATE_DIR${NC}"
    else
        # Remote mode — clone repo to temp directory
        echo -e "${CYAN}Cloning template from GitHub...${NC}"
        CLONED_TEMP_DIR=$(mktemp -d)
        git clone --depth 1 "$REPO_URL" "$CLONED_TEMP_DIR" 2>&1 | while read -r line; do
            echo -e "  ${line}"
        done
        TEMPLATE_DIR="$CLONED_TEMP_DIR"
        echo -e "${GREEN}Template cloned.${NC}"
    fi
}

# ── Cleanup ─────────────────────────────────────────────────────────────────

cleanup() {
    if [ -n "$CLONED_TEMP_DIR" ] && [ -d "$CLONED_TEMP_DIR" ]; then
        rm -rf "$CLONED_TEMP_DIR"
    fi
}
trap cleanup EXIT

# ── Dependency checks ───────────────────────────────────────────────────────

check_dependencies() {
    local missing=()

    if ! command -v xcodegen &>/dev/null; then
        missing+=("xcodegen (brew install xcodegen)")
    fi

    if ! command -v git &>/dev/null; then
        missing+=("git")
    fi

    if ! command -v rsync &>/dev/null; then
        missing+=("rsync")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}Missing dependencies:${NC}"
        for dep in "${missing[@]}"; do
            echo -e "  - $dep"
        done
        exit 1
    fi
}

# ── Validation helpers ──────────────────────────────────────────────────────

validate_project_name() {
    local name="$1"
    # PascalCase: starts with uppercase letter, only alphanumeric, min 2 chars
    if [[ ! "$name" =~ ^[A-Z][a-zA-Z0-9]+$ ]]; then
        return 1
    fi
    return 0
}

validate_bundle_id() {
    local bundle="$1"
    # Reverse domain: at least two segments, lowercase + digits + hyphens
    if [[ ! "$bundle" =~ ^[a-z][a-z0-9-]*(\.[a-z][a-z0-9-]*)+$ ]]; then
        return 1
    fi
    return 0
}

# ── Collect inputs ──────────────────────────────────────────────────────────

collect_inputs() {
    echo -e "${BOLD}${CYAN}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║     YK-Boilerplate — New Project Setup      ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"

    # Project Name
    while true; do
        echo -e "${BOLD}Project Name${NC} (PascalCase, e.g. SuperApp):"
        read -r PROJECT_NAME
        if validate_project_name "$PROJECT_NAME"; then
            break
        fi
        echo -e "${RED}Invalid. Use PascalCase (start uppercase, alphanumeric only, min 2 chars).${NC}"
    done

    # Bundle ID
    while true; do
        echo ""
        echo -e "${BOLD}Bundle ID${NC} (e.g. com.company.superapp):"
        read -r BUNDLE_ID
        if validate_bundle_id "$BUNDLE_ID"; then
            break
        fi
        echo -e "${RED}Invalid. Use reverse domain notation (e.g. com.company.appname).${NC}"
    done

    # VxHub ID
    echo ""
    echo -e "${BOLD}VxHub ID${NC} (press Enter to skip):"
    read -r VXHUB_ID
    if [ -z "$VXHUB_ID" ]; then
        VXHUB_ID="YOUR_VXHUB_ID_HERE"
    fi

    # Target directory
    echo ""
    echo -e "${BOLD}Target directory${NC} (default: ~/Desktop/Projects):"
    read -r TARGET_DIR
    if [ -z "$TARGET_DIR" ]; then
        TARGET_DIR="$HOME/Desktop/Projects"
    fi
    # Expand tilde
    TARGET_DIR="${TARGET_DIR/#\~/$HOME}"

    # Derived values
    PROJECT_NAME_LOWER=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
    BUNDLE_ID_PREFIX=$(echo "$BUNDLE_ID" | sed 's/\.[^.]*$//')
    DEST_DIR="$TARGET_DIR/$PROJECT_NAME"
}

# ── Confirmation ────────────────────────────────────────────────────────────

show_summary() {
    echo ""
    echo -e "${BOLD}${BLUE}── Summary ──────────────────────────────────${NC}"
    echo -e "  Project Name:  ${GREEN}$PROJECT_NAME${NC}"
    echo -e "  Bundle ID:     ${GREEN}$BUNDLE_ID${NC}"
    echo -e "  URL Scheme:    ${GREEN}${PROJECT_NAME_LOWER}${NC}"
    echo -e "  VxHub ID:      ${GREEN}$VXHUB_ID${NC}"
    echo -e "  Output:        ${GREEN}$DEST_DIR${NC}"
    echo -e "${BLUE}──────────────────────────────────────────────${NC}"
    echo ""

    read -r -p "Proceed? (y/N) " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        exit 0
    fi
}

# ── Copy template ───────────────────────────────────────────────────────────

copy_template() {
    echo ""
    echo -e "${CYAN}Copying template...${NC}"

    if [ -d "$DEST_DIR" ]; then
        echo -e "${RED}Error: $DEST_DIR already exists. Aborting.${NC}"
        exit 1
    fi

    mkdir -p "$DEST_DIR"

    rsync -a \
        --exclude='.git' \
        --exclude='create-project.sh' \
        --exclude='*.xcodeproj' \
        --exclude='*.xcworkspace' \
        --exclude='.build' \
        --exclude='DerivedData' \
        --exclude='.DS_Store' \
        --exclude='VxHub-iOS' \
        "$TEMPLATE_DIR/" "$DEST_DIR/"

    echo -e "${GREEN}Template copied.${NC}"
}

# ── Rename directories & files ──────────────────────────────────────────────

rename_structure() {
    echo -e "${CYAN}Renaming directories and files...${NC}"

    # Rename main source folder: YK-Boilerplate → ProjectName
    if [ -d "$DEST_DIR/YK-Boilerplate" ]; then
        mv "$DEST_DIR/YK-Boilerplate" "$DEST_DIR/$PROJECT_NAME"
    fi

    # Rename app entry file: BoilerplateApp.swift → {ProjectName}App.swift
    local app_file="$DEST_DIR/$PROJECT_NAME/Application/BoilerplateApp.swift"
    if [ -f "$app_file" ]; then
        mv "$app_file" "$DEST_DIR/$PROJECT_NAME/Application/${PROJECT_NAME}App.swift"
    fi

    echo -e "${GREEN}Rename complete.${NC}"
}

# ── String replacements ────────────────────────────────────────────────────

replace_in_file() {
    local file="$1"
    local search="$2"
    local replace="$3"

    if [ -f "$file" ]; then
        perl -i -pe "s/\Q${search}\E/${replace}/g" "$file"
    fi
}

replace_in_all_files() {
    local search="$1"
    local replace="$2"

    find "$DEST_DIR" -type f \( \
        -name "*.swift" -o \
        -name "*.xcconfig" -o \
        -name "*.yml" -o \
        -name "*.yaml" -o \
        -name "*.md" -o \
        -name "*.plist" -o \
        -name "*.json" -o \
        -name "*.strings" -o \
        -name "*.storyboard" -o \
        -name "*.xib" \
    \) -exec perl -i -pe "s/\Q${search}\E/${replace}/g" {} +
}

apply_replacements() {
    echo -e "${CYAN}Applying string replacements...${NC}"

    # Order matters: specific → general to avoid partial matches

    # 1. Bundle IDs — all environments use same bundle ID (no .dev/.staging suffix)
    replace_in_all_files "com.yourcompany.boilerplate.dev" "$BUNDLE_ID"
    replace_in_all_files "com.yourcompany.boilerplate.staging" "$BUNDLE_ID"
    replace_in_all_files "com.yourcompany.boilerplate" "$BUNDLE_ID"
    replace_in_all_files "com.yourcompany" "$BUNDLE_ID_PREFIX"

    # 2. Directory/target name
    replace_in_all_files "YK-Boilerplate" "$PROJECT_NAME"

    # 3. App struct name
    replace_in_all_files "BoilerplateApp" "${PROJECT_NAME}App"

    # 4. Product names — all environments use same name (no Dev/Staging suffix)
    replace_in_all_files "Boilerplate Dev" "$PROJECT_NAME"
    replace_in_all_files "Boilerplate Staging" "$PROJECT_NAME"
    replace_in_all_files "PRODUCT_NAME = Boilerplate" "PRODUCT_NAME = ${PROJECT_NAME}"

    # 5. Display name / splash text
    replace_in_all_files "YK Boilerplate" "$PROJECT_NAME"

    # 6. URL schemes — all environments use same scheme (no dev/staging suffix)
    replace_in_all_files "boilerplatedev" "$PROJECT_NAME_LOWER"
    replace_in_all_files "boilerplatestaging" "$PROJECT_NAME_LOWER"

    # 7. Prod URL scheme
    local prod_config="$DEST_DIR/$PROJECT_NAME/Core/BuildConfiguration/Prod.xcconfig"
    replace_in_file "$prod_config" "URL_SCHEME = boilerplate" "URL_SCHEME = ${PROJECT_NAME_LOWER}"

    # 8. project.yml Release product name (standalone "Boilerplate" without prefix)
    local project_yml="$DEST_DIR/project.yml"
    replace_in_file "$project_yml" 'PRODUCT_NAME: "Boilerplate"' "PRODUCT_NAME: \"${PROJECT_NAME}\""

    # 9. Any remaining standalone "Boilerplate" in CLAUDE.md
    local claude_md="$DEST_DIR/CLAUDE.md"
    replace_in_file "$claude_md" "Boilerplate" "$PROJECT_NAME"

    # 10. VxHub ID
    replace_in_all_files "YOUR_VXHUB_ID_HERE" "$VXHUB_ID"

    echo -e "${GREEN}Replacements applied.${NC}"
}

# ── Generate .gitignore ─────────────────────────────────────────────────────

create_gitignore() {
    cat > "$DEST_DIR/.gitignore" << 'GITIGNORE'
# Xcode
*.xcodeproj/project.xcworkspace/
*.xcodeproj/xcuserdata/
*.xcworkspace/xcuserdata/
xcuserdata/
*.xccheckout
*.moved-aside
*.xcuserstate
*.xcscmblueprint

# Build
build/
DerivedData/
*.ipa
*.dSYM.zip
*.dSYM

# Swift Package Manager
.build/
.swiftpm/
Package.resolved

# CocoaPods (if ever used)
Pods/

# Misc
.DS_Store
*.hmap
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
*.swp
*~

# Environment / Secrets
*.env
.env.*

# Fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output
GITIGNORE
}

# ── XcodeGen & Git ──────────────────────────────────────────────────────────

generate_project() {
    echo -e "${CYAN}Running xcodegen...${NC}"
    cd "$DEST_DIR"
    xcodegen generate
    echo -e "${GREEN}Xcode project generated.${NC}"
}

init_git() {
    echo -e "${CYAN}Initializing git repository...${NC}"
    cd "$DEST_DIR"
    create_gitignore
    git init
    git add -A
    git commit -m "Initial commit — $PROJECT_NAME from YK-Boilerplate template"
    echo -e "${GREEN}Git repository initialized.${NC}"
}

# ── Success ─────────────────────────────────────────────────────────────────

show_success() {
    echo ""
    echo -e "${BOLD}${GREEN}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║            Project Created!                  ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "  ${BOLD}Location:${NC} $DEST_DIR"
    echo ""
    echo -e "  ${BOLD}Next steps:${NC}"
    echo -e "  1. Open ${CYAN}$DEST_DIR/${PROJECT_NAME}.xcodeproj${NC}"
    echo -e "  2. Select your team in Signing & Capabilities"
    echo -e "  3. Update assets (AppIcon, colors, fonts)"
    if [ "$VXHUB_ID" = "YOUR_VXHUB_ID_HERE" ]; then
        echo -e "  4. Set your VxHub ID in xcconfig files"
    fi
    echo ""
    echo -e "  ${BOLD}Claude Code ready:${NC} CLAUDE.md is configured for your project."
    echo ""
}

# ── Main ────────────────────────────────────────────────────────────────────

main() {
    check_dependencies
    resolve_template_dir
    collect_inputs
    show_summary
    copy_template
    rename_structure
    apply_replacements
    generate_project
    init_git
    show_success
}

main
