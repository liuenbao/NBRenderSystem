package com.ccsu.android;

import android.content.Context;
import android.content.res.AssetManager;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.util.Log;

import com.ccsu.android.view.NBEnhancedGLView;

import java.io.File;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class NBGamePlayView extends NBEnhancedGLView implements NBEnhancedGLView.Renderer {

    private static final String TAG = NBGamePlayView.class.getSimpleName();

    static {
        System.loadLibrary("GamePlay_JNI");
    }

    private long mNativePtr = -1;
    private Context mContext = null;

    public NBGamePlayView(Context context) {
        super(context);
        init(context);
    }

    public NBGamePlayView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    private void init(Context context) {
        mContext = context;

        File externFileDir = context.getExternalFilesDir(null);

        Log.i(TAG, "nativeInit begin path is : " + externFileDir.getPath());
        mNativePtr = nativeInit(context.getAssets(), externFileDir.getPath());
        Log.i(TAG, "nativeInit end");

        super.setEGLContextClientVersion(2);

        super.setRenderer(this);
    }

    @Override
    public void onPause() {
        Log.i(TAG, "onPause begin");

        super.queueEvent(new Runnable() {
            @Override
            public void run() {
                if (mNativePtr != -1)
                    nativeOnPause(mNativePtr);
            }
        });

        super.onPause();
        Log.i(TAG, "onPause end");
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.i(TAG, "nativeOnResume begin");

        super.queueEvent(new Runnable() {
            @Override
            public void run() {
                if (mNativePtr != -1)
                    nativeOnResume(mNativePtr);
            }
        });

        Log.i(TAG, "nativeOnResume end");
    }

    @Override
    public void onSurfaceCreated(GL10 gl, EGLConfig config) {
        Log.i(TAG, "nativeSurfaceCreated begin");
        nativeSurfaceCreated(mNativePtr);
        Log.i(TAG, "nativeSurfaceCreated end");
    }

    @Override
    public void onSurfaceChanged(GL10 gl, int width, int height) {
        Log.i(TAG, "nativeSurfaceChanged begin with : " + width + " height : " + height);
        nativeSurfaceChanged(mNativePtr, width, height);
        Log.i(TAG, "nativeSurfaceChanged end");
    }

    @Override
    public void onDrawFrame(GL10 gl) {
        nativeDrawFrame(mNativePtr);
    }

    @Override
    public void onSurfaceDestroy() {
        Log.i(TAG, "nativeSurfaceDestroy begin");

        nativeSurfaceDestroy(mNativePtr);

        // deinit the native context
        nativeDeinit(mNativePtr);

        Log.i(TAG, "nativeSurfaceDestroy end");
    }

    private native long nativeInit(AssetManager assetManager, String resourcePath);
    private native void nativeDeinit(long nativePtr);

    private native void nativeSurfaceCreated(long nativePtr);
    private native void nativeSurfaceChanged(long nativePtr, int width, int height);
    private native void nativeSurfaceDestroy(long nativePtr);
    private native void nativeDrawFrame(long nativePtr);

    private native void nativeOnPause(long nativePtr);
    private native void nativeOnResume(long nativePtr);

}
