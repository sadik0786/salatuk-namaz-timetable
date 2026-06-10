package com.salatuk.timetable

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetProviderGlass : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout_glass).apply {
                val prayerName = widgetData.getString("prayer_name", "Next Prayer")
                val prayerTime = widgetData.getString("prayer_time", "--:--")
                val prayerAmPm = widgetData.getString("prayer_am_pm", "")
                val hijriDate = widgetData.getString("hijri_date", "")
                
                setTextViewText(R.id.prayer_name, prayerName)
                setTextViewText(R.id.prayer_time, prayerTime)
                setTextViewText(R.id.prayer_am_pm, prayerAmPm)
                setTextViewText(R.id.hijri_date, hijriDate)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
