package fr.dazu.sora_weather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File

class WeatherWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)

            val temp = widgetData.getString("widget_temp", "--°") ?: "--°"
            val city = widgetData.getString("widget_city", "Kumi Weather") ?: "Kumi Weather"
            val condition = widgetData.getString("widget_condition", "") ?: ""
            val minTemp = widgetData.getString("widget_min_temp", "--°") ?: "--°"
            val maxTemp = widgetData.getString("widget_max_temp", "--°") ?: "--°"
            val iconPath = widgetData.getString("widget_icon_path", null)
            val isLoading = widgetData.getBoolean("widget_loading", false)

            val views = RemoteViews(context.packageName, R.layout.weather_widget)
            views.setTextViewText(R.id.widget_temp, temp)
            views.setTextViewText(R.id.widget_city, city)
            views.setTextViewText(R.id.widget_condition, condition)
            views.setTextViewText(R.id.widget_min_max, "$minTemp / $maxTemp")

            if (iconPath != null) {
                val file = File(iconPath)
                if (file.exists()) {
                    val bitmap = BitmapFactory.decodeFile(iconPath)
                    if (bitmap != null) {
                        views.setImageViewBitmap(R.id.widget_icon, bitmap)
                    }
                }
            }

            views.setViewVisibility(
                R.id.widget_loading_overlay,
                if (isLoading) View.VISIBLE else View.GONE
            )

            val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0
            val refreshIntent = PendingIntent.getBroadcast(
                context,
                0,
                Intent(context, WeatherWidgetRefreshReceiver::class.java).apply {
                    data = Uri.parse("homeWidget://refresh")
                },
                flags
            )
            views.setOnClickPendingIntent(R.id.widget_refresh_btn, refreshIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
