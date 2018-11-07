package com.ccsu.android;

import android.content.res.Configuration;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

public class MainActivity extends AppCompatActivity {

    private NBGamePlayView mGamePlayView = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mGamePlayView = this.findViewById(R.id.gameplay_view);
    }

    @Override
    protected void onPause() {
        if (mGamePlayView != null)
            mGamePlayView.onPause();
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mGamePlayView != null)
            mGamePlayView.onResume();
    }

    @Override
    protected void onDestroy() {
        if (mGamePlayView != null)
            mGamePlayView.requestExitAndWait();
        super.onDestroy();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {

        super.onConfigurationChanged(newConfig);

        if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            // 加入横屏要处理的代码
        } else if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            // 加入竖屏要处理的代码
        }
    }
}
