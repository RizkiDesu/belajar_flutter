package com.example.belajar_flutter

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "kiosk_mode"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 🔒 LOCK SCREENSHOT
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
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
                "exitApp" -> {
                    stopLockTask()
                    finishAffinity()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // Optional: auto lock setiap app dibuka
    // override fun onResume() {
    //     super.onResume()
    //     startLockTask()
    // }
}
