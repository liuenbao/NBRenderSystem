package com.ccsu.android.view;

/**
 * This class will choose a RGB_888 surface with
 * or without a depth buffer.
 *
 */
class SimpleEGLConfigChooser extends ComponentSizeChooser {
    public SimpleEGLConfigChooser(boolean withDepthBuffer, int clientVersion) {
        super(8, 8, 8, 0, withDepthBuffer ? 16 : 0, 0, clientVersion);
    }
}