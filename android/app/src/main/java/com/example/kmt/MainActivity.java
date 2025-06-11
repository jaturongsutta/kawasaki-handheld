package com.example.kmt;

import android.content.Intent;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import com.example.kmt.MyForegroundService;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "factory_alert_service";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("startService")) {
                    Intent serviceIntent = new Intent(this, MyForegroundService.class);
                    startForegroundService(serviceIntent);
                    result.success("started");
                } else {
                    result.notImplemented();
                }
            });
    }
}
