#!/usr/bin/env bash

# ============================================
#  INSTALLER TERMUX BY Unknown-Desert
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_TERMUX="$HOME"

GREEN=$'\033[1;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[1;31m'
CYAN=$'\033[1;36m'
NC=$'\033[0m'

echo "=============================================="
echo "  📦 INSTALLER TERMUX BY Unknown-Desert"
echo "=============================================="
echo ""

if [[ -z "$BASH_VERSION" ]]; then
    echo -e "${RED}❌ Run with bash${NC}"
    exit 1
fi

echo -e "${CYAN}[i] Cleaning up old files...${NC}"

cd "$HOME" || {
    echo -e "${RED}❌ Failed to change to home directory.${NC}"
    exit 1
}

BASHRC="$HOME/.bashrc"
BASHRC_BACKUP="$HOME/.bashrc.backup"

if [[ -f "$BASHRC" ]]; then
    cp -f "$BASHRC" "$BASHRC_BACKUP"
    echo -e "${YELLOW}[i] Backup .bashrc dibuat: $BASHRC_BACKUP${NC}"
fi

echo ""
echo -e "${CYAN}[i] Starting termux.sh...${NC}"
cd "$HOME" || {
    echo -e "${RED}❌ Failed to change to home directory.${NC}"
    exit 1
}

if [[ -f "$HOME/termux.sh" ]]; then
    if bash "$HOME/termux.sh"; then
        echo -e "${GREEN}✅ termux.sh berhasil dijalankan.${NC}"

        if [ ! -f "$BASHRC" ]; then
            touch "$BASHRC"
        fi

        if ! grep -q "source ~/termux.sh" "$BASHRC" 2>/dev/null; then
            echo "" >> "$BASHRC"
            echo "# Termux customization by Unknown-Desert" >> "$BASHRC"
            echo "source ~/termux.sh" >> "$BASHRC"
            echo -e "${GREEN}✅ Auto-load termux.sh ditambahkan ke .bashrc${NC}"
        fi

        if ! grep -q "export LANG=en_US.UTF-8" "$BASHRC" 2>/dev/null; then
            echo "export LANG=en_US.UTF-8" >> "$BASHRC"
        fi
        if ! grep -q "export LC_ALL=en_US.UTF-8" "$BASHRC" 2>/dev/null; then
            echo "export LC_ALL=en_US.UTF-8" >> "$BASHRC"
        fi

        echo -e "${GREEN}✅ Instalasi selesai.${NC}"
    else
        echo -e "${RED}❌ termux.sh gagal. Memulihkan .bashrc dari backup...${NC}"
        if [[ -f "$BASHRC_BACKUP" ]]; then
            cp -f "$BASHRC_BACKUP" "$BASHRC"
            echo -e "${YELLOW}[i] .bashrc dipulihkan.${NC}"
        else
            echo -e "${YELLOW}[i] Tidak ada backup .bashrc, .bashrc dibiarkan apa adanya.${NC}"
        fi
        exit 1
    fi
else
    echo -e "${RED}❌ termux.sh tidak ditemukan di $HOME${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Cleanup complete!${NC}"
echo ""

if [[ -n "$1" ]]; then
    LANG_INPUT="$1"
else
    echo "🌐 Select Language"
    echo "  1) Indonesia"
    echo "  2) English"
    echo -n "(1/2): "
    read -r LANG_INPUT
fi

case "$LANG_INPUT" in
    1|id|ID|indonesia|Indonesia|INDONESIA)
        LANG_CODE="id"
        LANG_NAME="Bahasa Indonesia"
        ;;
    2|en|EN|english|English|ENGLISH)
        LANG_CODE="en"
        LANG_NAME="English"
        ;;
    *)
        echo -e "${YELLOW}[!] Invalid choice, defaulting to English.${NC}"
        LANG_CODE="en"
        LANG_NAME="English"
        ;;
esac

SOURCE_FILE="$SCRIPT_DIR/lang_${LANG_CODE}.sh"
TARGET_FILE="$HOME_TERMUX/termux.sh"

echo ""
echo -e "${CYAN}[i] Selected language: ${LANG_NAME}${NC}"
echo ""

echo "📦 Updating packages..."
pkg update -y || {
    echo -e "${RED}❌ Failed to update packages.${NC}"
    exit 1
}

echo ""
echo "📦 Installing dependencies..."
pkg install -y figlet cloudflared unbound python nodejs-lts ruby || {
    echo -e "${RED}❌ Failed to install basic packages.${NC}"
    exit 1
}

echo ""
echo "📦 Installing lolcat via gem..."
if command -v gem >/dev/null 2>&1; then
    gem install lolcat || {
        echo -e "${YELLOW}⚠️ Failed to install lolcat, skipping.${NC}"
    }
