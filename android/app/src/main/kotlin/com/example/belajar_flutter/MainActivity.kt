package com.example.belajar_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "kiosk_mode"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startKiosk" -> {
                    startLockTask()
                    result.success(null)
                }
                "stopKiosk" -> {
                    stopLockTask()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
