package com.example.belajar_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "kiosk_mode"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                // 🔒 MODE SISWA
                "startKiosk" -> {
                    startLockTask()
                    result.success(null)
                }

                // 🔓 MODE GURU
                "stopKiosk" -> {
                    stopLockTask()
                    result.success(null)
                }

                // ❌ SELESAI UJIAN
                "exitApp" -> {
                    stopLockTask()
                    finishAffinity()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }
}
