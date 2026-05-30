package com.saba.fitness;

import android.content.res.Configuration;
import android.os.Bundle;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        newConfig.fontScale = 1.0f;
        super.onConfigurationChanged(newConfig);
    }

    @Override
    protected void attachBaseContext(android.content.Context newBase) {
        android.content.res.Configuration config = new android.content.res.Configuration();
        config.fontScale = 1.0f;
        android.content.Context context = newBase.createConfigurationContext(config);
        super.attachBaseContext(context);
    }
}
