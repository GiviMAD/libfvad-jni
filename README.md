# LibfvadJNI

A JNI wrapper for [libfvad](https://github.com/dpirch/libfvad), allows voice activity detection in Java.

## Platform support 

This library aims to support the following platforms:

* Windows x86_64 (built with mingw)
* Debian x86_64/arm64 (built with GLIBC 2.31)
* macOS x86_64/arm64 (built targeting v11.0)

The native binaries for those platforms are included in the distributed jar.

Please open an issue if you found it don't work on any of the supported platforms.

## Installation

The package is distributed through [Maven Central](https://central.sonatype.com/artifact/io.github.givimad/libfvad-jni).

You can also find the package's jar attached to each [release](https://github.com/GiviMAD/libfvad-jni/releases).

## Example

A very basic example extracted from the tests.

```java
        VoiceActivityDetector vad = VoiceActivityDetector.newInstance();
        int sampleRate = 16000;
        vad.setMode(VoiceActivityDetector.Mode.QUALITY);
        vad.setSampleRate(VoiceActivityDetector.SampleRate.fromValue(sampleRate));
        short[] samples = ...;
        int samplesLength = samples.length;
        int step = (sampleRate / 1000) * 10; // 10ms step (only allows 10, 20 or 30ms frame)
        int detection = 0;
        for(int i = 0; i < samplesLength - step; i+=step) {
            short[] frame = Arrays.copyOfRange(samples, i, i+step);
            if(vad.process(frame)) {
                // voice has been detected
                detection = i;
                break;
            }
        }
        vad.close();
```

## Building and testing the project.

You need Java and Cpp setup.

After cloning the project you need to init the libfvad submodule by running:

```sh
git submodule update --init
```

Run the appropriate build script for your platform (build_debian.sh, build_macos.sh or build_win.ps1), it will place the native library file on the resources directory.

Finally you can run the project tests to confirm it works:

```sh
mvn test
```

BR
