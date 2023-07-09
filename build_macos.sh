set -xe

AARCH=${1:-$(uname -m)}
case "$AARCH" in
  x86_64|amd64)
    AARCH=x86_64
    AARCH_NAME=amd64
    TARGET_VERSION=11.0
    CFLAGS=""
    CXXFLAGS=""
    LDFLAGS=""
    ;;
  arm64|aarch64)
    AARCH=arm64
    AARCH_NAME=arm64
    TARGET_VERSION=11.0
    CFLAGS=""
    CXXFLAGS=""
    LDFLAGS=""
    ;;
  *)
    echo Unsupported arch $AARCH
    ;;
    
esac

INCLUDE_JAVA="-I $JAVA_HOME/include -I $JAVA_HOME/include/darwin"
TARGET=$AARCH-apple-macosx$TARGET_VERSION

(cd src/main/native/libfvad && cmake -DCMAKE_OSX_DEPLOYMENT_TARGET=$TARGET_VERSION -DCMAKE_OSX_ARCHITECTURES=$AARCH . && cmake --build .)

g++ -c -std=c++11 -arch "$AARCH" -O3 -DNDEBUG -fPIC $INCLUDE_JAVA -I src/main/native/libfvad/include $CXXFLAGS \
$CXXFLAGS --target="$TARGET" \
src/main/native/io_github_givimad_libfvadjni_VoiceActivityDetector.cpp -o src/main/native/io_github_givimad_libfvadjni_VoiceActivityDetector.o

g++ -arch "$AARCH" --target="$TARGET" -dynamiclib -I src/main/native -o src/main/resources/macos-$AARCH_NAME/libfvadjni.dylib src/main/native/libfvad/src/libfvad.a src/main/native/io_github_givimad_libfvadjni_VoiceActivityDetector.o -lc $LDFLAGS

rm -rf src/main/native/*.o
(cd src/main/native/libfvad && git clean -d -f -x)
