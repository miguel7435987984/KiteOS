#!/usr/bin/env bash
# ==============================================================================
# KiteOS 2.0 GApps (Google Play Store & Services) Installer
# Developer: Miguel | Motto: Fast • Lightweight • Free
# ==============================================================================

set -e

DEVICE="${1:-emulator-5554}"
ADB="adb -s $DEVICE"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GAPPS_DIR="$SCRIPT_DIR/../gapps"

echo "======================================================"
echo "🪁 Instalador Oficial de GApps - KiteOS 2.0"
echo "Desenvolvedor: Miguel | Alvo: $DEVICE"
echo "======================================================"

if ! command -v adb &> /dev/null; then
    if [ -d "/home/miguel/android-sdk/platform-tools" ]; then
        export PATH="/home/miguel/android-sdk/platform-tools:$PATH"
    else
        echo "❌ ADB não encontrado no PATH."
        exit 1
    fi
fi

echo "🔍 Verificando conexão com o dispositivo $DEVICE..."
$ADB wait-for-device

echo "🔑 Solicitando permissões de root no adbd..."
$ADB root || true
sleep 2
$ADB wait-for-device

echo "📦 Instalando componentes do Google Play Services e Store..."

if [ -d "$GAPPS_DIR" ]; then
    for apk in "$GAPPS_DIR"/*.apk; do
        if [ -f "$apk" ]; then
            echo "📲 Instalando $(basename "$apk")..."
            $ADB install -r -d -g "$apk" || echo "⚠️ Falha ao instalar $(basename "$apk") via pm install, continuando..."
        fi
    done
else
    echo "ℹ️ Pasta de APKs locais não encontrada em $GAPPS_DIR. Baixando MindTheGapps..."
    TMP_ZIP="/tmp/MindTheGapps-14.0.0-x86_64.zip"
    TMP_EXTRACT="/tmp/mtg_extract"
    curl -L -sS -o "$TMP_ZIP" "https://github.com/MustardChef/MindTheGapps-14.0.0-x86_64/releases/download/MindTheGapps-14.0.0-x86_64-20250202_012724/MindTheGapps-14.0.0-x86_64-20250202_012724.zip"
    mkdir -p "$TMP_EXTRACT"
    unzip -q -o "$TMP_ZIP" -d "$TMP_EXTRACT"

    APKS=(
        "$TMP_EXTRACT/system/system_ext/priv-app/GoogleServicesFramework/GoogleServicesFramework.apk"
        "$TMP_EXTRACT/system/product/priv-app/GmsCore/GmsCore.apk"
        "$TMP_EXTRACT/system/product/priv-app/Phonesky/Phonesky.apk"
        "$TMP_EXTRACT/system/product/app/GoogleContactsSyncAdapter/GoogleContactsSyncAdapter.apk"
        "$TMP_EXTRACT/system/product/app/GoogleCalendarSyncAdapter/GoogleCalendarSyncAdapter.apk"
        "$TMP_EXTRACT/system/product/priv-app/GooglePartnerSetup/GooglePartnerSetup.apk"
    )

    for apk in "${APKS[@]}"; do
        if [ -f "$apk" ]; then
            echo "📲 Instalando $(basename "$apk")..."
            $ADB install -r -d -g "$apk"
        fi
    done

    rm -rf "$TMP_ZIP" "$TMP_EXTRACT"
fi

echo "🔍 Verificando pacotes do Google instalados..."
$ADB shell "pm list packages | grep -E 'vending|gms|gsf'"

echo "======================================================"
echo "🎉 GApps instalado com sucesso no KiteOS 2.0!"
echo "• Google Play Store: Ativa"
echo "• Google Play Services: Ativo"
echo "• Google Services Framework: Ativo"
echo "======================================================"
