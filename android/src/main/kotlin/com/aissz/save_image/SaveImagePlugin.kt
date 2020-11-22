package com.aissz.save_image

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File
import java.io.FileOutputStream
import java.io.IOException


public class SaveImagePlugin: FlutterPlugin, MethodCallHandler {
  private var applicationContext: Context? = null
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = flutterPluginBinding.applicationContext
    val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "aissz.com/save_image")
    channel.setMethodCallHandler(SaveImagePlugin())
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "aissz.com/save_image")
      channel.setMethodCallHandler(SaveImagePlugin())
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "saveAssetToGallery" -> {
        val filePath = call.argument<ByteArray>("path") as String
        val videoMark = call.argument<ByteArray>("videoMark") as Boolean
        result.success(saveAsset(filePath, videoMark))
      }
      else -> result.notImplemented()
    }
  }

  private fun String.generateFile(): File {
    val storePath =  Environment.getExternalStorageDirectory().absolutePath + File.separator + getApplicationName()
    val appDir = File(storePath)
    if (!appDir.exists()) {
      appDir.mkdir()
    }
    var fileName = System.currentTimeMillis().toString()
    if (isNotEmpty()) {
      fileName += (".${this}")
    }
    return File(appDir, fileName)
  }

  private fun saveAsset(filePath: String, videoMark: Boolean): Boolean {
    try {
      //val context = applicationContext
      //val file = "png".generateFile()
      //val fos = FileOutputStream(file)
      //fos.flush()
      //fos.close()
      //val uri = Uri.fromFile(file)
      val storePath =  Environment.getExternalStorageDirectory().absolutePath + File.separator + Environment.DIRECTORY_DCIM
      val extension = filePath.substringAfterLast('.')
      val filename = "$storePath/${System.currentTimeMillis()}.$extension"
      print("filename: $filename")
      File(filePath).copyTo(File(filename))
      // MediaStore.Images.Media.insertImage(context?.contentResolver, bmp, "", "")
      // context?.sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri))
      return true
    } catch (e: IOException) {
      e.printStackTrace()
    }
    return false
  }

  private fun getApplicationName(): String {
    return try {
      var info: ApplicationInfo? = null
      info = applicationContext?.packageManager?.getApplicationInfo(applicationContext?.packageName, 0)
      val appName: String
      appName = if (info != null) {
        val charSequence = applicationContext?.packageManager?.getApplicationLabel(info)
        StringBuilder(charSequence!!.length).append(charSequence).toString()
      } else {
        ""
      }
      appName
    } catch (e: PackageManager.NameNotFoundException) {
      ""
    }
  }

}