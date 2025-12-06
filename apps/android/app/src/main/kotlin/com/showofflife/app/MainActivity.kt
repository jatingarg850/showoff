package com.showofflife.app

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import androidx.core.view.WindowCompat

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge for backward compatibility with Android 15+
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}
