package com.harsh.nearhood

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onResume() {
        super.onResume()
        createNotificationChannels()
    }

    /**
     * Creates the two FCM notification channels used by this app.
     *
     * Channels only need to be created once; calling this method with an
     * already-existing channel ID is a safe no-op on Android 8.0+.
     *
     * Channel IDs match what the backend sends in the FCM payload:
     *   - "posts"         → regular neighbourhood posts   (default importance)
     *   - "safety_alerts" → critical safety alerts        (high importance, heads-up)
     */
    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = getSystemService(NotificationManager::class.java) ?: return

        // ── Regular posts channel ──────────────────────────────────────────
        val postsChannel = NotificationChannel(
            "posts",
            "Neighbourhood Posts",
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = "New posts from your neighbourhood"
            enableVibration(true)
            setShowBadge(true)
        }

        // ── Safety alerts channel ──────────────────────────────────────────
        val safetyChannel = NotificationChannel(
            "safety_alerts",
            "Safety Alerts",
            NotificationManager.IMPORTANCE_HIGH,   // heads-up on lock screen
        ).apply {
            description = "Critical safety alerts for your area"
            enableVibration(true)
            enableLights(true)
            setShowBadge(true)
        }

        manager.createNotificationChannel(postsChannel)
        manager.createNotificationChannel(safetyChannel)
    }
}
