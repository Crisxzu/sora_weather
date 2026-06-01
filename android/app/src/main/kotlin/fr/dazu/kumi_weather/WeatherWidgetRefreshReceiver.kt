package fr.dazu.kumi_weather

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import kotlin.concurrent.thread

class WeatherWidgetRefreshReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val widgetData = HomeWidgetPlugin.getData(context)

        // Show loading overlay immediately
        widgetData.edit().putBoolean("widget_loading", true).apply()
        updateWidget(context)

        val apiLink = widgetData.getString("widget_api_link", null) ?: return
        val apiKey = widgetData.getString("widget_api_key", null) ?: return
        val cityQuery = widgetData.getString("widget_city_query", null)
        val position = widgetData.getString("widget_last_position", null)
        val langIso = widgetData.getString("widget_lang_iso", "en") ?: "en"
        val unitName = widgetData.getString("widget_unit_name", "celsius") ?: "celsius"

        thread {
            try {
                val trimmed = apiLink.trimEnd('/')
                val params = StringBuilder("lang_iso=$langIso")
                if (!cityQuery.isNullOrEmpty()) {
                    params.append("&city=${cityQuery}")
                } else if (!position.isNullOrEmpty()) {
                    params.append("&position=${position}")
                }

                val url = URL("$trimmed/weather?$params")
                val conn = url.openConnection() as HttpURLConnection
                conn.setRequestProperty("Authorization", "Api-Key $apiKey")
                conn.connectTimeout = 10_000
                conn.readTimeout = 10_000

                if (conn.responseCode != 200) {
                    Log.e("WidgetRefresh", "API error: ${conn.responseCode}")
                    widgetData.edit().putBoolean("widget_loading", false).apply()
                    updateWidget(context)
                    return@thread
                }

                val body = conn.inputStream.bufferedReader().readText()
                val json = JSONObject(body)
                val current = json.getJSONObject("current")
                val location = json.getJSONObject("location")
                val condition = current.getJSONObject("condition")
                val isFahrenheit = unitName == "fahrenheit"

                fun formatTemp(value: Double): String {
                    val converted = if (isFahrenheit) value * 9 / 5 + 32 else value
                    return "${converted.toInt()}°"
                }

                val temp = formatTemp(current.getDouble("temp"))
                val minTemp = formatTemp(current.getDouble("min_temp"))
                val maxTemp = formatTemp(current.getDouble("max_temp"))
                val cityName = location.getString("name")
                val conditionText = condition.getString("text")
                val iconCode = condition.getInt("code")
                val isDay = current.getInt("is_day") == 1
                val dayStr = if (isDay) "day" else "night"
                val baseIconUrl = widgetData.getString("widget_base_icon_url", "") ?: ""
                val iconUrl = "$baseIconUrl/$dayStr/$iconCode.png"

                widgetData.edit()
                    .putString("widget_temp", temp)
                    .putString("widget_city", cityName)
                    .putString("widget_condition", conditionText)
                    .putString("widget_min_temp", minTemp)
                    .putString("widget_max_temp", maxTemp)
                    .putString("widget_icon_url", iconUrl)
                    .putBoolean("widget_loading", false)
                    .apply()

                updateWidget(context)
            } catch (e: Exception) {
                Log.e("WidgetRefresh", "Error refreshing widget: $e")
                widgetData.edit().putBoolean("widget_loading", false).apply()
                updateWidget(context)
            }
        }
    }

    private fun updateWidget(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, WeatherWidgetProvider::class.java))
        for (id in ids) {
            WeatherWidgetProvider.updateAppWidget(context, manager, id)
        }
    }
}
