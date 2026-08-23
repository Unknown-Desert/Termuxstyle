#!/usr/bin/env bash

RED=$'\033[1;31m'
WHITE=$'\033[1;37m'
CYAN=$'\033[1;36m'
GREEN=$'\033[1;32m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m'

center() {
  local text="$1"
  local width=$(tput cols)
  local pad=$(( (width - ${#text}) / 2 ))
  if (( pad < 0 )); then pad=0; fi
  printf "%*s%s\n" $pad "" "$text"
}

type_text() {
  local text="$1"
  local width=$(tput cols)
  local pad=$(( (width - ${#text}) / 2 ))
  if (( pad < 0 )); then pad=0; fi
  printf "%*s" $pad ""
  for ((i=0; i<${#text}; i++)); do
    echo -n "${text:$i:1}"
    sleep 0.01
  done
  echo ""
}

FAKE_ALIASES=(ping curl wget git npm apt nc ssh ping6 ftp scp proxy)

set_fake_proxy() {
  export http_proxy="http://127.0.0.1:9"
  export https_proxy="http://127.0.0.1:9"
}

unset_fake_proxy() {
  unset http_proxy https_proxy
}

export FAKE_OFFLINE_ACTIVE=true
export FAKE_OFFLINE_REMIND_SHOWN=false
export FAKE_OFFLINE_STATUS="ON"

ping()   { echo "ping: unknown host"; fakeoffcheck "ping"; }
curl()   { echo "curl: network timeout"; fakeoffcheck "curl"; }
wget()   { echo "wget: failed: No route to host."; fakeoffcheck "wget"; }
git()    { echo "fatal: unable to access: Could not resolve host"; fakeoffcheck "git"; }
npm()    { echo "npm ERR! network request to failed"; fakeoffcheck "npm"; }
apt()    { echo "E: Unable to fetch packages, check your internet connection"; fakeoffcheck "apt"; }
nc()     { echo "nc: connection refused"; fakeoffcheck "nc"; }
ssh()    { echo "ssh: connection timeout"; fakeoffcheck "ssh"; }
ping6()  { echo "ping6: unreachable"; fakeoffcheck "ping6"; }
ftp()    { echo "ftp: connection lost"; fakeoffcheck "ftp"; }
scp()    { echo "scp: network unreachable"; fakeoffcheck "scp"; }
proxy()  { echo "proxy: connection refused"; fakeoffcheck "proxy"; unset_fake_proxy; }

set_fake_proxy

export _realcurl=$(command -v curl)
export _realwget=$(command -v wget)
secret_curl() { command curl "$@"; }
secret_wget() { command wget "$@"; }

declare -a DISABLED_ALIASES=()

enable_specific_aliases() {
  for alias_name in "${DISABLED_ALIASES[@]}"; do
    case "$alias_name" in
      ping)   ping()   { echo "ping: unknown host"; fakeoffcheck "ping"; } ;;
      curl)   curl()   { echo "curl: network timeout"; fakeoffcheck "curl"; } ;;
      wget)   wget()   { echo "wget: failed: No route to host."; fakeoffcheck "wget"; } ;;
      git)    git()    { echo "fatal: unable to access: Could not resolve host"; fakeoffcheck "git"; } ;;
      npm)    npm()    { echo "npm ERR! network request to failed"; fakeoffcheck "npm"; } ;;
      apt)    apt()    { echo "E: Unable to fetch packages, check your internet connection"; fakeoffcheck "apt"; } ;;
      nc)     nc()     { echo "nc: connection refused"; fakeoffcheck "nc"; } ;;
      ssh)    ssh()    { echo "ssh: connection timeout"; fakeoffcheck "ssh"; } ;;
      ping6)  ping6()  { echo "ping6: unreachable"; fakeoffcheck "ping6"; } ;;
      ftp)    ftp()    { echo "ftp: connection lost"; fakeoffcheck "ftp"; } ;;
      scp)    scp()    { echo "scp: network unreachable"; fakeoffcheck "scp"; } ;;
      proxy)  proxy()  { echo "proxy: connection refused"; fakeoffcheck "proxy"; unset_fake_proxy; } ;;
    esac
  done
  DISABLED_ALIASES=()
}

