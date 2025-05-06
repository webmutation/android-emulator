#!/bin/bash

# Start the emulator (headless)
emulator -avd test -no-audio -no-window -no-snapshot-load -no-snapshot-save -no-boot-anim -gpu off &

# Wait for the emulator to boot
echo "Waiting for emulator to boot..."
adb wait-for-device
BOOT_COMPLETED="0"
while [[ "$BOOT_COMPLETED" != "1" ]]; do
    BOOT_COMPLETED=$(adb shell getprop sys.boot_completed | tr -d '\r')
    sleep 2
done

echo "Emulator booted!"

# Install the 2FA APK
adb install /app/google-authenticator.apk

# Launch the app
adb shell monkey -p com.google.android.apps.authenticator2 -c android.intent.category.LAUNCHER 1

# Keep container running
tail -f /dev/null
