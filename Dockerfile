FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget unzip curl git openjdk-11-jdk qemu-kvm \
    libvirt-daemon-system libvirt-clients bridge-utils \
    libgl1-mesa-dev libpulse0 libnss3 libx11-dev \
    socat net-tools adb xvfb

# Install Android SDK
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH

RUN mkdir -p $ANDROID_HOME/cmdline-tools && cd $ANDROID_HOME/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O sdk-tools.zip && \
    unzip sdk-tools.zip && rm sdk-tools.zip && mv cmdline-tools latest

# Accept licenses and install emulator + platform tools
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-30" "system-images;android-30;google_apis;x86_64" "emulator"

# Create and start AVD
RUN echo "no" | avdmanager create avd -n test -k "system-images;android-30;google_apis;x86_64" --force

# Copy your APK into the image
COPY google-authenticator.apk /app/google-authenticator.apk

# Script to launch emulator, install APK, and start the app
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
