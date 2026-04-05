package fr.dazu.sora_weather

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetBackgroundReceiver
import es.antonborri.home_widget.HomeWidgetPlugin

class WeatherWidgetRefreshReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // 1. Afficher l'overlay de chargement immédiatement, sans attendre le Dart isolate
        HomeWidgetPlugin.getData(context)
            .edit()
            .putBoolean("widget_loading", true)
            .apply()

        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(
            ComponentName(context, WeatherWidgetProvider::class.java)
        )
        for (id in ids) {
            WeatherWidgetProvider.updateAppWidget(context, manager, id)
        }

        // 2. Déclencher le callback Dart pour le fetch des données
        val dartIntent = Intent(context, HomeWidgetBackgroundReceiver::class.java).apply {
            action = "es.antonborri.home_widget.action.BACKGROUND"
            data = Uri.parse("homeWidget://refresh")
        }
        context.sendBroadcast(dartIntent)
    }
}