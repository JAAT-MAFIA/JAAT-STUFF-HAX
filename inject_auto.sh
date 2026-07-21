#!/system/bin/sh

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

ABI=$(getprop ro.product.cpu.abi 2>/dev/null)
[ -z "$ABI" ] && ABI=$(uname -m 2>/dev/null)

case "$ABI" in
    *arm64*|*aarch64*)
        INJECTOR="$BASE_DIR/JAATSTUFFInjector_arm64"
        ;;
    *arm*|*v7*)
        INJECTOR="$BASE_DIR/JAATSTUFFInjector_arm32"
        ;;
    *x86_64*|*amd64*)
        INJECTOR="$BASE_DIR/JAATSTUFFInjector_x86_64"
        ;;
    *x86*)
        INJECTOR="$BASE_DIR/JAATSTUFFInjector_x86"
        ;;
    *)
        INJECTOR="$BASE_DIR/JAATSTUFFInjector_arm64"
        ;;
esac

if [ ! -f "$INJECTOR" ]; then
    INJECTOR="$BASE_DIR/JAATSTUFFInjector"
fi

if [ -f "$INJECTOR" ]; then
    chmod 777 "$INJECTOR" 2>/dev/null
    if [ $# -eq 0 ]; then
        exec "$INJECTOR"
    else
        exec "$INJECTOR" "$@"
    fi
else
    echo "[!] JAATSTUFFInjector binary missing!"
    exit 1
fi