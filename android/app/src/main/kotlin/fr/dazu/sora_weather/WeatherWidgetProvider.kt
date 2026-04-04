package fr.dazu.sora_weather

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
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
            val city = widgetData.getString("widget_city", "Sora Weather") ?: "Sora Weather"
            val condition = widgetData.getString("widget_condition", "") ?: ""
            val minTemp = widgetData.getString("widget_min_temp", "--°") ?: "--°"
            val maxTemp = widgetData.getString("widget_max_temp", "--°") ?: "--°"
            val iconPath = widgetData.getString("widget_icon_path", null)

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

            val refreshIntent = HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("homeWidget://refresh")
            )
            views.setOnClickPendingIntent(R.id.widget_refresh_btn, refreshIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
