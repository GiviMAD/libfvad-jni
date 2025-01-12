#!/bin/bash
set -xe
build_lib() {
  TARGET_DIR=src/main/resources/debian-$AARCH
  cmake -B build $CMAKE_ARGS -DCMAKE_C_FLAGS="$CMAKE_CFLAGS" -DCMAKE_INSTALL_PREFIX=$TARGET_DIR
  cmake --build build --config Release
  cmake --install build
  rm -rf build
}
AARCH=$(dpkg --print-architecture)
case $AARCH in
  amd64)
    build_lib
    ;;
  arm64)
    build_lib
    ;;
  armhf|armv7l)
    AARCH=armv7l
    build_lib
    ;;
esac
