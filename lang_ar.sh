#!/usr/bin/env bash

# ============================================
#  TERMUX - KONFIGURASI BAHASA ARAB (TRADISIONAL)
#  TERMUX - تكوين اللغة العربية (الفصحى)
#  BY Unknown-Desert
# ============================================

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ============================================
#  CEK FONT ARAB
#  التحقق من وجود خط عربي
# ============================================
if [[ ! -f "$HOME/.termux/font.ttf" ]]; then
    echo -e "\033[1;33m⚠️  Font Arab tidak terdeteksi! / لم يتم اكتشاف خط عربي!\"\033[0m"
    echo -e "\033[1;33m   Solusi: jalankan install.sh dan pilih bahasa Arab.\033[0m"
    echo -e "\033[1;33m   الحل: قم بتشغيل install.sh واختر اللغة العربية.\033[0m"
    echo ""
    sleep 3
fi

# ============================================
#  WARNA / الألوان
# ============================================
RED=$'\033[1;31m'
WHITE=$'\033[1;37m'
CYAN=$'\033[1;36m'
GREEN=$'\033[1;32m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m'

# ============================================
#  FUNGSI BANTUAN / دوال مساعدة
# ============================================
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

# ============================================
#  FAKE OFFLINE - ALIAS PALSU / أوامر مزيّفة
# ============================================
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

# Definisikan alias palsu dengan pesan Arab
ping()   { echo "ping: مضيف غير معروف / unknown host"; fakeoffcheck "ping"; }
curl()   { echo "curl: انتهت مهلة الشبكة / network timeout"; fakeoffcheck "curl"; }
wget()   { echo "wget: فشل: لا يوجد مسار إلى المضيف / failed: No route to host"; fakeoffcheck "wget"; }
git()    { echo "git: خطأ فادح: تعذر الوصول / fatal: unable to access"; fakeoffcheck "git"; }
npm()    { echo "npm ERR! فشل طلب الشبكة / network request failed"; fakeoffcheck "npm"; }
apt()    { echo "E: تعذر جلب الحزم، تأكد من اتصالك بالإنترنت / Unable to fetch packages"; fakeoffcheck "apt"; }
nc()     { echo "nc: تم رفض الاتصال / connection refused"; fakeoffcheck "nc"; }
ssh()    { echo "ssh: انتهت مهلة الاتصال / connection timeout"; fakeoffcheck "ssh"; }
ping6()  { echo "ping6: لا يمكن الوصول / unreachable"; fakeoffcheck "ping6"; }
ftp()    { echo "ftp: انقطع الاتصال / connection lost"; fakeoffcheck "ftp"; }
scp()    { echo "scp: الشبكة لا يمكن الوصول إليها / network unreachable"; fakeoffcheck "scp"; }
proxy()  { echo "proxy: تم رفض الاتصال / connection refused"; fakeoffcheck "proxy"; unset_fake_proxy; }

set_fake_proxy

export _realcurl=$(command -v curl)
export _realwget=$(command -v wget)
secret_curl() { command curl "$@"; }
secret_wget() { command wget "$@"; }

declare -a DISABLED_ALIASES=()

enable_specific_aliases() {
  for alias_name in "${DISABLED_ALIASES[@]}"; do
    case "$alias_name" in
      ping)   ping()   { echo "ping: مضيف غير معروف / unknown host"; fakeoffcheck "ping"; } ;;
      curl)   curl()   { echo "curl: انتهت مهلة الشبكة / network timeout"; fakeoffcheck "curl"; } ;;
      wget)   wget()   { echo "wget: فشل: لا يوجد مسار إلى المضيف / failed: No route to host"; fakeoffcheck "wget"; } ;;
      git)    git()    { echo "git: خطأ فادح: تعذر الوصول / fatal: unable to access"; fakeoffcheck "git"; } ;;
      npm)    npm()    { echo "npm ERR! فشل طلب الشبكة / network request failed"; fakeoffcheck "npm"; } ;;
      apt)    apt()    { echo "E: تعذر جلب الحزم، تأكد من اتصالك بالإنترنت / Unable to fetch packages"; fakeoffcheck "apt"; } ;;
      nc)     nc()     { echo "nc: تم رفض الاتصال / connection refused"; fakeoffcheck "nc"; } ;;
      ssh)    ssh()    { echo "ssh: انتهت مهلة الاتصال / connection timeout"; fakeoffcheck "ssh"; } ;;
      ping6)  ping6()  { echo "ping6: لا يمكن الوصول / unreachable"; fakeoffcheck "ping6"; } ;;
      ftp)    ftp()    { echo "ftp: انقطع الاتصال / connection lost"; fakeoffcheck "ftp"; } ;;
      scp)    scp()    { echo "scp: الشبكة لا يمكن الوصول إليها / network unreachable"; fakeoffcheck "scp"; } ;;
      proxy)  proxy()  { echo "proxy: تم رفض الاتصال / connection refused"; fakeoffcheck "proxy"; unset_fake_proxy; } ;;
    esac
  done
  DISABLED_ALIASES=()
}

