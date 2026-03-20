package com.example.kmt;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

import com.example.kmt.MyForegroundService;
import com.example.kmt.ScanKeyence;

public class MainActivity extends FlutterActivity {
    private static final String startAlertCHANNEL = "factory_alert_service";
    private static final String alertCHANNEL = "factory_alert_channel";
    private static final String KEYENCE_CHANNEL = "KeyenceChannel";
    private static final String SENSOR_READER_CHANNEL = "SensorReader";
    private static final String ENTER_KEY_CHANNEL = "EnterkeyChannel";
    private static final String NAV_CHANNEL = "navigate_channel";
    private ScanKeyence scanKeyence; 
    private MethodChannel enterKeyChannel;
    public static String lineCd = "";
    public static String username = "";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        scanKeyence = new ScanKeyence();  // สร้าง object
        new MethodChannel(flutterEngine.getDartExecutor(), startAlertCHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("startService")) {
                    Intent serviceIntent = new Intent(this, MyForegroundService.class);
                    startForegroundService(serviceIntent);
                    result.success("started");
                } else {
                    result.notImplemented();
                }
            });

        new MethodChannel(flutterEngine.getDartExecutor(), alertCHANNEL)
        .setMethodCallHandler(
            (call, result) -> {
                if (call.method.equals("setLineCD")) {
                    String lineCdValue = call.argument("lineCd");
                    String usernameValue = call.argument("username"); 
                    username = usernameValue;
                    lineCd = lineCdValue;
                    result.success("LineCD set to: " + lineCd + ", Username: " + username);
                } else if (call.method.equals("getIntentExtra")) {
                    Intent currentIntent = getIntent(); // หลัง setIntent()
                    String route = currentIntent.getStringExtra("navigateTo");
                    Log.d("MainActivity", "📨 Flutter เรียก getIntentExtra => " + route);
                    result.success(route);
                } else {
                    result.notImplemented();
                }
            });

          
        


       // สำหรับ Keyence Scanner
       new MethodChannel(flutterEngine.getDartExecutor(), KEYENCE_CHANNEL)
       .setMethodCallHandler((call, result) -> {
           if (call.method.equals("initializeSensor")) {
               scanKeyence.initialize(getApplicationContext());
               result.success(true);
           } else if (call.method.equals("stopSensor")) {
            scanKeyence.stopListening();
            result.success(true);
           } else {
               result.notImplemented();
           }
       });

        // EventChannel สำหรับส่งข้อมูล barcode ไป Flutter
        new EventChannel(flutterEngine.getDartExecutor(), SENSOR_READER_CHANNEL)
            .setStreamHandler(scanKeyence);

        // สำหรับ key event
        enterKeyChannel = new MethodChannel(flutterEngine.getDartExecutor(), ENTER_KEY_CHANNEL);

    }
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        handleIntent(getIntent()); // ✅ ดัก intent ตอนเปิดแอปครั้งแรก
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (scanKeyence != null) {
            scanKeyence.dispose();
        }
    }

    // @Override
    // protected void onNewIntent(Intent intent) {
    //     super.onNewIntent(intent);
    //     setIntent(intent); // 👈 สำคัญมาก
    //     Log.d("MainActivity", "🔥 onNewIntent เรียกแล้ว: " + intent.getStringExtra("navigateTo"));
    // }
    
    private void handleIntent(Intent intent) {
        if (intent != null && "notification".equals(intent.getStringExtra("navigateTo"))) {
            new MethodChannel(getFlutterEngine().getDartExecutor(), NAV_CHANNEL)
                .invokeMethod("goToNotification", null);
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        handleIntent(intent); // ✅ ดัก intent ตอนแอปเปิดอยู่แล้ว
    }


    @Override
    protected void onResume() {
        super.onResume();
        Intent intent = getIntent();
        // ทำอะไรบางอย่างถ้าต้องการ (optional)
    }
}
