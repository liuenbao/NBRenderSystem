//
// Created by liu enbao on 06/11/2018.
//

#include <jni.h>
#include <stdio.h>
#include <stdlib.h>

#include "Base.h"
#include "Platform.h"
#include "FileSystem.h"
#include "Game.h"
#include "SamplesGame.h"

#define LOG_TAG "GamePlay_JNI"
#include "Logging.h"
#include <android/asset_manager.h>
#include <android/asset_manager_jni.h>

#include <string>
#include <bitset>
#include <unistd.h>

static const char* const gClassName = "com/ccsu/android/NBGamePlayView";

typedef struct GamePlayContext {
    gameplay::Platform* platform;
    gameplay::Game* game;
} GamePlayContext;

AAssetManager* __assetManager;
static std::bitset<6> __gestureEventsProcessed;

static int __width;
static int __height;
static struct timespec __timespec;
static double __timeStart;
static double __timeAbsolute;
static bool __vsync = WINDOW_VSYNC;
static bool __multiSampling = false;
static bool __multiTouch = false;
static int __primaryTouchId = -1;
static bool __displayKeyboard = false;
static float __accelRawX;
static float __accelRawY;
static float __accelRawZ;
static float __gyroRawX;
static float __gyroRawY;
static float __gyroRawZ;

// OpenGL VAO functions.
static const char* __glExtensions;
PFNGLBINDVERTEXARRAYOESPROC glBindVertexArray = NULL;
PFNGLDELETEVERTEXARRAYSOESPROC glDeleteVertexArrays = NULL;
PFNGLGENVERTEXARRAYSOESPROC glGenVertexArrays = NULL;
PFNGLISVERTEXARRAYOESPROC glIsVertexArray = NULL;

namespace gameplay
{
    extern void print(const char* format, ...)
    {
        GP_ASSERT(format);
        va_list argptr;
        va_start(argptr, format);
        __android_log_vprint(ANDROID_LOG_INFO, "gameplay-native-activity", format, argptr);
        va_end(argptr);
    }

    static double timespec2millis(struct timespec *a)
    {
        GP_ASSERT(a);
        return (1000.0 * a->tv_sec) + (0.000001 * a->tv_nsec);
    }

    extern int strcmpnocase(const char* s1, const char* s2)
    {
        return strcasecmp(s1, s2);
    }

    Platform::Platform(Game* game)
            : _game(game)
    {
    }

    Platform::~Platform()
    {
    }

    Platform* Platform::create(Game* game)
    {
        Platform* platform = new Platform(game);
        return platform;
    }

    int Platform::enterMessagePump()
    {
        return 0;
    }

    void Platform::signalShutdown()
    {
        // nothing to do
    }

    bool Platform::canExit()
    {
        return false;
    }

    unsigned int Platform::getDisplayWidth()
    {
        return __width;
    }

    unsigned int Platform::getDisplayHeight()
    {
        return __height;
    }

    double Platform::getAbsoluteTime()
    {
        clock_gettime(CLOCK_REALTIME, &__timespec);
        double now = timespec2millis(&__timespec);
        __timeAbsolute = now - __timeStart;

        return __timeAbsolute;
    }

    void Platform::setAbsoluteTime(double time)
    {
        __timeAbsolute = time;
    }

    bool Platform::isVsync()
    {
        return __vsync;
    }

    void Platform::setVsync(bool enable)
    {
//        eglSwapInterval(__eglDisplay, enable ? 1 : 0);
        __vsync = enable;
    }


    void Platform::swapBuffers()
    {
//        if (__eglDisplay && __eglSurface)
//            eglSwapBuffers(__eglDisplay, __eglSurface);
    }

    void Platform::sleep(long ms)
    {
        usleep(ms * 1000);
    }

    void Platform::setMultiSampling(bool enabled)
    {
        if (enabled == __multiSampling)
        {
            return;
        }
        __multiSampling = enabled;
    }

    void Platform::displayKeyboard(bool display)
    {
        if (display)
            __displayKeyboard = true;
        else
            __displayKeyboard = false;
    }

        bool Platform::isMultiSampling()
    {
        return __multiSampling;
    }

    void Platform::setMultiTouch(bool enabled)
    {
        __multiTouch = enabled;
    }

    bool Platform::isMultiTouch()
    {
        return __multiTouch;
    }

    bool Platform::hasAccelerometer()
    {
        return true;
    }

    void Platform::getAccelerometerValues(float* pitch, float* roll)
    {

    }

    void Platform::shutdownInternal()
    {
        Game::getInstance()->shutdown();
    }