enable_fake_offline() {
  set_fake_proxy
  ping()   { echo "ping: مضيف غير معروف / unknown host"; fakeoffcheck "ping"; }
  curl()   { echo "curl: انتهت مهلة الشبكة / network timeout"; fakeoffcheck "curl"; }
  wget()   { echo "wget: فشل: لا يوجد مسار إلى المضيف / failed: No route to host"; fakeoffcheck "wget"; }
  git()    { echo "git: خطأ فادح: تعذر الوصول / fatal: unable to access"; fakeoffcheck "git"; }
  npm()    { echo "npm ERR! فشل طلب الشبكة / network request failed"; fakeoffcheck "npm"; }
  apt()    { echo "E: تعذر جلب الحزم، تأكد من اتصالك بالإنترنت / Unable to fetch packages"; fakeoffcheck "apt"; }
  nc()     { echo "nc: تم رفض الاتصال / connection refused"; fakeoffcheck "nc"; }
  ssh()    { echo "ssh: انتهت مهلة الاتصال / connection timeout"; fakeoffcheck "ssh"; }
  ping6()  { echo "ping6: لا يمكن الوصول / unreachable"; fakeoffcheck "ping6"; }
  ftp()    { echo "ftp: انقطع الاتصال / connection lost"; fakeoffcheck "ftp"; }
  scp()    { echo "scp: الشبكة لا يمكن الوصول إليها / network unreachable"; fakeoffcheck "scp"; }
  proxy()  { echo "proxy: تم رفض الاتصال / connection refused"; fakeoffcheck "proxy"; unset_fake_proxy; }
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

# ============================================
#  INTERAKSI DENGAN PENGGUNA (DUAL BAHASA)
#  التفاعل مع المستخدم (لغتان)
# ============================================
fakeoff() {
  if [ "$FAKE_OFFLINE_ACTIVE" != "true" ]; then
    echo "ℹ️  Fake Offline tidak aktif / الإنترنت الوهمي غير نشط."
    return
  fi

  echo -e "\n🕵️  Fake Offline Layer aktif / طبقة الإنترنت الوهمي نشطة."
  echo "➤ Pilihan / الخيارات:"
  echo "  [1] Nonaktifkan semua / تعطيل الكل"
  echo "  [2] Pilih perintah tertentu / اختيار أوامر معينة"
  echo "  [3] Abaikan / تجاهل (tidak akan ditanya lagi)"

  echo -n "Pilih / اختر (1/2/3): "
  read -r pilihan

  case "$pilihan" in
    1)
      echo -e "\nPilih mode / اختر الوضع:"
      echo "  [1] Sementara (1-15 menit) / مؤقت (١-١٥ دقيقة)"
      echo "  [2] Sampai Termux ditutup / حتى يتم إغلاق Termux"
      echo -n "Mode / الوضع (1/2): "
      read -r mode

      if [[ "$mode" == "1" ]]; then
        echo -n "Durasi (1-15, default 3): "
        read -r dur
        [[ "$dur" =~ ^[0-9]+$ && "$dur" -ge 1 && "$dur" -le 15 ]] || dur=3

        echo "🛑 Nonaktifkan semua selama $dur menit / تعطيل الكل لمدة $dur دقيقة..."
        disable_fake_offline

        (
          sleep "$((dur * 60))"
          echo -e "\n🔄 Aktifkan ulang / إعادة التفعيل..."
          enable_fake_offline
        ) &
      elif [[ "$mode" == "2" ]]; then
        echo "🛑 Nonaktifkan sampai Termux ditutup / تعطيل حتى إغلاق Termux..."
        disable_fake_offline
      else
        echo "❌ Mode tidak valid / وضع غير صالح. Abaikan."
      fi
      ;;

    2)
      fake_offline_menu
      ;;

    3)
      echo "✅ Tidak akan ditanya lagi / لن يتم السؤال مرة أخرى."
      export FAKE_OFFLINE_REMIND_SHOWN=true
      ;;

    *)
      echo "❌ Pilihan tidak valid / اختيار غير صالح. Abaikan."
      ;;
  esac
}

