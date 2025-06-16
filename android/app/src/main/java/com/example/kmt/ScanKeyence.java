package com.example.kmt;

import android.content.Context;
import com.keyence.autoid.sdk.scan.DecodeResult;
import com.keyence.autoid.sdk.scan.ScanManager;
import io.flutter.plugin.common.EventChannel;

public class ScanKeyence implements EventChannel.StreamHandler, ScanManager.DataListener {

    private EventChannel.EventSink sensorEventSink = null;
    private ScanManager mScanManager;
    private boolean isDataListenerAdded = false;

    public void initialize(Context context) {
        mScanManager = ScanManager.createScanManager(context);

        if (!isDataListenerAdded) {
            mScanManager.addDataListener(this);
            isDataListenerAdded = true;
        }
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        sensorEventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        sensorEventSink = null;
    }

    @Override
    public void onDataReceived(DecodeResult decodeResult) {
        String data = decodeResult.getData();  // แก้ตรงนี้
        if (sensorEventSink != null) {
            sensorEventSink.success(data);
        }
    }

    public void dispose() {
        if (mScanManager != null && isDataListenerAdded) {
            mScanManager.removeDataListener(this);
            mScanManager.releaseScanManager();
            isDataListenerAdded = false;
        }
    }
}