else
    echo -e "${YELLOW}⚠️ gem not found, lolcat not installed.${NC}"
fi

echo ""
if command -v npm >/dev/null 2>&1; then
    echo "📦 Installing GreenTunnel..."
    npm install -g green-tunnel || {
        echo -e "${YELLOW}⚠️ Failed to install GreenTunnel, skipping.${NC}"
    }
else
    echo -e "${YELLOW}⚠️ npm not found, GreenTunnel not installed.${NC}"
fi

echo ""
echo "🧹 Clearing cache..."
pkg clean || true


if [[ -f "$HOME/termux.sh" ]]; then
    rm -f "$HOME/termux.sh"
    echo -e "${YELLOW}[i] Removed old termux.sh${NC}"
fi

if [[ -f "$HOME/termux.sh.backup" ]]; then
    rm -f "$HOME/termux.sh.backup"
    echo -e "${YELLOW}[i] Removed old termux.sh.backup${NC}"
fi

if [[ -f "$HOME/.cache_profile" ]]; then
    rm -f "$HOME/.cache_profile"
    echo -e "${YELLOW}[i] Removed old .cache_profile${NC}"
fi

echo ""
if [[ -f "$SOURCE_FILE" ]]; then
    cp -f "$SOURCE_FILE" "$TARGET_FILE"
    chmod +x "$TARGET_FILE"
    echo -e "${GREEN}✅ termux.sh saved to: ${TARGET_FILE}${NC}"
    echo -e "${GREEN}   Language: ${LANG_NAME}${NC}"
else
    echo -e "${RED}❌ File not found: ${SOURCE_FILE}${NC}"
    echo "   Make sure lang_id.sh / lang_en.sh exist in this folder"
    exit 1
fi

if ! grep -q "LANG=en_US.UTF-8" "$HOME/.bashrc" 2>/dev/null; then
    echo "export LANG=en_US.UTF-8" >> "$HOME/.bashrc"
fi
if ! grep -q "LC_ALL=en_US.UTF-8" "$HOME/.bashrc" 2>/dev/null; then
    echo "export LC_ALL=en_US.UTF-8" >> "$HOME/.bashrc"
fi

BASHRC="$HOME/.bashrc"
if [ ! -f "$BASHRC" ]; then
    touch "$BASHRC"
fi

if ! grep -q "source ~/termux.sh" "$BASHRC" 2>/dev/null; then
    echo "" >> "$BASHRC"
    echo "# Termux customization by Unknown-Desert" >> "$BASHRC"
    echo "source ~/termux.sh" >> "$BASHRC"
    echo -e "${GREEN}✅ Auto-load termux.sh added to .bashrc${NC}"
fi

echo ""
echo -e "${CYAN}[i] Starting termux.sh...${NC}"
cd "$HOME" || {
    echo -e "${RED}❌ Failed to change to home directory.${NC}"
    exit 1
}

if [[ -f "$HOME/termux.sh" ]]; then
    if bash "$HOME/termux.sh"; then
        echo -e "${GREEN}✅ termux.sh ran successfully.${NC}"

        # Sekarang tambahkan kustomisasi ke .bashrc hanya setelah sukses
        if ! grep -q "LANG=en_US.UTF-8" "$HOME/.bashrc" 2>/dev/null; then
            echo "export LANG=en_US.UTF-8" >> "$HOME/.bashrc"
        fi
        if ! grep -q "LC_ALL=en_US.UTF-8" "$HOME/.bashrc" 2>/dev/null; then
            echo "export LC_ALL=en_US.UTF-8" >> "$HOME/.bashrc"
        fi

        BASHRC="$HOME/.bashrc"
        [ ! -f "$BASHRC" ] && touch "$BASHRC"

        if ! grep -q "source ~/termux.sh" "$BASHRC" 2>/dev/null; then
            echo "" >> "$BASHRC"
            echo "# Termux customization by Unknown-Desert" >> "$BASHRC"
            echo "source ~/termux.sh" >> "$BASHRC"
            echo -e "${GREEN}✅ Auto-load termux.sh added to .bashrc${NC}"
        fi
    else
        echo -e "${RED}❌ termux.sh failed. Restoring .bashrc from backup...${NC}"
        if [[ -f "$HOME/.bashrc.backup" ]]; then
            cp -f "$HOME/.bashrc.backup" "$HOME/.bashrc"
            echo -e "${YELLOW}[i] .bashrc restored from backup.${NC}"
        else
            echo -e "${YELLOW}[i] No backup .bashrc found, leaving current .bashrc.${NC}"
        fi
        exit 1
    fi
else
    echo -e "${RED}❌ termux.sh not found in $HOME${NC}"
    exit 1
fi