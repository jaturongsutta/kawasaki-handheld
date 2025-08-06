package com.example.kmt;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import android.app.PendingIntent;

import com.example.kmt.R;

import org.json.JSONObject;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.URL;
import java.util.Collections;
import java.util.Enumeration;

public class MyForegroundService extends Service {

    private static final String CHANNEL_ID = "factory_alert_channel";

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        createNotificationChannel();

        Notification notification = new Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("ระบบแจ้งเตือนโรงงาน")
                .setContentText("กำลังรอฟังคำสั่ง...")
                .setSmallIcon(R.mipmap.ic_launcher)
                .build();

        startForeground(1, notification);

        // ✅ Register device with backend
        registerWithServer();

        new Thread(() -> {
            try {
                ServerSocket serverSocket = new ServerSocket(4000); // TCP Port
                while (true) {
                    Socket socket = serverSocket.accept();
                    InputStream in = socket.getInputStream();
                    byte[] buffer = new byte[1024];
                    int read = in.read(buffer);
                    if (read > 0) {
                        String message = new String(buffer, 0, read);
                        Log.d("MyService", "รับข้อความ: " + message);
                        showAlertNotification(message);
                    }
                    socket.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();

        return START_STICKY;
    }

    private void registerWithServer() {
        new Thread(() -> {
            try {
                String ip = getLocalIpAddress();
                if (ip == null) {
                    Log.e("MyService", "ไม่พบ IP ของอุปกรณ์");
                    return;
                }
    
                //  ใช้ UUID แทน Build.SERIAL (เพราะ Android 10+ ไม่อนุญาต)
                String deviceId = android.provider.Settings.Secure.getString(
                        getContentResolver(), android.provider.Settings.Secure.ANDROID_ID);
    
                URL url = new URL("http://192.168.1.10:84/api/alert/register-device");
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
                conn.setDoOutput(true);
                conn.setDoInput(true);
    
                JSONObject json = new JSONObject();
                json.put("deviceId", deviceId); 
                json.put("ip", ip);
                json.put("port", 4000);
                json.put("lineCD", MainActivity.lineCd);
                json.put("username", MainActivity.username);
                
                OutputStream os = conn.getOutputStream();
                os.write(json.toString().getBytes("UTF-8"));
                os.flush();
                os.close();
    
                int responseCode = conn.getResponseCode();
                if (responseCode == HttpURLConnection.HTTP_OK || responseCode == HttpURLConnection.HTTP_CREATED) {
                    Log.d("MyService", "✅ ส่ง IP สำเร็จ: " + responseCode);
                } else {
                    Log.e("MyService", "❌ ส่ง IP ไม่สำเร็จ: " + responseCode);
                }
    
            } catch (Exception e) {
                Log.e("MyService", "❌ ส่ง IP ไม่สำเร็จ (Exception)", e);
            }
        }).start();
    }
    

    private String getLocalIpAddress() {
        try {
            for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements(); ) {
                NetworkInterface intf = en.nextElement();
                for (InetAddress addr : Collections.list(intf.getInetAddresses())) {
                    if (!addr.isLoopbackAddress() && addr instanceof java.net.Inet4Address) {
                        return addr.getHostAddress();
                    }
                }
            }
        } catch (Exception ex) {
            Log.e("MyService", "IP ERROR", ex);
        }
        return null;
    }

    private void showAlertNotification(String message) {
        createNotificationChannel();
    
        // ✅ Intent ไปยัง MainActivity
        Intent intent = new Intent(this, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        intent.putExtra("navigateTo", "notification");
    
        // ✅ PendingIntent
        PendingIntent pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
    
        // ✅ สร้าง Notification พร้อม action
        Notification notification = new Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("แจ้งเตือนใหม่")
                .setContentText(message)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent) // 🔑 ตรงนี้!
                .setAutoCancel(true)
                .build();
    
        NotificationManager manager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        manager.notify((int) System.currentTimeMillis(), notification);
    }
    

    // private void showAlertNotification(String message) {
    //     createNotificationChannel();
    //     Notification notification = new Notification.Builder(this, CHANNEL_ID)
    //             .setContentTitle("แจ้งเตือนใหม่")
    //             .setContentText(message)
    //             .setSmallIcon(R.mipmap.ic_launcher)
    //             .setAutoCancel(true)
    //             .build();
    //     Log.d("MyService", "รอรับข้อมูลที่พอร์ต 4000...");

    //     NotificationManager manager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
    //     manager.notify((int) System.currentTimeMillis(), notification);
    // }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Factory Alert Channel",
                    NotificationManager.IMPORTANCE_HIGH
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(serviceChannel);
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
