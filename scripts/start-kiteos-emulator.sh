#!/usr/bin/env bash
# ==============================================================================
# KiteOS 2.0 Official Emulator Launcher & Asset Injector
# Base: Android 14 (UDC) | Developer: Miguel
# ==============================================================================

set -e

export ANDROID_HOME="/home/miguel/android-sdk"
export ANDROID_AVD_HOME="/home/miguel/.android/avd"
export JAVA_HOME="/home/miguel/android-sdk/jdk17"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$JAVA_HOME/bin:$PATH"

KITEOS_DIR="/home/miguel/Documentos/KiteOS"
AVD_NAME="KiteOS_2.0"
ADB="adb -s emulator-5554"

echo "======================================================"
echo "🪁 Iniciando KiteOS 2.0 (Android 14) no Emulador..."
echo "Desenvolvedor: Miguel | Motto: Fast • Lightweight • Free"
echo "Target Seguro: emulator-5554 (celulares USB isolados)"
echo "======================================================"

# Iniciar o emulador com sistema gravável e aceleração gráfica
echo "📲 Abrindo emulador com suporte a injeção do KiteOS..."
emulator -avd "$AVD_NAME" -writable-system -gpu auto "$@" &
EMULATOR_PID=$!

echo "⏳ Aguardando emulador emulator-5554 conectar ao ADB (PID: $EMULATOR_PID)..."
$ADB wait-for-device

echo "🔑 Obtendo acesso root no emulador..."
$ADB root || true
sleep 3
$ADB wait-for-device

echo "🔓 Remontando partição do sistema como leitura e escrita..."
$ADB remount || true
sleep 3

echo "🎨 Injetando Bootanimation Oficial do KiteOS 2.0 (Prisma 3D)..."
if [ -f "$KITEOS_DIR/bootanimation/bootanimation.zip" ]; then
    $ADB shell "mkdir -p /system/media /product/media" || true
    $ADB push "$KITEOS_DIR/bootanimation/bootanimation.zip" /system/media/bootanimation.zip
    $ADB push "$KITEOS_DIR/bootanimation/bootanimation.zip" /product/media/bootanimation.zip
    $ADB shell "chmod 644 /system/media/bootanimation.zip /product/media/bootanimation.zip"
    echo "✅ Bootanimation instalada com sucesso!"
fi

echo "🖼️ Injetando Papel de Parede Ultra HD do KiteOS 2.0..."
if [ -f "$KITEOS_DIR/wallpapers/kiteos_default_wallpaper.png" ]; then
    $ADB push "$KITEOS_DIR/wallpapers/kiteos_default_wallpaper.png" /data/local/tmp/kiteos_wallpaper.png
    $ADB shell "mkdir -p /data/system/users/0" || true
    $ADB shell "cp /data/local/tmp/kiteos_wallpaper.png /data/system/users/0/wallpaper || true"
    $ADB shell "chmod 600 /data/system/users/0/wallpaper || true"
    echo "✅ Papel de parede injetado com sucesso!"
fi

echo "⚙️ Configurando propriedades de identidade do KiteOS 2.0..."
$ADB shell "setprop ro.kite.version 2.0"
$ADB shell "setprop ro.kite.developer Miguel"
$ADB shell "setprop ro.kite.motto Fast-Lightweight-Free"

echo "⏳ Aguardando boot do sistema finalizar..."
until [ "$($ADB shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
    sleep 2
done

# Aplicar o papel de parede usando WallpaperManager via shell se disponível
$ADB shell "am broadcast -a android.intent.action.WALLPAPER_CHANGED" 2>/dev/null || true

echo ""
echo "======================================================"
echo "🎉 KiteOS 2.0 ESTÁ RODANDO COM SUCESSO NO EMULADOR!"
echo "• Versão: 2.0 (Android 14 UpsideDownCake)"
echo "• Desenvolvedor: Miguel"
echo "• Bootanimation e Wallpaper customizados ativos"
echo "======================================================"

# Manter o processo aguardando o emulador
wait $EMULATOR_PID
