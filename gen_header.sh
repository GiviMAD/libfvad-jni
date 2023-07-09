set -xe

LIB_SRC=src/main/java/io/github/givimad/libfvadjni
javac -h src/main/native \
$LIB_SRC/internal/NativeUtils.java \
$LIB_SRC/VoiceActivityDetector.java

rm -rf $LIB_SRC/*.class $LIB_SRC/internal/*.class
