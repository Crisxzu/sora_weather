package fr.dazu.sora_weather

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import kotlin.concurrent.thread

class WeatherWidgetRefreshReceiver : BroadcastReceiver() {
    companion object {
        // Extra optionnel : index de la position à sélectionner dans widget_locations.
        // Absent (= -1) → simple refresh de la position active courante.
        const val EXTRA_TARGET_INDEX = "target_index"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val widgetData = HomeWidgetPlugin.getData(context)

        // Show loading overlay immediately
        widgetData.edit().putBoolean("widget_loading", true).apply()
        updateWidget(context)

        val apiLink = widgetData.getString("widget_api_link", null)
        val apiKey = widgetData.getString("widget_api_key", null)
        if (apiLink == null || apiKey == null) {
            widgetData.edit().putBoolean("widget_loading", false).apply()
            updateWidget(context)
            return
        }

        // Si un targetIndex est fourni, on bascule sur cette position (cycle) : on
        // met à jour l'index actif et on dérive la query depuis widget_locations.
        // Sinon on refresh la position courante via les clés city_query/last_position.
        var cityQuery = widgetData.getString("widget_city_query", null)
        var countryCode = widgetData.getString("widget_active_country", null)
        val position = widgetData.getString("widget_last_position", null)

        val targetIndex = intent.getIntExtra(EXTRA_TARGET_INDEX, -1)
        if (targetIndex >= 0) {
            val loc = resolveLocation(widgetData.getString("widget_locations", null), targetIndex)
            if (loc != null) {
                widgetData.edit().putInt("widget_active_index", targetIndex).apply()
                val isGps = loc.optString("type") == "gps"
                if (isGps) {
                    cityQuery = null
                    countryCode = null
                } else {
                    cityQuery = loc.optString("city").ifEmpty { null }
                    countryCode = loc.optString("country").ifEmpty { null }
                }
                // Persiste la query active pour les refresh simples suivants.
                widgetData.edit()
                    .putString("widget_city_query", cityQuery)
                    .putString("widget_active_country", countryCode)
                    .apply()
            }
        }

        val langIso = widgetData.getString("widget_lang_iso", "en") ?: "en"
        val unitName = widgetData.getString("widget_unit_name", "celsius") ?: "celsius"

        // Garde le process en vie pendant le fetch réseau : sans goAsync(), onReceive
        // rend la main immédiatement et le système peut tuer le process (widget lancé
        // app fermée) avant la fin du thread → overlay loading bloqué.
        val pendingResult = goAsync()

        thread {
            try {
                val trimmed = apiLink.trimEnd('/')
                val params = StringBuilder("lang_iso=${enc(langIso)}")
                if (!cityQuery.isNullOrEmpty()) {
                    params.append("&city=${enc(cityQuery)}")
                    if (!countryCode.isNullOrEmpty()) {
                        params.append("&country_code=${enc(countryCode)}")
                    }
                } else if (!position.isNullOrEmpty()) {
                    params.append("&position=${enc(position)}")
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
                    pendingResult.finish()
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
                // L'API renvoie is_day comme booléen (true/false) ; on tolère aussi
                // un entier 1/0 par sécurité.
                val isDay = when (val v = current.get("is_day")) {
                    is Boolean -> v
                    is Number -> v.toInt() == 1
                    else -> true
                }
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
            } finally {
                pendingResult.finish()
            }
        }
    }

    // Résout l'entrée `index` dans le JSON widget_locations. Renvoie null si l'index
    // est hors bornes ou si le JSON est absent/malformé.
    private fun resolveLocation(locationsJson: String?, index: Int): JSONObject? {
        if (locationsJson.isNullOrEmpty()) return null
        return try {
            val arr = JSONArray(locationsJson)
            if (index < 0 || index >= arr.length()) null else arr.getJSONObject(index)
        } catch (e: Exception) {
            null
        }
    }

    private fun enc(value: String): String = URLEncoder.encode(value, "UTF-8")

    private fun updateWidget(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, WeatherWidgetProvider::class.java))
        for (id in ids) {
            WeatherWidgetProvider.updateAppWidget(context, manager, id)
        }
    }
}
