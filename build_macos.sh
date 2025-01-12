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

TARGET_DIR=src/main/resources/macos-$AARCH_NAME

cmake -Bbuild -DCMAKE_INSTALL_PREFIX=$TARGET_DIR -DCMAKE_OSX_DEPLOYMENT_TARGET=$TARGET_VERSION -DCMAKE_OSX_ARCHITECTURES=$AARCH
cmake --build build --config Release
cmake --install build
rm -rf build