package com.example.kmt;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

import java.io.InputStream;
import java.net.ServerSocket;
import java.net.Socket;
import com.example.kmt.R;
import android.util.Log;

public class MyForegroundService extends Service {

    private static final String CHANNEL_ID = "factory_alert_channel";

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        createNotificationChannel();

        Notification notification = new Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("ระบบแจ้งเตือนโรงงาน")
                .setContentText("กำลังรอฟังคำสั่ง...")
                // .setSmallIcon(R.drawable.ic_launcher_foreground)
                .setSmallIcon(R.mipmap.ic_launcher)
                .build();

        startForeground(1, notification);

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

    private void showAlertNotification(String message) {
        createNotificationChannel();
        Notification notification = new Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("แจ้งเตือนใหม่")
                .setContentText(message)
                // .setSmallIcon(R.drawable.ic_launcher_foreground)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setAutoCancel(true)
                .build();
        Log.d("MyService", "รอรับข้อมูลที่พอร์ต 4000...");

        NotificationManager manager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        manager.notify((int) System.currentTimeMillis(), notification);
    }

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
