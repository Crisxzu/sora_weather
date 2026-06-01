package fr.dazu.kumi_weather

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        val appWidgetManager = AppWidgetManager.getInstance(context)
        val widgetIds = appWidgetManager.getAppWidgetIds(
            ComponentName(context, WeatherWidgetProvider::class.java)
        )

        if (widgetIds.isEmpty()) return

        WeatherWidgetProvider().onUpdate(context, appWidgetManager, widgetIds)
    }
}
