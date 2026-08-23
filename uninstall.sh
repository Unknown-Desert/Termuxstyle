#!/usr/bin/env bash

# ============================================
#  UNINSTALLER TERMUX BY Unknown-Desert
# ============================================

GREEN=$'\033[1;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[1;31m'
CYAN=$'\033[1;36m'
NC=$'\033[0m'

echo "=============================================="
echo "  🧹 UNINSTALLER TERMUX BY Unknown-Desert"
echo "=============================================="
echo ""

if [[ -z "$BASH_VERSION" ]]; then
    echo -e "${RED}❌ Jalankan dengan bash${NC}"
    exit 1
fi

cd "$HOME" || {
    echo -e "${RED}❌ Gagal pindah ke direktori home.${NC}"
    exit 1
}

echo -e "${CYAN}[i] Menghentikan proses background...${NC}"
pkill -f "cloudflared proxy-dns" 2>/dev/null && echo -e "${YELLOW}[i] cloudflared dihentikan${NC}" || true
pkill -f "unbound" 2>/dev/null && echo -e "${YELLOW}[i] unbound dihentikan${NC}" || true
pkill -f "gt" 2>/dev/null && echo -e "${YELLOW}[i] GreenTunnel dihentikan${NC}" || true
sleep 1

BASHRC="$HOME/.bashrc"
BASHRC_BACKUP="$HOME/.bashrc.backup"

echo ""
echo -e "${CYAN}[i] Memulihkan .bashrc...${NC}"

if [[ -f "$BASHRC_BACKUP" ]]; then
    cp -f "$BASHRC_BACKUP" "$BASHRC"
    echo -e "${GREEN}✅ .bashrc dipulihkan dari backup.${NC}"
else
    echo -e "${YELLOW}[i] Backup .bashrc tidak ditemukan. Membersihkan .bashrc...${NC}"
    if [[ -f "$BASHRC" ]]; then
        sed -i '/source ~\/termux.sh/d' "$BASHRC"
        sed -i '/# Termux customization by Unknown-Desert/d' "$BASHRC"
        sed -i '/export LANG=en_US.UTF-8/d' "$BASHRC"
        sed -i '/export LC_ALL=en_US.UTF-8/d' "$BASHRC"
        echo -e "${GREEN}✅ .bashrc dibersihkan dari entri kustomisasi.${NC}"
    else
        echo -e "${YELLOW}[i] .bashrc tidak ada, tidak perlu dibersihkan.${NC}"
    fi
fi

echo ""
echo -e "${CYAN}[i] Menghapus file kustomisasi...${NC}"

if [[ -f "$HOME/termux.sh" ]]; then
    rm -f "$HOME/termux.sh"
    echo -e "${YELLOW}[i] termux.sh dihapus${NC}"
fi

if [[ -f "$HOME/.cache_profile" ]]; then
    rm -f "$HOME/.cache_profile"
    echo -e "${YELLOW}[i] .cache_profile dihapus${NC}"
fi

if [[ -f "$BASHRC_BACKUP" ]]; then
    rm -f "$BASHRC_BACKUP"
    echo -e "${YELLOW}[i] .bashrc.backup dihapus${NC}"
fi

HOSTS_FILE="$PREFIX/etc/hosts"
BLOCK_TAG="# === Custom BlockList Start ==="
BLOCK_END="# === Custom BlockList End ==="

echo ""
echo -e "${CYAN}[i] Membersihkan blok domain di hosts...${NC}"

if [[ -f "$HOSTS_FILE" ]]; then
    sed -i "/$BLOCK_TAG/,/$BLOCK_END/d" "$HOSTS_FILE"
    echo -e "${GREEN}✅ Blok domain kustom dihapus dari hosts.${NC}"
else
    echo -e "${YELLOW}[i] File hosts tidak ditemukan.${NC}"
fi

RESOLV_FILE="$PREFIX/etc/resolv.conf"

echo ""
echo -e "${CYAN}[i] Mengembalikan DNS ke default...${NC}"

{
    echo "nameserver 8.8.8.8"
    echo "nameserver 8.8.4.4"
} > "$RESOLV_FILE"

echo -e "${GREEN}✅ resolv.conf diatur ke DNS default (Google DNS).${NC}"

echo ""
echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}  ✅ UNINSTALL SELESAI${NC}"
echo -e "${GREEN}  Kustomisasi Unknown-Desert telah dibersihkan.${NC}"
echo -e "${GREEN}  Paket dependensi TIDAK dihapus.${NC}"
echo -e "${GREEN}==============================================${NC}"