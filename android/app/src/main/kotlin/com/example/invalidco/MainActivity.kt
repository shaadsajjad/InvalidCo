package com.example.invalidco

import android.content.Context
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getImages" -> {
                        val images = getAllImages(this)
                        result.success(images)
                    }
                    "saveImage" -> {
                        val path = call.argument<String>("path")
                        if (path != null) {
                            try {
                                val srcFile = File(path)
                                val downloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                                val destFile = File(downloads, srcFile.name)

                                FileInputStream(srcFile).use { input ->
                                    FileOutputStream(destFile).use { output ->
                                        input.copyTo(output)
                                    }
                                }

                                result.success("Saved: ${destFile.absolutePath}")
                            } catch (e: Exception) {
                                result.error("SAVE_FAILED", e.message, null)
                            }
                        } else {
                            result.error("INVALID_PATH", "Path is null", null)
                        }
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