enable_fake_offline() {
  set_fake_proxy
  ping()   { echo "ping: unknown host"; fakeoffcheck "ping"; }
  curl()   { echo "curl: network timeout"; fakeoffcheck "curl"; }
  wget()   { echo "wget: failed: No route to host."; fakeoffcheck "wget"; }
  git()    { echo "fatal: unable to access: Could not resolve host"; fakeoffcheck "git"; }
  npm()    { echo "npm ERR! network request to failed"; fakeoffcheck "npm"; }
  apt()    { echo "E: Unable to fetch packages, check your internet connection"; fakeoffcheck "apt"; }
  nc()     { echo "nc: connection refused"; fakeoffcheck "nc"; }
  ssh()    { echo "ssh: connection timeout"; fakeoffcheck "ssh"; }
  ping6()  { echo "ping6: unreachable"; fakeoffcheck "ping6"; }
  ftp()    { echo "ftp: connection lost"; fakeoffcheck "ftp"; }
  scp()    { echo "scp: network unreachable"; fakeoffcheck "scp"; }
  proxy()  { echo "proxy: connection refused"; fakeoffcheck "proxy"; unset_fake_proxy; }
  export FAKE_OFFLINE_ACTIVE=true
  export FAKE_OFFLINE_STATUS="ON"
  DISABLED_ALIASES=()
}

disable_fake_offline() {
  for a in "${FAKE_ALIASES[@]}"; do
    unset -f "$a" 2>/dev/null
  done
  unset_fake_proxy
  export FAKE_OFFLINE_ACTIVE=false
  export FAKE_OFFLINE_STATUS="OFF"
  DISABLED_ALIASES=()
}

export FAKE_OFFLINE_TEMP_DISABLED=false

