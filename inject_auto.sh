#!/system/bin/sh

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── JAAT STUFF BGMI Injector Config ──────────────────────────────────────
LIB_NAME="$BASE_DIR/libCoderX.so"
VERSION_FILE="$BASE_DIR/version.txt"
INJECTOR="$BASE_DIR/JAATSTUFFInjector"

# JSON from JAAT GitHub — format: {"version":"x.x","link":"https://...libCoderX.so"}
JSON_URL="https://raw.githubusercontent.com/JAAT-MAFIA/JAAT-STUFF-HAX/main/libraries.json"

MIN_SIZE=$((5 * 1024 * 1024)) # 5MB min (libCoderX ~6MB)

# ───────────────────────────────────────────────
# Helper: Get file size (portable)
# ───────────────────────────────────────────────
get_size() {
    if command -v stat >/dev/null 2>&1; then
        stat -c%s "$1" 2>/dev/null || stat -f%z "$1" 2>/dev/null
    else
        wc -c < "$1" 2>/dev/null
    fi
}

# ───────────────────────────────────────────────
# Helper: Download (universal)
# ───────────────────────────────────────────────
download_file() {
    URL="$1"
    OUT="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -L -o "$OUT" "$URL"
        return $?
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$OUT" "$URL"
        return $?
    elif command -v busybox >/dev/null 2>&1; then
        busybox wget -O "$OUT" "$URL"
        return $?
    elif command -v toybox >/dev/null 2>&1; then
        toybox wget -O "$OUT" "$URL"
        return $?
    else
        echo "[!] No downloader available (curl/wget/busybox/toybox missing)"
        return 1
    fi
}

# ───────────────────────────────────────────────
# Fetch JSON
# ───────────────────────────────────────────────

echo "[*] JAAT STUFF — Checking for updates..."

TMP_JSON="$BASE_DIR/tmp.json"
rm -f "$TMP_JSON"

download_file "$JSON_URL" "$TMP_JSON" || {
    echo "[!] Failed to fetch JSON"
    exit 9
}

JSON_DATA=$(cat "$TMP_JSON")

REMOTE_VERSION=$(echo "$JSON_DATA" | grep -o '"version": *"[^"]*"' | cut -d '"' -f4)
REMOTE_LINK=$(echo "$JSON_DATA" | grep -o '"link": *"[^"]*"' | cut -d '"' -f4)

rm -f "$TMP_JSON"

LOCAL_VERSION=""
[ -f "$VERSION_FILE" ] && LOCAL_VERSION=$(cat "$VERSION_FILE")

NEED_DOWNLOAD=0

# Missing lib
if [ ! -f "$LIB_NAME" ]; then
    echo "[*] libCoderX.so missing — download zaroori"
    NEED_DOWNLOAD=1
fi

# Size check
if [ -f "$LIB_NAME" ]; then
    FILE_SIZE=$(get_size "$LIB_NAME")

    if [ -z "$FILE_SIZE" ] || [ "$FILE_SIZE" -lt "$MIN_SIZE" ]; then
        echo "[*] libCoderX.so corrupted / too small"
        NEED_DOWNLOAD=1
    fi
fi

# Version mismatch
if [ "$REMOTE_VERSION" != "$LOCAL_VERSION" ]; then
    echo "[*] Version mismatch (local: $LOCAL_VERSION, remote: $REMOTE_VERSION)"
    NEED_DOWNLOAD=1
fi

# ───────────────────────────────────────────────
# Download
# ───────────────────────────────────────────────

if [ "$NEED_DOWNLOAD" -eq 1 ]; then
    echo "[*] Downloading latest lib..."

    rm -f "$LIB_NAME"

    download_file "$REMOTE_LINK" "$LIB_NAME" || {
        echo "[!] Download failed"
        exit 10
    }

    chmod 777 "$LIB_NAME" 2>/dev/null

    FILE_SIZE=$(get_size "$LIB_NAME")
    if [ -z "$FILE_SIZE" ] || [ "$FILE_SIZE" -lt "$MIN_SIZE" ]; then
        echo "[!] Downloaded file invalid"
        rm -f "$LIB_NAME"
        exit 11
    fi

    echo "$REMOTE_VERSION" > "$VERSION_FILE"

    echo "[+] Updated to version $REMOTE_VERSION"
else
    echo "[*] Library OK (v$LOCAL_VERSION)"
fi

# ───────────────────────────────────────────────
# Game Selection
# ───────────────────────────────────────────────

echo "=============================="
echo " Select Game to Inject"
echo "=============================="
echo "1) BGMI"
echo "2) Global"
echo "3) VNG"
echo "4) Korea"
echo "5) Taiwan"
echo "6) DFM"
echo "=============================="
echo -n "Enter choice [1-6]: "
read choice

[ -z "$choice" ] && exit 1

case "$choice" in
    1) PACKAGE_NAME="com.pubg.imobile" ;;
    2) PACKAGE_NAME="com.tencent.ig" ;;
    3) PACKAGE_NAME="com.vng.pubgmobile" ;;
    4) PACKAGE_NAME="com.pubg.krmobile" ;;
    5) PACKAGE_NAME="com.rekoo.pubgm" ;;
    6) PACKAGE_NAME="com.proxima.dfm" ;;
    *) echo "[!] Invalid choice"; exit 2 ;;
esac

ACTIVITY_NAME="com.epicgames.ue4.SplashActivity"

# ───────────────────────────────────────────────
# File Check
# ───────────────────────────────────────────────

for file in "$LIB_NAME" "$INJECTOR"; do
    [ ! -f "$file" ] && echo "[!] Missing $file" && exit 3
    chmod 777 "$file" 2>/dev/null
done

chcon u:object_r:system_file:s0 "$LIB_NAME" 2>/dev/null

# ───────────────────────────────────────────────
# Launch Game
# ───────────────────────────────────────────────

echo "[*] Restarting game..."

am force-stop "$PACKAGE_NAME"
am start -n "$PACKAGE_NAME/$ACTIVITY_NAME"

sleep 2

# ───────────────────────────────────────────────
# Injection
# ───────────────────────────────────────────────

for i in 1 2 3; do
    echo "[*] Inject attempt $i..."
    # B8 FIX: v5.x uses --package and --libs (double-dash argparse format)
    # Old: AndKittyInjector -pkg <name> -lib <path>
    # New: AndKittyInjector --package <name> --libs <path>
    "$INJECTOR" --package "$PACKAGE_NAME" --libs "$LIB_NAME" && break
    sleep 1
done

if [ $? -eq 0 ]; then
    echo "[+] Injection Done"
else
    echo "[!] Injection failed"
    exit 6
fi