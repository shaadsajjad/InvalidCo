package com.example.invalidco

import android.content.Context
import android.net.Uri
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = "flutter_channel"

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getImages" -> {
                        val images = getAllImages(this)
                        result.success(images)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getAllImages(context: Context): List<String> {
        val list: MutableList<String> = mutableListOf()

        val projection = arrayOf(MediaStore.Images.Media.DATA) // file path
        val cursor = context.contentResolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            projection,
            null,
            null,
            "${MediaStore.Images.Media.DATE_ADDED} DESC"
        )

        cursor?.use {
            val columnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
            while (it.moveToNext()) {
                val path = it.getString(columnIndex)
                list.add(path)
            }
        }

        return list
    }

}