is_auto_off_command() {
    local cmd="$1"
    cmd="${cmd#"${cmd%%[![:space:]]*}"}" 
    local first_word="${cmd%%[[:space:]]*}"
    if [[ "$first_word" == ./* || "$first_word" == /* ]]; then
        return 0
    fi

    case "$first_word" in
        python|python2|python3|node|nodejs|ruby|perl|php|lua|deno|bun| \
        pip|pip3|gem|npm|yarn|pkg|apt|apt-get|dpkg)
            return 0 ;;
        bash|sh|zsh|fish|dash|ksh|source)
            local rest="${cmd#*[[:space:]]}"
            [[ -n "$rest" ]] && return 0 || return 1 ;;
        *)
            return 1 ;;
    esac
}

auto_off_preexec() {
    local cmd="$BASH_COMMAND"
    [[ "$cmd" == auto_off_preexec* || "$cmd" == auto_off_prompt* || "$cmd" == PROMPT_COMMAND* ]] && return

    [[ "$FAKE_OFFLINE_ACTIVE" != "true" || "$FAKE_OFFLINE_TEMP_DISABLED" == "true" ]] && return

    if is_auto_off_command "$cmd"; then
        echo -e "\n🔓 Fake Offline dimatikan sementara untuk perintah: $cmd"
        disable_fake_offline
        export FAKE_OFFLINE_TEMP_DISABLED=true
    fi
}
trap auto_off_preexec DEBUG

auto_off_prompt() {
    if [[ "$FAKE_OFFLINE_TEMP_DISABLED" == "true" ]]; then
        enable_fake_offline
        export FAKE_OFFLINE_TEMP_DISABLED=false
        echo "🔒 Fake Offline diaktifkan kembali."
    fi
}

fakeoff() {
  if [ "$FAKE_OFFLINE_ACTIVE" != "true" ]; then
    echo "ℹ️ Fake Offline tidak aktif."
    return
  fi

  echo -e "\n🕵️  Fake Offline Layer aktif."
  echo "➤ Pilihan:"
  echo "  [1] Nonaktifkan semua Fake Offline"
  echo "  [2] Pilih alias tertentu untuk dimatikan"
  echo "  [3] Abaikan (tidak akan ditanya lagi)"

  echo -n "Pilih (1/2/3): "
  read -r pilihan

  case "$pilihan" in
    1)
      echo -e "\nPilih mode penonaktifan:"
      echo "  [1] Sementara (1-15 menit)"
      echo "  [2] Sampai Termux ditutup"
      echo -n "Mode (1/2): "
      read -r mode

      if [[ "$mode" == "1" ]]; then
        echo -n "⏱ Durasi penonaktifan (1-15 menit, default 3): "
        read -r dur
        [[ "$dur" =~ ^[0-9]+$ && "$dur" -ge 1 && "$dur" -le 15 ]] || dur=3

        echo "🛑 Nonaktif semua Fake Offline selama $dur menit..."
        disable_fake_offline

        (
          sleep "$((dur * 60))"
          echo -e "\n🔄 Mengaktifkan ulang Fake Offline Layer..."
          enable_fake_offline
        ) &
      elif [[ "$mode" == "2" ]]; then
        echo "🛑 Nonaktif semua Fake Offline sampai Termux ditutup..."
        disable_fake_offline
      else
        echo "❌ Mode tidak valid. Abaikan."
      fi
      ;;

    2)
      fake_offline_menu
      ;;

    3)
      echo "✅ Tidak akan ditanya lagi di sesi ini."
      export FAKE_OFFLINE_REMIND_SHOWN=true
      ;;

    *)
      echo "❌ Pilihan tidak valid. Abaikan."
      ;;
  esac
}

fake_offline_menu() {
  local ALIASES=(ping curl wget git npm apt nc ssh ping6 ftp scp proxy)

  echo -e "\n🔧 Pilih alias yang ingin dimatikan:"
  for i in "${!ALIASES[@]}"; do
    echo "  $((i + 1)). ${ALIASES[$i]}"
  done

  echo -n "Masukkan nomor alias (pisah spasi, contoh: 2 4 6): "
  read -r pilihan

  [[ -z "$pilihan" ]] && echo "😶‍🌫️ Tidak ada alias dipilih." && return

  echo -e "\n🎯 Pilih mode:"
  echo "  [1] Nonaktifkan sementara (1-15 menit)"
  echo "  [2] Nonaktifkan sampai Termux ditutup"
  echo -n "Pilih mode (1/2): "
  read -r mode

  if [[ "$mode" != "1" && "$mode" != "2" ]]; then
    echo "❌ Mode tidak valid."
    return
  fi

  local dur=3
  if [[ "$mode" == "1" ]]; then
    echo -n "⏱ Durasi (1-15 menit, default 3): "
    read -r dur
    [[ "$dur" =~ ^[0-9]+$ && "$dur" -ge 1 && "$dur" -le 15 ]] || dur=3
  fi

  local selected_aliases=()
  for num in $pilihan; do
    idx=$((num - 1))
    alias_name="${ALIASES[$idx]}"
    if [[ -z "$alias_name" ]]; then
      echo "❌ Nomor $num tidak valid."
      continue
    fi
    selected_aliases+=("$alias_name")
  done

  if [ ${#selected_aliases[@]} -eq 0 ]; then
    echo "😶‍🌫️ Tidak ada alias valid dipilih."
    return
  fi

  for alias_name in "${selected_aliases[@]}"; do
    if [[ "$alias_name" == "proxy" ]]; then
      unset_fake_proxy
      unset -f proxy 2>/dev/null
    else
      unset -f "$alias_name" 2>/dev/null
    fi
    echo "🛑 '${alias_name}' dinonaktifkan."
  done

  DISABLED_ALIASES=("${selected_aliases[@]}")

  if [[ "$mode" == "1" ]]; then
    (
      sleep $((dur * 60))
      echo -e "\n🔄 Mengaktifkan ulang alias yang dinonaktifkan: ${DISABLED_ALIASES[*]}"
      local to_reactivate=("${DISABLED_ALIASES[@]}")
      for alias_name in "${to_reactivate[@]}"; do
        case "$alias_name" in
          ping)   ping()   { echo "ping: unknown host"; fakeoffcheck "ping"; } ;;
          curl)   curl()   { echo "curl: network timeout"; fakeoffcheck "curl"; } ;;
          wget)   wget()   { echo "wget: failed: No route to host."; fakeoffcheck "wget"; } ;;
          git)    git()    { echo "fatal: unable to access: Could not resolve host"; fakeoffcheck "git"; } ;;
          npm)    npm()    { echo "npm ERR! network request to failed"; fakeoffcheck "npm"; } ;;
          apt)    apt()    { echo "E: Unable to fetch packages, check your internet connection"; fakeoffcheck "apt"; } ;;
          nc)     nc()     { echo "nc: connection refused"; fakeoffcheck "nc"; } ;;
          ssh)    ssh()    { echo "ssh: connection timeout"; fakeoffcheck "ssh"; } ;;
          ping6)  ping6()  { echo "ping6: unreachable"; fakeoffcheck "ping6"; } ;;
          ftp)    ftp()    { echo "ftp: connection lost"; fakeoffcheck "ftp"; } ;;
          scp)    scp()    { echo "scp: network unreachable"; fakeoffcheck "scp"; } ;;
          proxy)  proxy()  { echo "proxy: connection refused"; fakeoffcheck "proxy"; unset_fake_proxy; } ;;
        esac
      done
      DISABLED_ALIASES=()
    ) &
  fi
}

fakeoffcheck() {
  if [ "$FAKE_OFFLINE_ACTIVE" = "true" ] && [ "$FAKE_OFFLINE_REMIND_SHOWN" != "true" ]; then
    echo -e "\n⚠️  Terdeteksi penggunaan perintah '$1' saat Fake Offline aktif."
    fakeoff
  fi
}

detect_fake_proxy_use() {
  if [ "$FAKE_OFFLINE_REMIND_SHOWN" = "true" ]; then
    return
  fi

  local lastcmd=$(fc -l -1 2>/dev/null | sed 's/^ *[0-9]* *//')
  local triggers=("curl" "wget" "npm" "git" "node" "python" "pip" "http")

  for cmd in "${triggers[@]}"; do
    if [[ "$lastcmd" == "$cmd "* || "$lastcmd" == *" $cmd "* || "$lastcmd" == *"$cmd" ]]; then
      if [[ "$http_proxy" == "http://127.0.0.1:9" || "$https_proxy" == "http://127.0.0.1:9" ]]; then
        fakeoffcheck "proxy (deteksi perintah: $cmd)"
        break
      fi
    fi
  done
}

export PROMPT_COMMAND="auto_off_prompt; detect_fake_proxy_use"

PROFILE_FILE="$HOME/.cache_profile"

if [ ! -f "$PROFILE_FILE" ]; then
    echo "🛠️  Pengaturan pertama kali..."
    echo ""

    read -p "Masukkan Custom Nama Banner (Default : Unknown): " FIGLET_TEXT

    FIGLET_TEXT=${FIGLET_TEXT:-Unknown}
    USE_FIGLET="true"

    read -p "Masukkan Custom Username (Default : User): " USER_NAME
    USER_NAME=${USER_NAME:-User}

    echo "Masukkan 3 Custom Password (Defaul : ):"
    read -s PASS1
    echo ""
    read -s PASS2
    echo ""
    read -s PASS3
    echo ""

    read -p "Masukkan Custom Hint Password (Default : Invisible): " HINT_PASSWORD
    HINT_PASSWORD=${HINT_PASSWORD:-Invisible}

    cat > "$PROFILE_FILE" <<EOF
# Profil pengguna – dibuat otomatis
USE_FIGLET="$USE_FIGLET"
PASSWORD1="$PASS1"
PASSWORD2="$PASS2"
PASSWORD3="$PASS3"
HINT_PASSWORD="$HINT_PASSWORD"
FIGLET_TEXT="$FIGLET_TEXT"
USER_NAME="$USER_NAME"
EOF

    echo "✅ Profil disimpan di $PROFILE_FILE"
    echo ""
fi

source "$PROFILE_FILE"

clear

center "${YELLOW}       Masukkan 3 Password (Hint: $HINT_PASSWORD)${NC}"
echo ""

echo -ne "${YELLOW}Pass 1: ${NC}"
read -s USER1 && tput cuu1 && tput el && echo ""
[[ "$USER1" != "$PASSWORD1" ]] && echo -e "${RED}❌ Password 1 salah.${NC}" && exit 1

echo -ne "${YELLOW}Pass 2: ${NC}"
read -s USER2 && tput cuu1 && tput el && echo ""
[[ "$USER2" != "$PASSWORD2" ]] && echo -e "${RED}❌ Password 2 salah.${NC}" && exit 1

echo -ne "${YELLOW}Pass 3: ${NC}"
read -s USER3 && tput cuu1 && tput el && echo ""
[[ "$USER3" != "$PASSWORD3" ]] && echo -e "${RED}❌ Password 3 salah.${NC}" && exit 1

clear

FIGLET_TEXT=${FIGLET_TEXT:-Unknown}


if [ "$USE_FIGLET" = "true" ]; then
  if command -v figlet >/dev/null 2>&1; then
    if command -v lolcat >/dev/null 2>&1 && echo "test" | lolcat >/dev/null 2>&1; then
      figlet -f slant "$FIGLET_TEXT" | while IFS= read -r line; do center "$line"; done | lolcat
    else
      figlet -f slant "$FIGLET_TEXT" | while IFS= read -r line; do center "$line"; done
    fi
  else
    center "${CYAN}$FIGLET_TEXT${NC}"
  fi
else
  center "${CYAN}$FIGLET_TEXT${NC}"
fi

echo ""

TODAY=$(date +"%A, %d %B %Y")
center "${WHITE}     📆 $TODAY${NC}"
echo ""
center "${CYAN}        ⫸   SELAMAT DATANG DI TERMUX BY Unknown-Desert   ⫷${NC}"
echo ""
sleep 0.2

MOTIVASI_LIST=(
  "Pantang Menyerah" "Gagal itu Guru" "Gas Terus Walau Nyeret"
  "Kalah Hari Ini, Bangkit Besok" "Ga gagal ga sukses" "Lawan Rasa Malas"
  "Jangan Menyerah Bro!" "Mulai Aja Dulu" "Pasti Bisa!" "Terus Maju, Jangan Ragu"
)
RANDOM_MOTIVASI=${MOTIVASI_LIST[$RANDOM % ${#MOTIVASI_LIST[@]}]}
center "${WHITE} 🥶 MOTIVASI"
center "${WHITE}              ${CYAN}${RANDOM_MOTIVASI}${NC}"
echo ""

DNS_FILE="$PREFIX/etc/resolv.conf"
IS_SAFE=false

try_cloudflared() {
  command -v cloudflared >/dev/null 2>&1 || return 1

  pkill -f "cloudflared proxy-dns" 2>/dev/null
  sleep 1

  {
    cloudflared proxy-dns --port 5053 >/dev/null 2>&1 &
  } 2>/dev/null
  disown 2>/dev/null
  sleep 3

  if pgrep -f "cloudflared proxy-dns" >/dev/null; then
    return 0
  else
    return 1
  fi
}

try_unbound() {
  command -v unbound >/dev/null 2>&1 || return 1

  mkdir -p ~/.unbound
  cat > ~/.unbound/unbound.conf <<'EOF'
server:
    interface: 127.0.0.1
    port: 5353
    do-ip4: yes
    do-ip6: no
    do-udp: yes
    do-tcp: yes
    access-control: 127.0.0.0/8 allow
    verbosity: 0
    use-syslog: no
    logfile: "/dev/null"
    cache-min-ttl: 300
    cache-max-ttl: 3600

forward-zone:
    name: "."
    forward-tls-upstream: yes
    forward-addr: 1.1.1.1@853#cloudflare-dns.com
    forward-addr: 1.0.0.1@853#cloudflare-dns.com
EOF

  pkill -f "unbound" 2>/dev/null
  sleep 1
  {
    unbound -c ~/.unbound/unbound.conf -d >/dev/null 2>&1 &
  } 2>/dev/null
  disown 2>/dev/null
  sleep 3

  if pgrep -f "unbound" >/dev/null; then
    return 0
  else
    return 1
  fi
}

if try_cloudflared; then
  IS_SAFE=true
  echo -e "${GREEN}[✓] cloudflared proxy-dns aktif (DoH via Cloudflare).${NC}"
  echo "nameserver 127.0.0.1#5053" > "$DNS_FILE"
else
  if try_unbound; then
    IS_SAFE=true
    echo -e "${GREEN}[✓] Unbound aktif (DoT via Cloudflare).${NC}"
    echo "nameserver 127.0.0.1#5353" > "$DNS_FILE"
  else
    echo -e "${RED}[✗] Semua metode DNS terenkripsi gagal. Fallback ke AdGuard DNS.${NC}"
    echo "nameserver 94.140.14.14" > "$DNS_FILE"
    echo "nameserver 94.140.15.15" >> "$DNS_FILE"
  fi
fi

BLOCK_FILE="$PREFIX/etc/hosts"
BLOCK_TAG="# === Custom BlockList Start ==="
BLOCK_END="# === Custom BlockList End ==="

BLOCK_LIST=(
  "ads.google.com" "ad.doubleclick.net" "track.adware.com"
  "malicious-site.xyz" "api.tracker.com" "analytics.example.net"
  "doubleclick.net" "googleadservices.com" "googlesyndication.com"
  "google-analytics.com"
)

if [ -f "$BLOCK_FILE" ]; then
  sed -i "/$BLOCK_TAG/,/$BLOCK_END/d" "$BLOCK_FILE"
fi

{
  echo "$BLOCK_TAG"
  for domain in "${BLOCK_LIST[@]}"; do
    echo "127.0.0.1 $domain"
    echo "::1 $domain"
  done
  echo "$BLOCK_END"
} >> "$BLOCK_FILE"

echo -e "${GREEN}[✓] Blokir domain iklan/malware diterapkan.${NC}"

SAFETY_STATUS="${RED}False${NC}"
[ "$IS_SAFE" = true ] && SAFETY_STATUS="${GREEN}True${NC}"

if command -v gt >/dev/null 2>&1; then
  pkill -f "gt" 2>/dev/null
  {
    gt --dns doh --no-system-proxy --log-level error >/dev/null 2>&1 &
  } 2>/dev/null
  disown 2>/dev/null
  echo -e "${GREEN}[✓] GreenTunnel berjalan di port 8000 (proxy).${NC}"
fi

OS=$(uname -o)
HOST="$(getprop ro.product.manufacturer 2>/dev/null) $(getprop ro.product.model 2>/dev/null)"
KERNEL=$(uname -r)
UPTIME=$(uptime -p 2>/dev/null || echo "N/A")
PACKAGES="$(dpkg --get-selections 2>/dev/null | wc -l)"
SHELL_NAME=$(basename "$SHELL")
MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{printf "%.0f MiB", $2/1024}')
MEM_FREE=$(grep MemAvailable /proc/meminfo | awk '{printf "%.0f MiB", $2/1024}')
MEM_INFO="$MEM_FREE / $MEM_TOTAL"

STORAGE_LINE=$(df ~ 2>/dev/null | awk 'NR==2')
STORAGE_USED_KB=$(echo "$STORAGE_LINE" | awk '{print $3}')
STORAGE_TOTAL_KB=$(echo "$STORAGE_LINE" | awk '{print $2}')
if [[ -n "$STORAGE_USED_KB" && -n "$STORAGE_TOTAL_KB" && "$STORAGE_TOTAL_KB" -gt 0 ]]; then
  USED_GB=$(awk "BEGIN {printf \"%.2f\", $STORAGE_USED_KB / (1024*1024)}")
  TOTAL_GB=$(awk "BEGIN {printf \"%.2f\", $STORAGE_TOTAL_KB / (1024*1024)}")
  PERCENTAGE=$(awk "BEGIN {printf \"%.0f%%\", ($STORAGE_USED_KB / $STORAGE_TOTAL_KB) * 100}")
  STORAGE_INFO="$USED_GB GB / $TOTAL_GB GB"
else
  STORAGE_INFO="N/A"
  PERCENTAGE="N/A"
fi

IP_ADDR=$(ip addr 2>/dev/null | awk '/inet /&&!/127.0.0.1/ {print $2; exit}' | cut -d/ -f1)
IP_ADDR=${IP_ADDR:-N/A}

MAC_ADDR=""
if ip link show wlan0 &>/dev/null; then
  MAC_ADDR=$(ip link show wlan0 | awk '/ether/ {print $2}')
fi
if [[ -z "$MAC_ADDR" ]]; then
  for iface in rmnet_data0 ccmni0 usb0 eth0; do
    if ip link show "$iface" &>/dev/null; then
      MAC_ADDR=$(ip link show "$iface" | awk '/ether/ {print $2}')
      break
    fi
  done
fi
MAC_ADDR=${MAC_ADDR:-N/A}

echo -e "${CYAN}OS        : $OS${NC}"
echo -e "${CYAN}Host      : $HOST${NC}"
echo -e "${CYAN}Kernel    : $KERNEL${NC}"
echo -e "${CYAN}Uptime    : $UPTIME${NC}"
echo -e "${CYAN}Packages  : $PACKAGES pkgs${NC}"
echo -e "${CYAN}Shell     : $SHELL_NAME${NC}"
echo -e "${CYAN}IP Addr   : $IP_ADDR${NC}"
echo -e "${CYAN}MAC Addr  : $MAC_ADDR${NC}"
echo -e "${CYAN}Memory RAM: $MEM_INFO${NC}"
echo -e "${CYAN}Storage   : $STORAGE_INFO  <($PERCENTAGE)>${NC}"
echo -e "${CYAN}Safe Net  : $SAFETY_STATUS${NC}"
echo -e "${CYAN}Fake Off  : $FAKE_OFFLINE_STATUS${NC}"

if pgrep -f "gt" >/dev/null 2>&1; then
  echo -e "${CYAN}Anti-DPI  : ${GREEN}Aktif (GreenTunnel)${NC}"
fi
echo ""

USER_NAME=${USER_NAME:-User}
export PS1="${GREEN}┌─[Anonymous 💀 @${USER_NAME}]─[\A]\n${CYAN}└─[🔥 \w] ➤ ${NC}"

