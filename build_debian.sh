#!/bin/bash
set -xe
build_lib() {
  (cd src/main/native/libfvad && cmake . && cmake --build .)
  #exit 0
  g++ -c -std=c++11 -O3 -DNDEBUG -fPIC -pthread -I${JAVA_HOME}/include -I${JAVA_HOME}/include/linux -I src/main/native/libfvad/include $CXXFLAGS \
  src/main/native/io_github_givimad_libfvadjni_VoiceActivityDetector.cpp -o src/main/native/io_github_givimad_libfvadjni_VoiceActivityDetector.o

  g++ -shared -fPIC -pthread $CXXFLAGS -I src/main/native -I src/main/native/libfvad/include -o src/main/resources/debian-$AARCH/libfvadjni.so src/main/native/libfvad/src/CMakeFiles/fvad.dir/*.o src/main/native/libfvad/src/CMakeFiles/fvad.dir/**/*.o src/main/native/libfvad/src/libfvad.a src/main/native/io_github_givimad_libfvadjni_VoiceActivityDetector.o -lc $LDFLAGS

  rm -rf src/main/native/*.o
  (cd src/main/native/libfvad && git clean -d -f -x)
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
