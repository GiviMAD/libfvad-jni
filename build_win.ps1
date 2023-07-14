Set-PSDebug -Trace 1

cd src\main\native\libfvad
cmake . -G "MinGW Makefiles"
cmake --build .
cd ..\..\..\..\

g++ -c -std=c++11 -O3 -DNDEBUG -fPIC -I $env:JAVA_HOME\include -I $env:JAVA_HOME\include\win32 -I src\main\native\libfvad\include -I src\main\native src\main\native\io_github_givimad_libfvadjni_VoiceActivityDetector.cpp -o src\main\native\io_github_givimad_libfvadjni_VoiceActivityDetector.o

g++ -shared -static -I src\main\native\libfvad\include -I src\main\native -o src\main\resources\win-amd64\libfvadjni.dll src\main\native\libfvad\src\CMakeFiles\fvad.dir\*.c.obj src\main\native\libfvad\src\CMakeFiles\fvad.dir\vad\*.c.obj src\main\native\libfvad\src\CMakeFiles\fvad.dir\signal_processing\*.c.obj src\main\native\libfvad\src\libfvad.a src\main\native\io_github_givimad_libfvadjni_VoiceActivityDetector.o

if ($LastExitCode -ne 0) {
    Write-Error "Unable to build library"
    Exit 1
}

rm -fo src\main\native\*.o
cd src\main\native\libfvad
git clean -d -f -x
cd ..\..\..\..\
Set-PSDebug -Trace 0