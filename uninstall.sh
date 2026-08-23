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

# ===== Pindah ke home =====
cd "$HOME" || {
    echo -e "${RED}❌ Failed to change to home directory.${NC}"
    exit 1
}

# ===== TIDAK MENYENTUH .bashrc DI SINI =====
echo -e "${CYAN}[i] Preparing installation...${NC}"
echo ""

# ===== PEMILIHAN BAHASA =====
if [[ -n "$1" ]]; then
    LANG_INPUT="$1"
    # Hanya gunakan argumen sekali
    set -- ""
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

# ===== INSTALASI DEPENDENSI =====
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

# ===== PEMBERSIHAN FILE LAMA (dipindah ke sini) =====
echo ""
echo -e "${CYAN}[i] Cleaning up old files...${NC}"

if [[ -f "$TARGET_FILE" ]]; then
    rm -f "$TARGET_FILE"
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

echo -e "${GREEN}✅ Cleanup complete!${NC}"
echo ""

# ===== LOOP PENYALINAN FILE BAHASA =====
while true; do
    if [[ -f "$SOURCE_FILE" ]]; then
        cp -f "$SOURCE_FILE" "$TARGET_FILE"
        chmod +x "$TARGET_FILE"
        echo -e "${GREEN}✅ termux.sh saved to: ${TARGET_FILE}${NC}"
        echo -e "${GREEN}   Language: ${LANG_NAME}${NC}"
        break
    else
        echo -e "${RED}❌ File not found: ${SOURCE_FILE}${NC}"
        echo "   Make sure lang_id.sh / lang_en.sh exist in this folder"
        echo ""
        echo "🌐 Select Language Again"
        echo "  1) Indonesia"
        echo "  2) English"
        echo -n "(1/2): "
        read -r LANG_INPUT

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
    fi
done

# ===== JALANKAN termux.sh TERLEBIH DAHULU =====
echo ""
echo -e "${CYAN}[i] Starting termux.sh...${NC}"
cd "$HOME" || {
    echo -e "${RED}❌ Failed to change to home directory.${NC}"
    exit 1
}

# Backup .bashrc sebelum menjalankan termux.sh
BASHRC="$HOME/.bashrc"
BASHRC_BACKUP="$HOME/.bashrc.backup"

if [[ -f "$BASHRC" ]]; then
    cp -f "$BASHRC" "$BASHRC_BACKUP"
    echo -e "${YELLOW}[i] Backup .bashrc dibuat: $BASHRC_BACKUP${NC}"
fi

if [[ -f "$TARGET_FILE" ]]; then
    if bash "$TARGET_FILE"; then
        echo -e "${GREEN}✅ termux.sh berhasil dijalankan.${NC}"

        # ===== TAMBAH SOURCE KE .bashrc HANYA SETELAH SUKSES =====
        if [ ! -f "$BASHRC" ]; then
            touch "$BASHRC"
        fi

        if ! grep -q "source ~/termux.sh" "$BASHRC" 2>/dev/null; then
            echo "" >> "$BASHRC"
            echo "# Termux customization by Unknown-Desert" >> "$BASHRC"
            echo "source ~/termux.sh" >> "$BASHRC"
            echo -e "${GREEN}✅ Auto-load termux.sh ditambahkan ke .bashrc${NC}"
        fi

        # Tambahkan LANG/LC_ALL jika belum ada
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
    echo -e "${YELLOW}[i] Kembali ke pemilihan bahasa...${NC}"
    exec bash "$0"   # Restart skrip dari awal
fi