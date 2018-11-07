package com.ccsu.android.view;

import android.util.Log;

import javax.microedition.khronos.egl.EGL10;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.egl.EGLContext;
import javax.microedition.khronos.egl.EGLDisplay;

class DefaultContextFactory implements EGLContextFactory {
    private int EGL_CONTEXT_CLIENT_VERSION = 0x3098;

    public EGLContext createContext(EGL10 egl, EGLDisplay display, EGLConfig config, int clientVersion) {
        int[] attrib_list = {EGL_CONTEXT_CLIENT_VERSION, clientVersion,
                EGL10.EGL_NONE };

        return egl.eglCreateContext(display, config, EGL10.EGL_NO_CONTEXT,
                clientVersion != 0 ? attrib_list : null);
    }

    public EGLContext createSharedContext(EGL10 egl, EGLContext sharedContext, EGLDisplay display, EGLConfig config, int clientVersion) {
        int[] attrib_list = {EGL_CONTEXT_CLIENT_VERSION, clientVersion,
                EGL10.EGL_NONE };

        return egl.eglCreateContext(display, config, sharedContext,
                clientVersion != 0 ? attrib_list : null);
    }

    public void destroyContext(EGL10 egl, EGLDisplay display,
                               EGLContext context) {
        if (!egl.eglDestroyContext(display, context)) {
            Log.e("DefaultContextFactory", "display:" + display + " context: " + context);
            if (NBEnhancedGLView.LOG_THREADS) {
                Log.i("DefaultContextFactory", "tid=" + Thread.currentThread().getId());
            }
            EglHelper.throwEglException("eglDestroyContex", egl.eglGetError());
        }
    }
}