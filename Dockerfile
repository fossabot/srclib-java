FROM maven:3-jdk-8

RUN apt-get update -y

# Gradle

ENV GRADLE_VERSION 2.10
WORKDIR /usr/lib
RUN wget https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
RUN unzip "gradle-${GRADLE_VERSION}-bin.zip"
RUN ln -s "/usr/lib/gradle-${GRADLE_VERSION}/bin/gradle" /usr/bin/gradle
RUN rm "gradle-${GRADLE_VERSION}-bin.zip"

# Install Android SDK
RUN cd /opt && wget -q http://dl.google.com/android/android-sdk_r24.3.4-linux.tgz 
RUN cd /opt && tar xzf android-sdk_r24.3.4-linux.tgz 
RUN cd /opt && rm -f android-sdk_r24.3.4-linux.tgz
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
RUN echo y | android update sdk --filter platform-tools,build-tools-23.0.2,build-tools-23.0.1,build-tools-23,build-tools-22.0.1,build-tools-22,build-tools-21.1.2,build-tools-21.1.1,build-tools-21.1,build-tools-21.0.2,build-tools-21.0.1,build-tools-21,build-tools-20,build-tools-19.1,build-tools-19.0.3,build-tools-19.0.2,build-tools-19.0.1,build-tools-19,build-tools-18.1.1,build-tools-18.1,build-tools-18.0.1,build-tools-17,android-23,android-22,android-21,android-20,android-19,android-18,android-17,android-16,android-15,android-14 --no-ui --force --all
RUN echo y | android update sdk --filter extra-android-support --no-ui --force --all
RUN echo y | android update sdk --filter extra-android-m2repository,extra-google-m2repository --no-ui --force --all

# See https://code.google.com/p/android/issues/detail?id=82711
RUN apt-get install -y lib32z1 lib32ncurses5 lib32stdc++6

# Adding special JDK
WORKDIR /srclib/srclib-java
RUN wget https://srclib-support.s3-us-west-2.amazonaws.com/srclib-java/build/bundled-jdk1.8.0_45.tar.gz
RUN tar xfz bundled-jdk1.8.0_45.tar.gz
RUN rm bundled-jdk1.8.0_45.tar.gz

# Add this toolchain
RUN apt-get install -qq make
ENV SRCLIBPATH /srclib
ADD . /srclib/srclib-java/
RUN cd /srclib/srclib-java && make
