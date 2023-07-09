#include <iostream>
#include "io_github_givimad_libfvadjni_VoiceActivityDetector.h"
#include <map>
#include "fvad.h"

std::map<int, Fvad *> instMap;

JNIEXPORT jint JNICALL Java_io_github_givimad_libfvadjni_VoiceActivityDetector_fvadNew(JNIEnv *env, jclass thisClass)
{
  int ref = rand();
  instMap.insert({ref, fvad_new()});
  return ref;
}

JNIEXPORT void JNICALL Java_io_github_givimad_libfvadjni_VoiceActivityDetector_fvadReset(JNIEnv *env, jobject thisObject, jint instRef)
{
  fvad_reset(instMap.at(instRef));
}

JNIEXPORT jint JNICALL Java_io_github_givimad_libfvadjni_VoiceActivityDetector_fvadSetMode(JNIEnv *env, jobject thisObject, jint instRef, jint mode)
{
  return fvad_set_mode(instMap.at(instRef), mode);
}

JNIEXPORT jint JNICALL Java_io_github_givimad_libfvadjni_VoiceActivityDetector_fvadSetSampleRate(JNIEnv *env, jobject thisObject, jint instRef, jint sampleRate)
{
  return fvad_set_sample_rate(instMap.at(instRef), sampleRate);
}
JNIEXPORT jint JNICALL Java_io_github_givimad_libfvadjni_VoiceActivityDetector_fvadProcess(JNIEnv *env, jobject thisObject, jint instRef, jshortArray frame, jint length)
{
  const int16_t *framePointer = env->GetShortArrayElements(frame, NULL);
  return fvad_process(instMap.at(instRef), framePointer, length);
}
JNIEXPORT void JNICALL Java_io_github_givimad_libfvadjni_VoiceActivityDetector_fvadFree(JNIEnv *env, jobject thisObject, jint instRef)
{
  fvad_free(instMap.at(instRef));
  instMap.erase(instRef);
}
