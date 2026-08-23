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
        echo -e "${YELLOW}[!] Choice Fail, Default: Bahasa Indonesia.${NC}"
        LANG_CODE="id"
        LANG_NAME="Bahasa Indonesia"
        ;;
esac

SOURCE_FILE="$SCRIPT_DIR/lang_${LANG_CODE}.sh"
TARGET_FILE="$HOME_TERMUX/termux.sh"

echo ""
echo -e "${CYAN}[i] Bahasa dipilih : ${LANG_NAME}${NC}"
echo ""

echo "📦 Update paket..."
pkg update -y || {
    echo -e "${RED}❌ Fail update packages.${NC}"
    exit 1
}

echo ""
echo "📦 Install dependencies..."
pkg install -y figlet cloudflared unbound python nodejs-lts ruby || {
    echo -e "${RED}❌ Fail install Basic Packages.${NC}"
    exit 1
}

echo ""
echo "📦 Install lolcat via gem..."
if command -v gem >/dev/null 2>&1; then
    gem install lolcat || {
        echo -e "${YELLOW}⚠️ Fail Installing lolcat, Skip.${NC}"
    }
else
    echo -e "${YELLOW}⚠️ gem not found, lolcat has not Installed.${NC}"
fi

echo ""
if command -v npm >/dev/null 2>&1; then
    echo "📦 Install GreenTunnel..."
    npm install -g green-tunnel || {
        echo -e "${YELLOW}⚠️ Fail Installing GreenTunnel, Skip.${NC}"
    }
else
    echo -e "${YELLOW}⚠️ npm not found, GreenTunnel has not Installed.${NC}"
fi

echo ""
echo "🧹 Clear cache..."
pkg clean || true

echo ""
if [[ -f "$SOURCE_FILE" ]]; then
    if [[ -f "$TARGET_FILE" ]]; then
        BACKUP_FILE="${TARGET_FILE}.backup_$(date +%Y%m%d_%H%M%S)"
        mv "$TARGET_FILE" "$BACKUP_FILE"
        echo -e "${YELLOW}[i] Backup Old Termux: ${BACKUP_FILE}${NC}"
    fi

    cp -f "$SOURCE_FILE" "$TARGET_FILE"
    chmod +x "$TARGET_FILE"
    echo -e "${GREEN}✅ termux.sh Saved in: ${TARGET_FILE}${NC}"
    echo -e "${GREEN}   Language: ${LANG_NAME}${NC}"
else
    echo -e "${RED}❌ Files Not Found: ${SOURCE_FILE}${NC}"
    echo "   Make sure the files lang_id.sh / lang_en.sh / lang_ar.sh in this folder"
    exit 1
fi

if [[ "$LANG_CODE" == "ar" ]]; then
    echo ""
    echo -e "${CYAN}[i] Mengatur dukungan penuh untuk Bahasa Arab Tradisional...${NC}"
    echo -e "${CYAN}[i] جاري تهيئة الدعم الكامل للغة العربية الفصحى...${NC}"

    pkg install -y unzip

    mkdir -p "$HOME/.termux"

    if [ -w "/tmp" ]; then
        TMP_DIR="/tmp"
    else
        mkdir -p "$HOME/tmp"
        TMP_DIR="$HOME/tmp"
    fi

    echo -e "${CYAN}[i] Mengunduh font Noto Sans Arabic...${NC}"
    echo -e "${CYAN}[i] جاري تحميل خط Noto Sans Arabic...${NC}"
    curl -L -o "$HOME/.termux/font.ttf" \
        "https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSansArabic/NotoSansArabic-Regular.ttf"

    if [[ -f "$HOME/.termux/font.ttf" ]]; then
        echo -e "${GREEN}✅ Font Noto Sans Arabic berhasil dipasang!${NC}"
        echo -e "${GREEN}✅ تم تثبيت خط Noto Sans Arabic بنجاح!${NC}"
    else
        echo -e "${YELLOW}⚠️ Gagal download Noto Sans Arabic, fallback ke GNU FreeFont...${NC}"
        echo -e "${YELLOW}⚠️ فشل تحميل Noto Sans Arabic، جاري استخدام GNU FreeFont...${NC}"
        curl -L -o "$TMP_DIR/freefont.zip" \
            "https://ftp.gnu.org/gnu/freefont/freefont-ttf-20120503.zip"
        if [[ -f "$TMP_DIR/freefont.zip" ]]; then
            unzip -p "$TMP_DIR/freefont.zip" FreeMono.ttf > "$HOME/.termux/font.ttf"
            rm -f "$TMP_DIR/freefont.zip"
            echo -e "${GREEN}✅ Font GNU FreeFont berhasil dipasang!${NC}"
            echo -e "${GREEN}✅ تم تثبيت خط GNU FreeFont بنجاح!${NC}"
        else
            echo -e "${YELLOW}⚠️ Gagal download semua font. Install termux-styling manual.${NC}"
            echo -e "${YELLOW}⚠️ فشل تحميل جميع الخطوط. قم بتثبيت termux-styling يدويًا.${NC}"
            pkg install -y termux-styling
            echo -e "   Jalankan 'chfont' dan pilih font yang support Arab."
            echo -e "   قم بتشغيل 'chfont' واختر خطًا يدعم العربية."
        fi
    fi

    if ! grep -q "LANG=en_US.UTF-8" "$HOME/.bashrc" 2>/dev/null; then
        echo "export LANG=en_US.UTF-8" >> "$HOME/.bashrc"
    fi
    if ! grep -q "LC_ALL=en_US.UTF-8" "$HOME/.bashrc" 2>/dev/null; then
        echo "export LC_ALL=en_US.UTF-8" >> "$HOME/.bashrc"
    fi

    echo -e "${YELLOW}⚠️ PENTING: Restart Termux (ketik 'exit' dan buka lagi) agar font berlaku!${NC}"
    echo -e "${YELLOW}⚠️ مهم: أعد تشغيل Termux (اكتب 'exit' ثم افتح مجددًا) لتطبيق التغييرات!${NC}"
    echo ""
fi