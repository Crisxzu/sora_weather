package fr.dazu.sora_weather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Looper
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import java.io.File
import java.net.HttpURLConnection
import java.net.URL
import java.security.MessageDigest

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
            val iconUrl = widgetData.getString("widget_icon_url", null)
            val iconPath = widgetData.getString("widget_icon_path", null)
            val isLoading = widgetData.getBoolean("widget_loading", false)

            // État "vide" : l'app n'a jamais écrit les credentials → aucune donnée
            // exploitable. On invite à ouvrir l'app plutôt que d'afficher des "--°".
            val hasData = !widgetData.getString("widget_api_link", null).isNullOrEmpty()

            val views = RemoteViews(context.packageName, R.layout.weather_widget)

            if (!hasData) {
                views.setViewVisibility(R.id.widget_empty_overlay, View.VISIBLE)
                // Un tap n'importe où ouvre l'app.
                views.setOnClickPendingIntent(R.id.widget_empty_overlay, launchAppPendingIntent(context))
                appWidgetManager.updateAppWidget(appWidgetId, views)
                return
            }
            views.setViewVisibility(R.id.widget_empty_overlay, View.GONE)
            views.setTextViewText(R.id.widget_temp, temp)
            views.setTextViewText(R.id.widget_city, city)
            views.setTextViewText(R.id.widget_condition, condition)
            views.setTextViewText(R.id.widget_min_max, "$minTemp / $maxTemp")

            // Icône : priorité à widget_icon_url (écrit par le refresh natif et par
            // saveWidgetData) via un cache local. Fallback sur widget_icon_path (chemin
            // du fichier écrit par le chemin Dart) pour compatibilité.
            val bitmap = loadIcon(context, iconUrl) ?: loadIconFromPath(iconPath)
            if (bitmap != null) {
                views.setImageViewBitmap(R.id.widget_icon, bitmap)
            }

            views.setViewVisibility(
                R.id.widget_loading_overlay,
                if (isLoading) View.VISIBLE else View.GONE
            )

            // Bouton refresh : rafraîchit la position active courante (pas de targetIndex).
            views.setOnClickPendingIntent(
                R.id.widget_refresh_btn,
                refreshPendingIntent(context, requestCode = 0, targetIndex = -1)
            )

            // Boutons de cycle : n'apparaissent que s'il y a plus d'une position.
            val locationCount = locationCount(widgetData.getString("widget_locations", null))
            val activeIndex = widgetData.getInt("widget_active_index", 0)
            if (locationCount > 1) {
                val prevIndex = (activeIndex - 1 + locationCount) % locationCount
                val nextIndex = (activeIndex + 1) % locationCount
                views.setViewVisibility(R.id.widget_prev_btn, View.VISIBLE)
                views.setViewVisibility(R.id.widget_next_btn, View.VISIBLE)
                views.setOnClickPendingIntent(
                    R.id.widget_prev_btn,
                    refreshPendingIntent(context, requestCode = 1, targetIndex = prevIndex)
                )
                views.setOnClickPendingIntent(
                    R.id.widget_next_btn,
                    refreshPendingIntent(context, requestCode = 2, targetIndex = nextIndex)
                )
            } else {
                views.setViewVisibility(R.id.widget_prev_btn, View.GONE)
                views.setViewVisibility(R.id.widget_next_btn, View.GONE)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        // Construit un PendingIntent vers le receiver de refresh. targetIndex >= 0
        // demande de basculer sur cette position (cycle) ; -1 = refresh simple.
        // requestCode distinct par bouton + data Uri unique → intents non fusionnés.
        private fun refreshPendingIntent(
            context: Context,
            requestCode: Int,
            targetIndex: Int
        ): PendingIntent {
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0
            val intent = Intent(context, WeatherWidgetRefreshReceiver::class.java).apply {
                data = Uri.parse("homeWidget://refresh/$requestCode")
                putExtra(WeatherWidgetRefreshReceiver.EXTRA_TARGET_INDEX, targetIndex)
            }
            return PendingIntent.getBroadcast(context, requestCode, intent, flags)
        }

        // PendingIntent qui lance l'app (MainActivity) — utilisé par l'overlay "vide".
        private fun launchAppPendingIntent(context: Context): PendingIntent {
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0
            val launchIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
                ?: Intent()
            return PendingIntent.getActivity(context, 100, launchIntent, flags)
        }

        private fun locationCount(locationsJson: String?): Int {
            if (locationsJson.isNullOrEmpty()) return 0
            return try {
                JSONArray(locationsJson).length()
            } catch (e: Exception) {
                0
            }
        }

        private fun loadIconFromPath(iconPath: String?): Bitmap? {
            if (iconPath == null) return null
            val file = File(iconPath)
            if (!file.exists()) return null
            return BitmapFactory.decodeFile(iconPath)
        }

        // Charge l'icône depuis une URL, mise en cache dans cacheDir/widget_icons
        // (clé = hash de l'URL). Le téléchargement réseau ne se fait QUE hors du
        // main thread (sinon NetworkOnMainThreadException) : depuis onUpdate (main
        // thread) on se contente du cache déjà présent ; le refresh, lui, appelle
        // updateWidget depuis son thread réseau, ce qui déclenche le download.
        private fun loadIcon(context: Context, iconUrl: String?): Bitmap? {
            if (iconUrl.isNullOrEmpty()) return null
            return try {
                val cacheFile = File(context.cacheDir, "widget_icons/${md5(iconUrl)}.png")
                if (!cacheFile.exists()) {
                    val onMainThread = Looper.myLooper() == Looper.getMainLooper()
                    if (onMainThread) return null
                    cacheFile.parentFile?.mkdirs()
                    val conn = (URL(iconUrl).openConnection() as HttpURLConnection).apply {
                        connectTimeout = 10_000
                        readTimeout = 10_000
                    }
                    if (conn.responseCode != 200) return null
                    conn.inputStream.use { input ->
                        cacheFile.outputStream().use { output -> input.copyTo(output) }
                    }
                }
                BitmapFactory.decodeFile(cacheFile.absolutePath)
            } catch (e: Exception) {
                null
            }
        }

        private fun md5(input: String): String {
            val bytes = MessageDigest.getInstance("MD5").digest(input.toByteArray())
            return bytes.joinToString("") { "%02x".format(it) }
        }
    }
}
