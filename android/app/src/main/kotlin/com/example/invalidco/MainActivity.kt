package com.example.invalidco

import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "flutter_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getImages" -> {
                        val images = getAllImages(this)
                        Log.d("MainActivity", "Found ${images.size} images")
                        result.success(images)
                    }
                    "saveImage" -> {
                        val path = call.argument<String>("path")
                        if (path != null) {
                            try {
                                saveToDownloads(this, path)
                                result.success("Saved successfully")
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

        val projection = arrayOf(MediaStore.Images.Media.DATA) // absolute file path
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
                if (path != null) {
                    list.add(path) // <-- this will be like /storage/emulated/0/DCIM/...
                }
            }
        }

        return list
    }


    private fun saveToDownloads(context: Context, imagePath: String) {
        val srcFile = File(Uri.parse(imagePath).path ?: throw Exception("Invalid URI"))

        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, srcFile.name)
            put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
            put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
        }

        val resolver = context.contentResolver
        val uri: Uri? =
            resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)

        uri?.let {
            resolver.openOutputStream(it).use { outputStream ->
                FileInputStream(srcFile).use { inputStream ->
                    inputStream.copyTo(outputStream as OutputStream)
                }
            }
        } ?: throw Exception("Failed to create file in Downloads")
    }
}