fake_offline_menu() {
  local ALIASES=(ping curl wget git npm apt nc ssh ping6 ftp scp proxy)

  echo -e "\n🔧 Pilih perintah yang akan dinonaktifkan / اختر الأمر المطلوب تعطيله:"
  for i in "${!ALIASES[@]}"; do
    echo "  $((i + 1)). ${ALIASES[$i]}"
  done

  echo -n "Nomor (pisah spasi) / الأرقام (مفصولة بمسافات): "
  read -r pilihan

  [[ -z "$pilihan" ]] && echo "Tidak ada yang dipilih / لم يتم اختيار شيء." && return

  echo -e "\n🎯 Pilih mode / اختر الوضع:"
  echo "  [1] Sementara (1-15 menit) / مؤقت"
  echo "  [2] Sampai Termux ditutup / حتى إغلاق Termux"
  echo -n "Mode / الوضع (1/2): "
  read -r mode

  if [[ "$mode" != "1" && "$mode" != "2" ]]; then
    echo "❌ Mode tidak valid / وضع غير صالح."
    return
  fi

  local dur=3
  if [[ "$mode" == "1" ]]; then
    echo -n "Durasi (1-15, default 3): "
    read -r dur
    [[ "$dur" =~ ^[0-9]+$ && "$dur" -ge 1 && "$dur" -le 15 ]] || dur=3
  fi

  local selected_aliases=()
  for num in $pilihan; do
    idx=$((num - 1))
    alias_name="${ALIASES[$idx]}"
    if [[ -z "$alias_name" ]]; then
      echo "❌ Nomor $num tidak valid / الرقم $num غير صالح."
      continue
    fi
    selected_aliases+=("$alias_name")
  done

  if [ ${#selected_aliases[@]} -eq 0 ]; then
    echo "Tidak ada perintah valid / لا توجد أوامر صالحة."
    return
  fi

  for alias_name in "${selected_aliases[@]}"; do
    if [[ "$alias_name" == "proxy" ]]; then
      unset_fake_proxy
      unset -f proxy 2>/dev/null
    else
      unset -f "$alias_name" 2>/dev/null
    fi
    echo "🛑 '${alias_name}' dinonaktifkan / تم تعطيله."
  done

  DISABLED_ALIASES=("${selected_aliases[@]}")

  if [[ "$mode" == "1" ]]; then
    (
      sleep $((dur * 60))
      echo -e "\n🔄 Mengaktifkan ulang / إعادة تفعيل: ${DISABLED_ALIASES[*]}"
      local to_reactivate=("${DISABLED_ALIASES[@]}")
      for alias_name in "${to_reactivate[@]}"; do
        case "$alias_name" in
          ping)   ping()   { echo "ping: مضيف غير معروف / unknown host"; fakeoffcheck "ping"; } ;;
          curl)   curl()   { echo "curl: انتهت مهلة الشبكة / network timeout"; fakeoffcheck "curl"; } ;;
          wget)   wget()   { echo "wget: فشل: لا يوجد مسار إلى المضيف / failed: No route to host"; fakeoffcheck "wget"; } ;;
          git)    git()    { echo "git: خطأ فادح: تعذر الوصول / fatal: unable to access"; fakeoffcheck "git"; } ;;
          npm)    npm()    { echo "npm ERR! فشل طلب الشبكة / network request failed"; fakeoffcheck "npm"; } ;;
          apt)    apt()    { echo "E: تعذر جلب الحزم، تأكد من اتصالك بالإنترنت / Unable to fetch packages"; fakeoffcheck "apt"; } ;;
          nc)     nc()     { echo "nc: تم رفض الاتصال / connection refused"; fakeoffcheck "nc"; } ;;
          ssh)    ssh()    { echo "ssh: انتهت مهلة الاتصال / connection timeout"; fakeoffcheck "ssh"; } ;;
          ping6)  ping6()  { echo "ping6: لا يمكن الوصول / unreachable"; fakeoffcheck "ping6"; } ;;
          ftp)    ftp()    { echo "ftp: انقطع الاتصال / connection lost"; fakeoffcheck "ftp"; } ;;
          scp)    scp()    { echo "scp: الشبكة لا يمكن الوصول إليها / network unreachable"; fakeoffcheck "scp"; } ;;
          proxy)  proxy()  { echo "proxy: تم رفض الاتصال / connection refused"; fakeoffcheck "proxy"; unset_fake_proxy; } ;;
        esac
      done
      DISABLED_ALIASES=()
    ) &
  fi
}

