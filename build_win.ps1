Set-PSDebug -Trace 1
cmake -B build -DCMAKE_INSTALL_PREFIX=src/main/resources/win-amd64
cmake --build build --config Release
cmake --install build
rm -r -fo build