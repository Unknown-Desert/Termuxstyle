#!/usr/bin/env bash

# ============================================
#  INSTALLER TERMUX BY LR
#  with Language Selection
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
echo "  📦 INSTALLER TERMUX BY LR"
echo "=============================================="
echo ""

if [[ -n "$1" ]]; then
    LANG_INPUT="$1"
else
    echo "🌐 Pilih Bahasa / Select Language / اختر اللغة:"
    echo "  1) Indonesia"
    echo "  2) English"
    echo "  3) العربية"
    echo -n "(1/2/3): "
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
    3|ar|AR|arabic|Arabic|العربية|عربي)
        LANG_CODE="ar"
        LANG_NAME="العربية"
        ;;
    *)
        echo -e "${YELLOW}[!] Pilihan tidak dikenal, menggunakan Bahasa Indonesia.${NC}"
        LANG_CODE="id"
        LANG_NAME="Bahasa Indonesia"
        ;;
esac

SOURCE_FILE="$SCRIPT_DIR/lang_${LANG_CODE}.sh"
TARGET_FILE="$HOME_TERMUX/termux.sh"

echo ""
echo -e "${CYAN}[i] Bahasa dipilih : ${LANG_NAME}${NC}"
echo -e "${CYAN}[i] File sumber     : ${SOURCE_FILE}${NC}"
echo -e "${CYAN}[i] File tujuan     : ${TARGET_FILE}${NC}"
echo ""

echo "📦 Install dependencies..."
pkg update -y
pkg install -y figlet lolcat cloudflared unbound python nodejs-lts

if command -v npm >/dev/null 2>&1; then
    echo ""
    echo "📦 Install GreenTunnel..."
    npm install -g green-tunnel
else
    echo "⚠️ npm not found. GreenTunnel not installed."
fi

pkg clean

echo ""

if [[ -f "$SOURCE_FILE" ]]; then
    if [[ -f "$TARGET_FILE" ]]; then
        BACKUP_FILE="${TARGET_FILE}.backup_$(date +%Y%m%d_%H%M%S)"
        mv "$TARGET_FILE" "$BACKUP_FILE"
        echo -e "${YELLOW}[i] Backup termux.sh lama: ${BACKUP_FILE}${NC}"
    fi

    cp -f "$SOURCE_FILE" "$TARGET_FILE"
    chmod +x "$TARGET_FILE"
    echo -e "${GREEN}✅ termux.sh berhasil dipasang di: ${TARGET_FILE}${NC}"
    echo -e "${GREEN}   Bahasa: ${LANG_NAME}${NC}"
    echo -e "${GREEN}   Jalankan dengan: ./termux.sh${NC}"
else
    echo -e "${RED}❌ File bahasa tidak ditemukan: ${SOURCE_FILE}${NC}"
    echo "   Pastikan file lang_id.sh / lang_en.sh / lang_ar.sh berada di folder yang sama dengan install.sh"
    exit 1
fi