package io.github.givimad.libfvadjni;

import io.github.givimad.libfvadjni.internal.NativeUtils;

import java.io.IOException;

/**
 * Libfvad voice activity detector.
 */
public class VoiceActivityDetector implements AutoCloseable {

    private static boolean libraryLoaded;

    private final int pointerRef;
    private boolean closed;

    //region native api
    private static native int fvadNew();

    private native void fvadReset(int inst);

    private native int fvadSetMode(int inst, int mode);

    private native int fvadSetSampleRate(int inst, int sample_rate);

    private native int fvadProcess(int inst, short[] frame, int length);

    private native void fvadFree(int inst);

    //endregion

    private VoiceActivityDetector(int pointerRef) {
        this.pointerRef = pointerRef;
    }

    /**
     * Sets the vad mode
     *
     * @param mode the desired vad mode
     * @return true when successful
     * @throws IOException instance is closed
     */
    public boolean setMode(Mode mode) throws IOException {
        assertOpen();
        return fvadSetMode(pointerRef, mode.ordinal()) == 0;
    }

    /**
     * Sets the detector sample rate.
     *
     * @param sampleRate desired audio sample rate
     * @return true when successful
     * @throws IOException instance is closed
     */
    public boolean setSampleRate(SampleRate sampleRate) throws IOException {
        assertOpen();
        return fvadSetSampleRate(pointerRef, sampleRate.toValue()) == 0;
    }

    /**
     * Process audio frame. Only allow audio frames of 10, 20 or 30 ms.
     * You should calculate the frame length to use. Formula sampleRate/1000*ms.
     *
     * @param frame audio samples
     * @return true if voice is detected
     * @throws IOException              instance is closed
     * @throws IllegalArgumentException incorrect frame length
     */
    public boolean process(short[] frame) throws IOException, IllegalArgumentException {
        return process(frame, frame.length);
    }

    /**
     * Process audio frame.
     *
     * @param frame  audio samples
     * @param length audio samples length
     * @return true if voice is detected
     * @throws IOException              instance is closed
     * @throws IllegalArgumentException length parameter is incorrect
     */
    public boolean process(short[] frame, int length) throws IOException, IllegalArgumentException {
        assertOpen();
        var result = fvadProcess(pointerRef, frame, length);
        if (result == -1) {
            throw new IllegalArgumentException("Invalid frame length");
        }
        return result == 1;
    }

    /**
     * Resets the vad state.
     *
     * @throws IOException is detector is closed
     */
    public void reset() throws IOException {
        assertOpen();
        fvadReset(pointerRef);
    }

    @Override
    public void close() {
        if (!closed) {
            closed = true;
            fvadFree(pointerRef);
        }
    }

    /**
     * Available sample rates.
     */
    public enum SampleRate {
        /** 8000 samples per seconds */
        S8000(8000),
        /** 8000 samples per seconds */
         S16000(16000),
        /** 8000 samples per seconds */
         S32000(32000),
        /** 8000 samples per seconds */
         S48000(48000);

        SampleRate(final int value) {
            this.value = value;
        }
        private final int value;

        /**
         * Get value.
         * @return sample rate int value.
         */
        public int toValue() {
            return value;
        }
        /**
         * Initialize from number. Only 8000, 16000, 32000, 48000 are allowed.
         *
         * @param value desired sample rate.
         * @return sample rate enum instance.
         * @throws IllegalArgumentException unsupported value.
         */
        public static SampleRate fromValue(int value) throws IllegalArgumentException {
            return switch (value) {
                case 8000 -> S8000;
                case 16000 -> S16000;
                case 32000 -> S32000;
                case 48000 -> S48000;
                default -> throw new IllegalArgumentException("Unsupported sample rate.");
            };
        }
    }

    /**
     * Available vad modes.
     */
    public enum Mode {
        /**
         * Least aggressive about filtering out non-speech
         */
        QUALITY,
        /**
         * Least aggressive about filtering out non-speech
         */
        LOW_BITRATE,
        /**
         * Restrictive in reporting speech
         */
        AGGRESSIVE,
        /**
         * More restrictive in reporting speech
         */
        VERY_AGGRESSIVE,

    }

    /**
     * Initializes a {@link VoiceActivityDetector} instance.
     * @return a new {@link VoiceActivityDetector}.
     * @throws IOException native library unavailable.
     */
    public static VoiceActivityDetector newInstance() throws IOException {
        assertRegistered();
        return new VoiceActivityDetector(fvadNew());
    }

    /**
     * Register the native library, should be called at first.
     *
     * @throws IOException when unable to load the native library
     */
    public static void loadLibrary() throws IOException {
        if (libraryLoaded) {
            return;
        }
        String bundleLibraryPath = null;
        String osName = System.getProperty("os.name").toLowerCase();
        String osArch = System.getProperty("os.arch").toLowerCase();
        if (osName.contains("win")) {
            if (osArch.contains("amd64") || osArch.contains("x86_64")) {
                bundleLibraryPath = "/win-amd64/libfvadjni.dll";
            }
        } else if (osName.contains("nix") || osName.contains("nux") || osName.contains("aix")) {
            if (osArch.contains("amd64") || osArch.contains("x86_64")) {
                bundleLibraryPath = "/debian-amd64/libfvadjni.so";
            } else if (osArch.contains("aarch64") || osArch.contains("arm64")) {
                bundleLibraryPath = "/debian-arm64/libfvadjni.so";
            } else if (osArch.contains("armv7") || osArch.contains("arm")) {
                bundleLibraryPath = "/debian-armv7l/libfvadjni.so";
            }
        } else if (osName.contains("mac") || osName.contains("darwin")) {
            if (osArch.contains("amd64") || osArch.contains("x86_64")) {
                bundleLibraryPath = "/macos-amd64/libfvadjni.dylib";
            } else if (osArch.contains("aarch64") || osArch.contains("arm64")) {
                bundleLibraryPath = "/macos-arm64/libfvadjni.dylib";
            }
        }
        if (bundleLibraryPath == null) {
            throw new java.io.IOException("libfvad-jni: Unsupported platform " + osName + " - " + osArch + ".");
        }
        NativeUtils.loadLibraryFromJar(bundleLibraryPath);
        libraryLoaded = true;
    }
    private static void assertRegistered() throws IOException {
        if (!libraryLoaded) {
            throw new IOException("Native library is unavailable.");
        }
    }
    private void assertOpen() throws IOException {
        if (closed) {
            throw new IOException("VAD is closed.");
        }
    }
}
