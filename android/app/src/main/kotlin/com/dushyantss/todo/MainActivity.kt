package com.dushyantss.todo

import android.os.Bundle
import android.view.WindowManager

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity(): FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    this.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    GeneratedPluginRegistrant.registerWith(this)
  }
}