fakeoffcheck() {
  if [ "$FAKE_OFFLINE_ACTIVE" = "true" ] && [ "$FAKE_OFFLINE_REMIND_SHOWN" != "true" ]; then
    echo -e "\n⚠️  Terdeteksi perintah '$1' saat Fake Offline aktif / تم اكتشاف استخدام الأمر '$1' أثناء تفعيل الإنترنت الوهمي."
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
        fakeoffcheck "proxy (perintah: $cmd)"
        break
      fi
    fi
  done
}

export PROMPT_COMMAND="detect_fake_proxy_use"

# ============================================
#  PROFIL PENGGUNA (PASSWORD)
#  الملف الشخصي (كلمات المرور)
# ============================================
PROFILE_FILE="$HOME/.cache_profile"

if [ ! -f "$PROFILE_FILE" ]; then
    echo "🛠️  Pengaturan pertama kali / الإعداد لأول مرة..."
    echo ""

    read -p "Gunakan figlet untuk banner? (y/n, default n) / استخدام figlet للشعار؟: " USE_FIGLET
    case "$USE_FIGLET" in
        y|Y|yes|YES) USE_FIGLET="true" ;;
        *) USE_FIGLET="false" ;;
    esac

    echo "Password (kosongkan untuk default kosong) / كلمة المرور (اتركها فارغة للافتراضي الفارغ):"
    read -s PASS1
    echo ""
    read -s PASS2
    echo ""
    read -s PASS3
    echo ""

    read -p "Hint password (opsional) / تلميح كلمة المرور (اختياري): " HINT_PASSWORD

    cat > "$PROFILE_FILE" <<EOF
# Profil pengguna / الملف الشخصي – dibuat otomatis
USE_FIGLET="$USE_FIGLET"
PASSWORD1="$PASS1"
PASSWORD2="$PASS2"
PASSWORD3="$PASS3"
HINT_PASSWORD="$HINT_PASSWORD"
EOF

    echo "✅ Profil disimpan di / تم حفظ الملف الشخصي في $PROFILE_FILE"
    echo ""
fi

source "$PROFILE_FILE"

# ============================================
#  AUTHENTIKASI 3 PASSWORD
#  المصادقة بثلاث كلمات مرور
# ============================================
clear

center "${YELLOW}       Masukkan 3 Password (Tersembunyi) / أدخل ٣ كلمات مرور (غير مرئية)${NC}"
echo ""

if [ -n "$HINT_PASSWORD" ]; then
    echo -e "${YELLOW}Hint / تلميح: $HINT_PASSWORD${NC}"
fi

echo -ne "${YELLOW}Pass 1 / كلمة المرور ١: ${NC}"
read -s USER1 && tput cuu1 && tput el && echo ""
[[ "$USER1" != "$PASSWORD1" ]] && echo -e "${RED}❌ Password 1 salah / كلمة المرور ١ خاطئة.${NC}" && exit 1

echo -ne "${YELLOW}Pass 2 / كلمة المرور ٢: ${NC}"
read -s USER2 && tput cuu1 && tput el && echo ""
[[ "$USER2" != "$PASSWORD2" ]] && echo -e "${RED}❌ Password 2 salah / كلمة المرور ٢ خاطئة.${NC}" && exit 1

echo -ne "${YELLOW}Pass 3 / كلمة المرور ٣: ${NC}"
read -s USER3 && tput cuu1 && tput el && echo ""
[[ "$USER3" != "$PASSWORD3" ]] && echo -e "${RED}❌ Password 3 salah / كلمة المرور ٣ خاطئة.${NC}" && exit 1

clear

# ============================================
#  BANNER / الشعار
# ============================================
if [ "$USE_FIGLET" = "true" ]; then
  if command -v figlet >/dev/null 2>&1; then
    if command -v lolcat >/dev/null 2>&1 && echo "test" | lolcat >/dev/null 2>&1; then
      figlet -f slant "مجهول" | while IFS= read -r line; do center "$line"; done | lolcat
    else
      figlet -f slant "مجهول" | while IFS= read -r line; do center "$line"; done
    fi
  else
    echo -e "${RED}❌ Figlet tidak ditemukan / لم يتم العثور على figlet.${NC}"
    center "${CYAN}مجهول${NC}"
  fi
else
  center "${CYAN}مجهول${NC}"
fi
echo ""

TODAY=$(date +"%A، %d %B %Y")
center "${WHITE}     📆 $TODAY${NC}"
echo ""
center "${CYAN}        ⫸   SELAMAT DATANG / مرحباً بكم في TERMUX BY Unknown-Desert   ⫷${NC}"
echo ""
sleep 0.2

