#!/usr/bin/env bash
# ==============================================================================
# KiteOS 2.0 GUI Launcher (No Terminal)
# ==============================================================================

export ANDROID_HOME="/home/miguel/android-sdk"
export ANDROID_AVD_HOME="/home/miguel/.android/avd"
export JAVA_HOME="/home/miguel/android-sdk/jdk17"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$JAVA_HOME/bin:$PATH"

# Se o emulador já estiver rodando, focar nele
if adb -s emulator-5554 get-state 2>/dev/null | grep -q "device"; then
    notify-send "KiteOS 2.0" "O KiteOS já está aberto e em execução!" -i kiteos 2>/dev/null || true
    exit 0
fi

notify-send "KiteOS 2.0" "Iniciando o KiteOS 2.0 (Android 14)..." -i kiteos 2>/dev/null || true

# Iniciar o emulador gráfico em segundo plano sem necessidade de terminal
nohup emulator -avd "KiteOS_2.0" -writable-system -gpu auto > /tmp/kiteos-gui.log 2>&1 &
