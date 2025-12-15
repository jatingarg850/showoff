package com.showoff.life

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import androidx.core.view.WindowCompat
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.core.app.NotificationCompat

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge for backward compatibility with Android 15+
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // Create notification channel for Android 8.0+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel()
        }
    }
    
    private fun createNotificationChannel() {
        val channelId = "showoff_notifications"
        val channelName = "ShowOff Notifications"
        val importance = NotificationManager.IMPORTANCE_DEFAULT
        
        val channel = NotificationChannel(channelId, channelName, importance).apply {
            description = "Notifications for ShowOff.life app"
            enableVibration(true)
            setShowBadge(true)
        }
        
        // Register the channel with the system
        val notificationManager: NotificationManager =
            getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(channel)
    }
}