# ============================================
#  MOTIVASI / تحفيز
# ============================================
MOTIVASI_LIST=(
  "لا تستسلم أبداً / Pantang Menyerah"
  "الفشل هو معلم النجاح / Gagal itu Guru"
  "استمر حتى لو كان صعباً / Teruskan Walau Berat"
  "اخسر اليوم وانهض غداً / Kalah Hari Ini, Bangkit Besok"
  "لا نجاح بدون فشل / Tak Ada Sukses Tanpa Gagal"
  "حارب الكسل / Lawan Malas"
  "لا تستسلم يا صديقي / Jangan Menyerah Bro!"
  "ابدأ الآن / Mulai Sekarang"
  "أنت قادر / Kamu Bisa!"
  "تقدّم بثقة / Maju dengan Percaya Diri"
)
RANDOM_MOTIVASI=${MOTIVASI_LIST[$RANDOM % ${#MOTIVASI_LIST[@]}]}
center "${WHITE} 🥶 MOTIVASI / تحفيز"
center "${WHITE}              ${CYAN}${RANDOM_MOTIVASI}${NC}"
echo ""

# ============================================
#  DNS TERENKRIPSI / DNS مشفّر
# ============================================
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
  pgrep -f "cloudflared proxy-dns" >/dev/null && return 0 || return 1
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
  pgrep -f "unbound" >/dev/null && return 0 || return 1
}

if try_cloudflared; then
  IS_SAFE=true
  echo -e "${GREEN}[✓] cloudflared proxy-dns aktif / نشط (DoH via Cloudflare).${NC}"
  echo "nameserver 127.0.0.1#5053" > "$DNS_FILE"
else
  if try_unbound; then
    IS_SAFE=true
    echo -e "${GREEN}[✓] Unbound aktif / نشط (DoT via Cloudflare).${NC}"
    echo "nameserver 127.0.0.1#5353" > "$DNS_FILE"
  else
    echo -e "${RED}[✗] Semua metode DNS gagal / فشلت جميع طرق DNS. Fallback ke AdGuard.${NC}"
    echo "nameserver 94.140.14.14" > "$DNS_FILE"
    echo "nameserver 94.140.15.15" >> "$DNS_FILE"
  fi
fi

# ============================================
#  BLOKIR DOMAIN / حظر النطاقات
# ============================================
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

echo -e "${GREEN}[✓] Blokir domain iklan/malware diterapkan / تم تطبيق حظر الإعلانات والبرمجيات الخبيثة.${NC}"

# ============================================
#  GREEN TUNNEL (ANTI-DPI)
# ============================================
SAFETY_STATUS="${RED}False${NC}"
[ "$IS_SAFE" = true ] && SAFETY_STATUS="${GREEN}True${NC}"

if command -v gt >/dev/null 2>&1; then
  pkill -f "gt" 2>/dev/null
  {
    gt --dns doh --no-system-proxy --log-level error >/dev/null 2>&1 &
  } 2>/dev/null
  disown 2>/dev/null
  echo -e "${GREEN}[✓] GreenTunnel berjalan di port 8000 / يعمل على المنفذ 8000.${NC}"
fi

# ============================================
#  INFORMASI SISTEM / معلومات النظام
# ============================================
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

echo -e "${CYAN}OS / النظام      : $OS${NC}"
echo -e "${CYAN}Host / الجهاز   : $HOST${NC}"
echo -e "${CYAN}Kernel / النواة : $KERNEL${NC}"
echo -e "${CYAN}Uptime / مدة التشغيل : $UPTIME${NC}"
echo -e "${CYAN}Packages / الحزم: $PACKAGES pkg${NC}"
echo -e "${CYAN}Shell / الصدفة  : $SHELL_NAME${NC}"
echo -e "${CYAN}IP Address / عنوان IP : $IP_ADDR${NC}"
echo -e "${CYAN}MAC Address / عنوان MAC: $MAC_ADDR${NC}"
echo -e "${CYAN}Memory RAM / الذاكرة: $MEM_INFO${NC}"
echo -e "${CYAN}Storage / التخزين: $STORAGE_INFO  <($PERCENTAGE)>${NC}"
echo -e "${CYAN}Safe Net / الشبكة الآمنة: $SAFETY_STATUS${NC}"
echo -e "${CYAN}Fake Offline / الإنترنت الوهمي: $FAKE_OFFLINE_STATUS${NC}"

if pgrep -f "gt" >/dev/null 2>&1; then
  echo -e "${CYAN}Anti-DPI / مكافحة DPI: ${GREEN}Aktif / نشط (GreenTunnel)${NC}"
fi
echo ""

# ============================================
#  PROMPT / موجه الأوامر
# ============================================
export PS1="${GREEN}┌─[مجهول 💀 @User]─[\A]\n${CYAN}└─[🔥 \w] ➤ ${NC}"