    bool Platform::isGestureSupported(Gesture::GestureEvent evt)
    {
        // Pinch currently not implemented
        return evt == gameplay::Gesture::GESTURE_SWIPE || evt == gameplay::Gesture::GESTURE_TAP || evt == gameplay::Gesture::GESTURE_LONG_TAP ||
               evt == gameplay::Gesture::GESTURE_DRAG || evt == gameplay::Gesture::GESTURE_DROP || evt == gameplay::Gesture::GESTURE_PINCH;
    }

    void Platform::registerGesture(Gesture::GestureEvent evt)
    {
        switch(evt)
        {
            case Gesture::GESTURE_ANY_SUPPORTED:
                __gestureEventsProcessed.set();
                break;

            case Gesture::GESTURE_TAP:
            case Gesture::GESTURE_SWIPE:
            case Gesture::GESTURE_LONG_TAP:
            case Gesture::GESTURE_DRAG:
            case Gesture::GESTURE_DROP:
            case Gesture::GESTURE_PINCH:
                __gestureEventsProcessed.set(evt);
                break;

            default:
                break;
        }
    }

    void Platform::unregisterGesture(Gesture::GestureEvent evt)
    {
        switch(evt)
        {
            case Gesture::GESTURE_ANY_SUPPORTED:
                __gestureEventsProcessed.reset();
                break;

            case Gesture::GESTURE_TAP:
            case Gesture::GESTURE_SWIPE:
            case Gesture::GESTURE_LONG_TAP:
            case Gesture::GESTURE_DRAG:
            case Gesture::GESTURE_DROP:
                __gestureEventsProcessed.set(evt, 0);
                break;

            default:
                break;
        }
    }

    bool Platform::hasMouse()
    {
        // not
        return false;
    }

    void Platform::setMouseCaptured(bool captured)
    {
        // not
    }

    bool Platform::isMouseCaptured()
    {
        // not
        return false;
    }

    void Platform::setCursorVisible(bool visible)
    {
        // not
    }

    bool Platform::isCursorVisible()
    {
        // not
        return false;
    }

    void Platform::getSensorValues(float* accelX, float* accelY, float* accelZ, float* gyroX, float* gyroY, float* gyroZ)
    {
        if (accelX)
        {
            *accelX = __accelRawX;
        }

        if (accelY)
        {
            *accelY = __accelRawY;
        }

        if (accelZ)
        {
            *accelZ = __accelRawZ;
        }

        if (gyroX)
        {
            *gyroX = __gyroRawX;
        }

        if (gyroY)
        {
            *gyroY = __gyroRawY;
        }

        if (gyroZ)
        {
            *gyroZ = __gyroRawZ;
        }
    }

    void Platform::getArguments(int* argc, char*** argv)
    {
        if (argc)
            *argc = 0;
        if (argv)
            *argv = 0;
    }

    bool Platform::isGestureRegistered(Gesture::GestureEvent evt)
    {
        return __gestureEventsProcessed.test(evt);
    }

    std::string Platform::displayFileDialog(size_t mode, const char* title, const char* filterDescription, const char* filterExtensions, const char* initialDirectory)
    {
        return "";
    }
}

JNIEXPORT jlong JNICALL nativeInit(JNIEnv* env, jobject thiz, jobject assetManager, jstring stringExternalPath) {

    __assetManager = AAssetManager_fromJava(env, assetManager);

    const char* externalPath = env->GetStringUTFChars(stringExternalPath, NULL);

    // Set the default path to store the resources.
    std::string assetsPath(externalPath);
    if (externalPath[strlen(externalPath)-1] != '/')
        assetsPath += "/";

    FileSystem::setResourcePath(assetsPath.c_str());

    env->ReleaseStringUTFChars(stringExternalPath, externalPath);

    GamePlayContext* playContext = new GamePlayContext;
    playContext->game = new SamplesGame();
    playContext->platform = gameplay::Platform::create(playContext->game);

    // Get the initial time.
    clock_gettime(CLOCK_REALTIME, &__timespec);
    __timeStart = timespec2millis(&__timespec);
    __timeAbsolute = 0L;

    return reinterpret_cast<jlong>(playContext);
}

JNIEXPORT void JNICALL nativeDeinit(JNIEnv* env, jobject thiz, jlong nativePtr) {
    GamePlayContext* gamePlayCtx = reinterpret_cast<GamePlayContext*>(nativePtr);
    if (gamePlayCtx == NULL) {
        return ;
    }

    if (gamePlayCtx->game != NULL) {
        delete gamePlayCtx->game;
        gamePlayCtx->game = NULL;
    }

    if (gamePlayCtx->platform != NULL) {
        delete gamePlayCtx->platform;
        gamePlayCtx->platform = NULL;
    }

    delete gamePlayCtx;
}

