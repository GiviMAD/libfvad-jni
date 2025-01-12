  cmake_minimum_required(VERSION 3.5)

project(libfvad-jni C CXX)

# ---- Set options ----

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(JAVA_AWT_LIBRARY NotNeeded)
set(JAVA_JVM_LIBRARY NotNeeded)
find_package(JNI REQUIRED)
if (JNI_FOUND)
    message (STATUS "JNI_INCLUDE_DIRS=${JNI_INCLUDE_DIRS}")
endif()

if(MSVC)
  # Force compiler to use UTF-8 for IPA constants
  add_compile_options("$<$<C_COMPILER_ID:MSVC>:/utf-8>")
  add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")
elseif(NOT APPLE)
  string(APPEND CMAKE_CXX_FLAGS " -Wall -Wextra -Wl,-rpath,'$ORIGIN'")
  string(APPEND CMAKE_C_FLAGS " -Wall -Wextra")
  set(CMAKE_INSTALL_RPATH '$ORIGIN')
elseif(APPLE)
  set(CMAKE_INSTALL_RPATH "@loader_path")
endif()

# ---- Declare libraries ----

add_library(libfvad-jni SHARED src/main/native/io_github_givimad_libfvadjni_VoiceActivityDetector.cpp)

if(NOT DEFINED LIBFVAD_DIR)
set(LIBFVAD_DIR "${CMAKE_CURRENT_BINARY_DIR}/libfvad.s")
set(LIBFVAD_INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/libfvad")
include(ExternalProject)
  ExternalProject_Add(
    libfvad-external
    PREFIX "${LIBFVAD_INSTALL_DIR}"
    URL "${CMAKE_CURRENT_LIST_DIR}/src/main/native/libfvad"
    CMAKE_ARGS -DCMAKE_INSTALL_RPATH:STRING=${CMAKE_INSTALL_RPATH} -DCMAKE_INSTALL_PREFIX:PATH=${LIBFVAD_DIR} -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES} -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=${CMAKE_OSX_DEPLOYMENT_TARGET}
  )
  add_dependencies(libfvad-jni libfvad-external)
endif()

# ---- Declare executable ----

if((NOT MSVC) AND (NOT APPLE))
  # Linux flags
  string(APPEND CMAKE_CXX_FLAGS " -Wall -Wextra -Wl,-rpath,'$ORIGIN'")
  string(APPEND CMAKE_C_FLAGS " -Wall -Wextra")
  # target_link_libraries(libfvad-jni -static-libgcc -static-libstdc++)
endif()

if(MSVC)
target_link_libraries(libfvad-jni
  fvad
)
else()
target_link_libraries(libfvad-jni
  libfvad.a
)
endif()
target_link_directories(libfvad-jni PUBLIC
  ${LIBFVAD_DIR}/lib
  ${LIBFVAD_DIR}/lib/static
)

target_include_directories(libfvad-jni PUBLIC
  ${JNI_INCLUDE_DIRS}
  src/main/native
  ${LIBFVAD_DIR}/include
)

# ---- Declare install targets ----

install(
  TARGETS libfvad-jni
  DESTINATION ${CMAKE_INSTALL_PREFIX}
)

# Dependencies

install(
  DIRECTORY ${LIBFVAD_DIR}/lib/
  DESTINATION ${CMAKE_INSTALL_PREFIX}
  USE_SOURCE_PERMISSIONS
  FILES_MATCHING
  PATTERN "*.so.*"
  PATTERN "*.so"
  PATTERN "*.dylib"
)

install(
  DIRECTORY ${LIBFVAD_DIR}/bin/
  DESTINATION ${CMAKE_INSTALL_PREFIX}
  USE_SOURCE_PERMISSIONS
  FILES_MATCHING
  PATTERN "*.dll"
)

