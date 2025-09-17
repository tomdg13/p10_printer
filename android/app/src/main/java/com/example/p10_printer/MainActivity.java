package com.example.p10_printer;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import com.example.p10_printer.Printer;

public class MainActivity extends FlutterActivity {
    private static final String TAG = MainActivity.class.getSimpleName();
    private static final String CHANNEL = "com.example/printerState";
    private static final String PRINTER_STATE_CHANNEL = "com.example/printerStateStream";

    @Override
    public  void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("onPrint")) {
                                Printer.printerTest(MainActivity.this);
                            }
                        });
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), PRINTER_STATE_CHANNEL)
                .setStreamHandler(new EventChannel.StreamHandler() {
                    private Handler mainHandler = new Handler(Looper.getMainLooper());
                    private boolean isRunning = false;

                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        isRunning = true;

                        // Simulating printer state changes
                        new Thread(() -> {
                            try {
                                String[] printerStates = {"Idle", "Printing", "Error", "Out of Paper"};
                                int index = 0;

                                while (isRunning) {
                                    Thread.sleep(2000); // Simulate delay between state changes
                                    String state = printerStates[index];
                                    mainHandler.post(() -> events.success(state)); // Send state to Flutter

                                    index = (index + 1) % printerStates.length; // Loop through states
                                }
                            } catch (InterruptedException e) {
                                mainHandler.post(() -> events.error("ERROR", "Interrupted", null));
                            }
                        }).start();
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        isRunning = false;
                    }
                });
    }
}
