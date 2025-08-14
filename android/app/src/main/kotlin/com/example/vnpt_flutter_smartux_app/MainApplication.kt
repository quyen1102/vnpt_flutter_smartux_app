package com.example.vnpt_flutter_smartux_app

import android.app.Application
import ic.vnpt.analytics.heatmap.SmartUX
import ic.vnpt.analytics.heatmap.util.DisableUploadImage

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // app key get from admin page
        SmartUX.init(
            application = this,
            domain = "https://console-smartux.vnpt.vn",
            projectKey = "<PROJECT_KEY>",
            isDisableUploadImage = DisableUploadImage.NO
        )
    }
}