JNIEXPORT void JNICALL nativeSurfaceCreated(JNIEnv* env, jobject thiz) {
    LOGI("nativeSurfaceCreated");

    // Initialize OpenGL ES extensions.
    __glExtensions = (const char*)glGetString(GL_EXTENSIONS);

    if (strstr(__glExtensions, "GL_OES_vertex_array_object") || strstr(__glExtensions, "GL_ARB_vertex_array_object"))
    {
        // Disable VAO extension for now.
        glBindVertexArray = (PFNGLBINDVERTEXARRAYOESPROC)eglGetProcAddress("glBindVertexArrayOES");
        glDeleteVertexArrays = (PFNGLDELETEVERTEXARRAYSOESPROC)eglGetProcAddress("glDeleteVertexArraysOES");
        glGenVertexArrays = (PFNGLGENVERTEXARRAYSOESPROC)eglGetProcAddress("glGenVertexArraysOES");
        glIsVertexArray = (PFNGLISVERTEXARRAYOESPROC)eglGetProcAddress("glIsVertexArrayOES");
    }

    EGLDisplay display = eglGetCurrentDisplay();
    EGLSurface surface = eglGetCurrentSurface(EGL_DRAW);

    eglQuerySurface(display, surface, EGL_WIDTH, &__width);
    eglQuerySurface(display, surface, EGL_HEIGHT, &__height);

    Game::getInstance()->run();
}

JNIEXPORT void JNICALL nativeSurfaceChanged(JNIEnv* env, jobject thiz, jlong nativePtr, jint width, jint height) {
    LOGI("nativeSurfaceChanged width : %d height : %d", width, height);
    GamePlayContext* gamePlayCtx = reinterpret_cast<GamePlayContext*>(nativePtr);
    gamePlayCtx->game->resizeEvent(width, height);
}

JNIEXPORT void JNICALL nativeSurfaceDestroy(JNIEnv* env, jobject thiz, jlong nativePtr) {
    LOGI("nativeSurfaceDestroy");
    GamePlayContext* gamePlayCtx = reinterpret_cast<GamePlayContext*>(nativePtr);
    if (gamePlayCtx->game->canExit()) {
        gamePlayCtx->game->exit();
    }
}

JNIEXPORT void JNICALL nativeDrawFrame(JNIEnv* env, jobject thiz, jlong nativePtr) {
    GamePlayContext* gamePlayCtx = reinterpret_cast<GamePlayContext*>(nativePtr);
//    LOGI("nativeDrawFrame begin gamePlayCtx : %p", gamePlayCtx);
    if (gamePlayCtx == NULL) {
        return ;
    }

    if (gamePlayCtx->game == NULL) {
        return ;
    }

    gamePlayCtx->game->frame();
}

JNIEXPORT void JNICALL nativeOnPause(JNIEnv* env, jobject thiz, jlong nativePtr) {
    gameplay::Game::getInstance()->pause();
}

JNIEXPORT void JNICALL nativeOnResume(JNIEnv* env, jobject thiz, jlong nativePtr) {
//    if (Game::getInstance()->getState() == Game::UNINITIALIZED)
//    {
//        Game::getInstance()->run();
//    }
//    else
//    {
        Game::getInstance()->resume();
//    }
}

static JNINativeMethod gMethods[] ={
        {"nativeInit",           "(Landroid/content/res/AssetManager;Ljava/lang/String;)J", (void*)nativeInit},
        {"nativeDeinit",         "(J)V",     (void*)nativeDeinit},

        {"nativeSurfaceCreated", "(J)V",     (void*)nativeSurfaceCreated},
        {"nativeSurfaceChanged", "(JII)V",  (void*)nativeSurfaceChanged},
        {"nativeSurfaceDestroy", "(J)V",    (void*)nativeSurfaceDestroy},
        {"nativeDrawFrame",      "(J)V",    (void*)nativeDrawFrame},

        {"nativeOnPause",       "(J)V",     (void*)nativeOnPause},
        {"nativeOnResume",      "(J)V",     (void*)nativeOnResume}
};
#define METHOD_ARR_LEN(x) (sizeof(gMethods)/sizeof(gMethods[0]))

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void* reserved) {
    JNIEnv *env = NULL;

    if (vm->GetEnv((void **)&env, JNI_VERSION_1_4) != JNI_OK) {
        return JNI_ERR;
    }

    jclass clazz = env->FindClass(gClassName);
    if(env->RegisterNatives(clazz, gMethods, METHOD_ARR_LEN(gMethods)) < 0) {
        return JNI_ERR;
    }

    return JNI_VERSION_1_4;
}

JNIEXPORT void JNICALL JNI_OnUnload(JavaVM *vm, void *reserved) {
    JNIEnv *env = NULL;

    if (vm->GetEnv((void **) &env, JNI_VERSION_1_4) != JNI_OK) {
        return ;
    }

    jclass clazz = (env)->FindClass( gClassName);

    env->UnregisterNatives(clazz);
}