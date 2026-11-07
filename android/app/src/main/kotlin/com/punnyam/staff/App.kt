package com.punnyam.staff

import android.app.Application
import com.pnsol.sdk.util.MpayEnvironmentConfig
import ps.module.PsModuleProvider

class App : Application() {
    override fun onCreate() {
        super.onCreate()
        PsModuleProvider
            .withMpayEnvironment(
                MpayEnvironmentConfig.getEnvironment(null, BuildConfig.PS_ENV) // qa / uat / release - ask Payswiff
            )
            .initialize(this, BuildConfig.PS_APP_NAME) // APPLICATION_NAME - ask Payswiff
    }
}