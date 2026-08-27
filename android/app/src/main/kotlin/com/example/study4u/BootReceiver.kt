package com.example.study4u

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Handles BOOT_COMPLETED to ensure alarms are rescheduled.
 * The actual rescheduling is done by Flutter on next app launch via
 * NotificationService.rescheduleAllCourses(). This receiver just ensures
 * the app is aware of boot and could trigger a background reschedule
 * if needed in future (e.g. via WorkManager).
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            // No-op for now – Flutter will reschedule on next launch.
            // This keeps the receiver declared so alarms are not considered
            // orphaned and the app can be started after reboot.
        }
    }
}
