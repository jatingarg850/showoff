package com.showofflife.app

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.app.PictureInPictureParams
import android.util.Rational
import androidx.core.view.WindowCompat

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge for backward compatibility with Android 15+
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
    
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        
        // Enable picture-in-picture mode when user leaves the app
        // This is called when user presses home or switches apps
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            try {
                val params = PictureInPictureParams.Builder()
                    .setAspectRatio(Rational(16, 9))  // Standard video aspect ratio
                    .build()
                enterPictureInPictureMode(params)
            } catch (e: Exception) {
                // Silently fail if PiP is not supported
            }
        }
    }
}
