package com.plotprojects.cordova;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;

public class PlotCordovaNotificationOpenReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        PackageManager pm = context.getPackageManager();

        Intent startIntent = pm.getLaunchIntentForPackage(context.getPackageName());
        startIntent.setAction(Intent.ACTION_MAIN);
        startIntent.putExtra("originalPlotIntent", intent);
        startIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        context.startActivity(startIntent);
    }

}