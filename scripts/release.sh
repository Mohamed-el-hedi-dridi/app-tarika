#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  release.sh — Script de release OTA pour Tarika
#
#  Usage :
#    ./scripts/release.sh patch    # 1.0.0 → 1.0.1  (correction)
#    ./scripts/release.sh minor    # 1.0.1 → 1.1.0  (nouveauté)
#    ./scripts/release.sh major    # 1.1.0 → 2.0.0  (refonte)
#
#  Prérequis :
#    - GitHub CLI (gh) installé et authentifié : brew install gh && gh auth login
#    - flutter dans le PATH
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Couleurs ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[•]${NC} $*"; }
success() { echo -e "${GREEN}[✔]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
error()   { echo -e "${RED}[✘]${NC} $*"; exit 1; }

# ── Vérifications ─────────────────────────────────────────────────────────────
command -v flutter >/dev/null 2>&1 || error "flutter introuvable dans le PATH"
command -v gh      >/dev/null 2>&1 || error "GitHub CLI (gh) introuvable — installe-le : brew install gh"
command -v jq      >/dev/null 2>&1 || error "jq introuvable — installe-le : brew install jq"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."
cd "$ROOT"

# ── Type de bump ──────────────────────────────────────────────────────────────
BUMP="${1:-patch}"
[[ "$BUMP" =~ ^(major|minor|patch)$ ]] || error "Argument invalide : utilise major, minor ou patch"

# ── Lire la version courante depuis pubspec.yaml ──────────────────────────────
CURRENT_LINE=$(grep '^version:' pubspec.yaml)
CURRENT_VERSION=$(echo "$CURRENT_LINE" | sed 's/version: //' | cut -d'+' -f1)
CURRENT_BUILD=$(echo "$CURRENT_LINE"   | sed 's/version: //' | cut -d'+' -f2)

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case "$BUMP" in
  major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR+1)); PATCH=0 ;;
  patch) PATCH=$((PATCH+1)) ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
NEW_BUILD=$((CURRENT_BUILD+1))
TAG="v${NEW_VERSION}"

echo ""
info "Version actuelle : ${CURRENT_VERSION}+${CURRENT_BUILD}"
info "Nouvelle version : ${NEW_VERSION}+${NEW_BUILD}  (tag: ${TAG})"
echo ""

# ── Changelog interactif ──────────────────────────────────────────────────────
echo -e "${YELLOW}Décris les changements (Entrée pour finir) :${NC}"
read -r CHANGELOG
[[ -z "$CHANGELOG" ]] && CHANGELOG="Mise à jour ${NEW_VERSION}"

# ── Confirmation ─────────────────────────────────────────────────────────────
echo ""
warn "Récapitulatif :"
echo "  Version   : ${NEW_VERSION}+${NEW_BUILD}"
echo "  Tag       : ${TAG}"
echo "  Changelog : ${CHANGELOG}"
echo ""
read -rp "Continuer ? [o/N] " CONFIRM
[[ "$CONFIRM" =~ ^[oOyY]$ ]] || { warn "Annulé."; exit 0; }

# ── 1. Mettre à jour pubspec.yaml ─────────────────────────────────────────────
info "Mise à jour pubspec.yaml…"
sed -i.bak "s/^version: .*/version: ${NEW_VERSION}+${NEW_BUILD}/" pubspec.yaml
rm -f pubspec.yaml.bak
success "pubspec.yaml → version: ${NEW_VERSION}+${NEW_BUILD}"

# ── 2. Mettre à jour version.json (apk_url provisoire) ───────────────────────
APK_URL="https://github.com/Mohamed-el-hedi-dridi/app-tarika/releases/download/${TAG}/tarika.apk"
info "Mise à jour version.json…"
jq \
  --argjson build "$NEW_BUILD" \
  --arg version "$NEW_VERSION" \
  --arg apk_url "$APK_URL" \
  --arg changelog "$CHANGELOG" \
  '.build=$build | .version=$version | .apk_url=$apk_url | .changelog=$changelog' \
  version.json > version.json.tmp && mv version.json.tmp version.json
success "version.json mis à jour"

# ── 3. Build APK release ──────────────────────────────────────────────────────
info "Build APK release…"
flutter build apk --release 2>&1 | tail -5
APK_SRC="build/app/outputs/flutter-apk/app-release.apk"
[[ -f "$APK_SRC" ]] || error "APK introuvable après le build : $APK_SRC"
success "APK buildé"

# ── 4. Commit + tag ───────────────────────────────────────────────────────────
info "Commit git…"
git add pubspec.yaml version.json pubspec.lock
git commit -m "release: ${NEW_VERSION}+${NEW_BUILD} — ${CHANGELOG}"
git tag "$TAG"
git push origin main
git push origin "$TAG"
success "Commit + tag poussés"

# ── 5. GitHub Release + upload APK ───────────────────────────────────────────
info "Création de la GitHub Release ${TAG}…"
gh release create "$TAG" \
  --title "Tarika ${NEW_VERSION}" \
  --notes "$CHANGELOG" \
  "$APK_SRC#tarika.apk"
success "Release ${TAG} publiée avec l'APK"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Release ${NEW_VERSION}+${NEW_BUILD} publiée avec succès !${NC}"
echo -e "${GREEN}  APK : ${APK_URL}${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
