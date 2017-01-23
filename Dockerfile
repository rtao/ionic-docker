FROM node:7.4.0

# Install Java 8
COPY java-8-debian.list /etc/apt/sources.list.d/
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 \
    && apt-get update \
    && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 \
    select true | /usr/bin/debconf-set-selections \
    && apt-get install -y --force-yes oracle-java8-installer

# Install Deps
RUN dpkg --add-architecture i386 && apt-get update \
    && apt-get install -y --force-yes expect wget \
    libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 unzip

# Install Android SDK
RUN cd /opt && wget --output-document=android-sdk.tgz --quiet \
    http://dl.google.com/android/android-sdk_r24.3.3-linux.tgz \
    && tar xzf android-sdk.tgz && rm -f android-sdk.tgz \
    && chown -R root.root android-sdk-linux

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install sdk elements
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools
RUN chmod +x /opt/tools/android-accept-licenses.sh
RUN ["/opt/tools/android-accept-licenses.sh", "android update sdk --all --force --no-ui --filter platform-tools,tools,build-tools-23,build-tools-23.0.2,android-23,addon-google_apis_x86-google-23,extra-android-support,extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services,sys-img-armeabi-v7a-android-23"]
