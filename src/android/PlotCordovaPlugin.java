/**
 * © 2017 Plot Projects
 * https://www.plotprojects.com
 */
package com.plotprojects.cordova;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import com.plotprojects.retail.android.FilterableNotification;
import com.plotprojects.retail.android.Geotrigger;
import com.plotprojects.retail.android.NotificationTrigger;
import com.plotprojects.retail.android.Plot;
import com.plotprojects.retail.android.PlotConfiguration;
import com.plotprojects.retail.android.SentGeotrigger;
import com.plotprojects.retail.android.SentNotification;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;

public class PlotCordovaPlugin extends CordovaPlugin {

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        handleIntent(cordova.getActivity().getIntent());
    }

    @Override
    public void onNewIntent(Intent intent) {
        handleIntent(intent);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if ("initPlot".equals(action)) {
            this.initPlot(args, callbackContext);
        } else if ("enable".equals(action)) {
            this.enable(callbackContext);
        } else if ("disable".equals(action)) {
            this.disable(callbackContext);
        } else if ("isEnabled".equals(action)) {
            this.isEnabled(callbackContext);
        } else if ("setCooldownPeriod".equals(action)) {
            this.setCooldownPeriod(args, callbackContext);
        } else if ("getVersion".equals(action)) {
            this.getVersion(callbackContext);
        } else if ("defaultNotificationHandler".equals(action)) {
            this.defaultNotificationHandler(args, callbackContext);
        } else if ("mailDebugLog".equals(action)) {
            this.mailDebugLog(callbackContext);
        } else if ("loadedNotifications".equals(action)) {
            this.loadedNotifications(callbackContext);
        } else if ("loadedGeotriggers".equals(action)) {
            this.loadedGeotriggers(callbackContext);
        } else if ("setStringSegmentationProperty".equals(action)) {
            this.setStringSegmentationProperty(args, callbackContext);
        } else if ("setBooleanSegmentationProperty".equals(action)) {
            this.setBooleanSegmentationProperty(args, callbackContext);
        } else if ("setIntegerSegmentationProperty".equals(action)) {
            this.setIntegerSegmentationProperty(args, callbackContext);
        } else if ("setDoubleSegmentationProperty".equals(action)) {
            this.setDoubleSegmentationProperty(args, callbackContext);
        } else if ("setDateSegmentationProperty".equals(action)) {
            this.setDateSegmentationProperty(args, callbackContext);
        } else if ("sentNotifications".equals(action)) {
            this.sentNotifications(callbackContext);
        } else if ("sentGeotriggers".equals(action)) {
            this.sentGeotriggers(callbackContext);
        } else if ("clearSentNotifications".equals(action)) {
            this.clearSentNotifications(callbackContext);
        } else if ("clearSentGeotriggers".equals(action)) {
            this.clearSentGeotriggers(callbackContext);
        } else {
            return false;
        }
        return true;
    }

    private void initPlot(JSONArray args, CallbackContext callbackContext) {
        try {
            JSONObject jsonConfiguration = null;
            try {
                if (args.length() > 0) {
                    jsonConfiguration = args.getJSONObject(0);
                }
            } catch (JSONException e) {
                callbackContext.error("Configuration not specified or not specified correctly.");
                return;
            }
            String publicKey = null;
            try {
                if (jsonConfiguration != null && jsonConfiguration.has("publicKey")) {
                    publicKey = jsonConfiguration.getString("publicKey");
                }
            } catch (JSONException e) {
                callbackContext.error("Public token not specified or not specified correctly.");
                return;
            }
            
            PlotRemoteHandler remoteHandler = new PlotRemoteHandler(cordova.getActivity());
            String remoteNotificationFilter = null;
            if (jsonConfiguration != null && jsonConfiguration.has("remoteNotificationFilter")) {
                remoteNotificationFilter = jsonConfiguration.getString("remoteNotificationFilter");
            }

            String remoteGeotriggerHandler = null;
            if (jsonConfiguration != null && jsonConfiguration.has("remoteGeotriggerHandler")) {
                remoteGeotriggerHandler = jsonConfiguration.getString("remoteGeotriggerHandler");
            }

            remoteHandler.setRemoteNotificationFilter(remoteNotificationFilter);
            remoteHandler.setRemoteGeotriggerHandler(remoteGeotriggerHandler);

            if (publicKey != null) {
                PlotConfiguration configuration = new PlotConfiguration(publicKey);
                try {
                    if (jsonConfiguration.has("cooldownPeriod")) {
                        configuration.setCooldownPeriod(jsonConfiguration.getInt("cooldownPeriod"));
                    }
                } catch (JSONException e) {
                    callbackContext.error("Cooldown period not specified correctly.");
                    return;
                }
                try {
                    if (jsonConfiguration.has("enableOnFirstRun")) {
                        configuration.setEnableOnFirstRun(jsonConfiguration.getBoolean("enableOnFirstRun"));
                    }
                } catch (JSONException e) {
                    callbackContext.error("Enable on first run not specified correctly.");
                    return;
                }
                Plot.init(cordova.getActivity(), configuration);
            } else {
                Plot.init(cordova.getActivity());
            }
            callbackContext.success();
        } catch (Exception e) {
            Log.e("PlotCordovaPlugin", "Error during plotInit", e);
            callbackContext.error(e.getMessage());
        }
    }

    private void enable(CallbackContext callbackContext) {
        try {
            Plot.enable();
            callbackContext.success();
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void disable(CallbackContext callbackContext) {
        try {
            Plot.disable();
            callbackContext.success();
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void isEnabled(CallbackContext callbackContext) {
        try {
            boolean isEnabled = Plot.isEnabled();
            callbackContext.success(isEnabled ? 1 : 0);
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void setCooldownPeriod(JSONArray args, CallbackContext callbackContext) {
        try {
            try {
                int cooldownseconds = args.getInt(0);
                Plot.setCooldownPeriod(cooldownseconds);
                callbackContext.success();
            } catch (JSONException e) {
                callbackContext.error("Cooldown period not specified or not specified correctly.");
            }
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void getVersion(CallbackContext callbackContext) {
        try {
            String version = Plot.getVersion();
            callbackContext.success(version);
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void mailDebugLog(CallbackContext callbackContext) {
        try {
            Plot.mailDebugLog();
            callbackContext.success();
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void defaultNotificationHandler(JSONArray args, CallbackContext callbackContext) {
        try {
            String data = args.getString(1);

            Uri uri = Uri.parse(data);

            Intent openBrowserIntent = new Intent(Intent.ACTION_VIEW, uri);
            openBrowserIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);

            Context context = cordova.getActivity();
            context.startActivity(openBrowserIntent);

            callbackContext.success();
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void setStringSegmentationProperty(JSONArray args, CallbackContext callbackContext) {
        try {
            try {
                String property = args.getString(0);
                String value = args.getString(1);
                Plot.setStringSegmentationProperty(property, value);
                callbackContext.success();
            } catch (JSONException e) {
                callbackContext.error("Segmentation property or value not specified or not specified correctly.");
            }
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void setBooleanSegmentationProperty(JSONArray args, CallbackContext callbackContext) {
        try {
            try {
                String property = args.getString(0);
                Boolean value = args.getBoolean(1);
                Plot.setBooleanSegmentationProperty(property, value);
                callbackContext.success();
            } catch (JSONException e) {
                callbackContext.error("Segmentation property or value not specified or not specified correctly.");
            }
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void setIntegerSegmentationProperty(JSONArray args, CallbackContext callbackContext) {
        try {
            try {
                String property = args.getString(0);
                long value = args.getLong(1);
                Plot.setLongSegmentationProperty(property, value);
                callbackContext.success();
            } catch (JSONException e) {
                callbackContext.error("Segmentation property or value not specified or not specified correctly.");
            }
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void setDoubleSegmentationProperty(JSONArray args, CallbackContext callbackContext) {
        try {
            try {
                String property = args.getString(0);
                double value = args.getDouble(1);
                Plot.setDoubleSegmentationProperty(property, value);
                callbackContext.success();
            } catch (JSONException e) {
                callbackContext.error("Segmentation property or value not specified or not specified correctly.");
            }
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void setDateSegmentationProperty(JSONArray args, CallbackContext callbackContext) {
        try {
            try {
                String property = args.getString(0);
                String value = args.getString(1);
                SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
                Date date = formatter.parse(value);
                Plot.setDateSegmentationProperty(property, date.getTime());
                callbackContext.success();
            } catch (JSONException e) {
                callbackContext.error("Segmentation property or value not specified or not specified correctly.");
            }
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void loadedNotifications(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                Collection<NotificationTrigger> notifications = Plot.getLoadedNotifications();
                try {
                    JSONArray result = new JSONArray();
                    for (NotificationTrigger t : notifications) {
                        result.put(filterableNotificationToJson(t));
                    }

                    callbackContext.success(result);
                } catch (Exception e) {
                    Log.e("PlotCordovaPlugin", "Error during loadedNotifications", e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void loadedGeotriggers(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                Collection<Geotrigger> notifications = Plot.getLoadedGeotriggers();
                try {
                    JSONArray result = new JSONArray();
                    for (Geotrigger t : notifications) {
                        result.put(geotriggerToJson(t));
                    }

                    callbackContext.success(result);
                } catch (Exception e) {
                    Log.e("PlotCordovaPlugin", "Error during loadedNotifications", e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void sentNotifications(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                Collection<SentNotification> notifications = Plot.getSentNotifications();
                try {
                    JSONArray result = new JSONArray();
                    for (SentNotification n : notifications) {
                        result.put(sentNotificationToJson(n));
                    }

                    callbackContext.success(result);
                } catch (Exception e) {
                    Log.e("PlotCordovaPlugin", "Error during getSentNotifications", e);
                    callbackContext.error(e.getMessage());
                }
            }

        });

    }

    private void sentGeotriggers(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                Collection<SentGeotrigger> geotriggers = Plot.getSentGeotriggers();
                try {
                    JSONArray result = new JSONArray();
                    for (SentGeotrigger g : geotriggers) {
                        result.put(sentGeotriggerToJson(g));
                    }

                    callbackContext.success(result);
                } catch (Exception e) {
                    Log.e("PlotCordovaPlugin", "Error during getSentGeotriggers", e);
                    callbackContext.error(e.getMessage());
                }
            }

        });
    }

    private void clearSentNotifications(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    Plot.clearSentNotifications();
                    callbackContext.success();
                } catch (Exception e) {
                    Log.e("PlotCordovaPlugin", "Error during clearSentNotifications", e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void clearSentGeotriggers(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    Plot.clearSentGeotriggers();
                    callbackContext.success();
                } catch (Exception e) {
                    Log.e("PlotCordovaPlugin", "Error during clearSentGeotriggers", e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }


    private JSONObject filterableNotificationToJson(NotificationTrigger notification) throws JSONException {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("id", notification.getId());
        jsonObject.put("message", notification.getMessage());
        jsonObject.put("data", notification.getData());
        if (!Double.isNaN(notification.getGeofenceLatitude())) {
            jsonObject.put("geofenceLatitude", notification.getGeofenceLatitude());
        } else {
            jsonObject.put("geofenceLatitude", null);
        }
        if (!Double.isNaN(notification.getGeofenceLongitude())) {
            jsonObject.put("geofenceLongitude", notification.getGeofenceLongitude());
        } else {
            jsonObject.put("geofenceLongitude", null);
        }
        jsonObject.put("dwellingMinutes", notification.getDwellingMinutes());
        jsonObject.put("trigger", notification.getTrigger());
        jsonObject.put("notificationHandlerType", notification.getHandlerType());
        jsonObject.put("matchRange", notification.getMatchRange());
        jsonObject.put("regionType", notification.getRegionType());

        return jsonObject;
    }

    private JSONObject geotriggerToJson(Geotrigger geotrigger) throws JSONException {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("id", geotrigger.getId());
        jsonObject.put("name", geotrigger.getName());
        jsonObject.put("data", geotrigger.getData());
        if (!Double.isNaN(geotrigger.getGeofenceLatitude())) {
            jsonObject.put("geofenceLatitude", geotrigger.getGeofenceLatitude());
        } else {
            jsonObject.put("geofenceLatitude", null);
        }
        if (!Double.isNaN(geotrigger.getGeofenceLongitude())) {
            jsonObject.put("geofenceLongitude", geotrigger.getGeofenceLongitude());
        } else {
            jsonObject.put("geofenceLongitude", null);
        }
        jsonObject.put("dwellingMinutes", geotrigger.getDwellingMinutes());
        jsonObject.put("trigger", geotrigger.getTrigger());
        jsonObject.put("matchRange", geotrigger.getMatchRange());
        jsonObject.put("regionType", geotrigger.getRegionType());

        return jsonObject;
    }

    private JSONObject sentNotificationToJson(SentNotification sentNotification) throws JSONException {
        JSONObject jsonObject = new JSONObject();

        jsonObject.put("id", sentNotification.getId());
        jsonObject.put("matchId", sentNotification.getMatchId());
        jsonObject.put("message", sentNotification.getMessage());
        jsonObject.put("data", sentNotification.getData());
        if (!Double.isNaN(sentNotification.getGeofenceLatitude())) {
            jsonObject.put("geofenceLatitude", sentNotification.getGeofenceLatitude());
        } else {
            jsonObject.put("geofenceLatitude", null);
        }
        if (!Double.isNaN(sentNotification.getGeofenceLongitude())) {
            jsonObject.put("geofenceLongitude", sentNotification.getGeofenceLongitude());
        } else {
            jsonObject.put("geofenceLongitude", null);
        }
        jsonObject.put("trigger", sentNotification.getTrigger());
        jsonObject.put("dwellingMinutes", sentNotification.getDwellingMinutes());
        jsonObject.put("notificationHandlerType", sentNotification.getHandlerType());
        jsonObject.put("matchRange", sentNotification.getMatchRange());
        jsonObject.put("regionType", sentNotification.getRegionType());
        jsonObject.put("dateSent", sentNotification.getDateSent());
        jsonObject.put("dateOpened", sentNotification.getDateOpened());
        jsonObject.put("isOpened", sentNotification.isOpened());

        return jsonObject;
    }

    private JSONObject sentGeotriggerToJson(SentGeotrigger sentGeotrigger) throws JSONException {
        JSONObject jsonObject = new JSONObject();

        jsonObject.put("id", sentGeotrigger.getId());
        jsonObject.put("matchId", sentGeotrigger.getMatchId());
        jsonObject.put("data", sentGeotrigger.getData());
        if (!Double.isNaN(sentGeotrigger.getGeofenceLatitude())) {
            jsonObject.put("geofenceLatitude", sentGeotrigger.getGeofenceLatitude());
        } else {
            jsonObject.put("geofenceLatitude", null);
        }
        if (!Double.isNaN(sentGeotrigger.getGeofenceLongitude())) {
            jsonObject.put("geofenceLongitude", sentGeotrigger.getGeofenceLongitude());
        } else {
            jsonObject.put("geofenceLongitude", null);
        }
        jsonObject.put("trigger", sentGeotrigger.getTrigger());
        jsonObject.put("dwellingMinutes", sentGeotrigger.getDwellingMinutes());
        jsonObject.put("matchRange", sentGeotrigger.getMatchRange());
        jsonObject.put("regionType", sentGeotrigger.getRegionType());
        jsonObject.put("dateSent", sentGeotrigger.getDateSent());
        jsonObject.put("dateHandled", sentGeotrigger.getDateHandled());
        jsonObject.put("isHandled", sentGeotrigger.isHandled());

        return jsonObject;
    }

    private void handleIntent(Intent intent) {
        if (intent != null && intent.hasExtra("originalPlotIntent")) {
            Intent originalIntent = intent.getParcelableExtra("originalPlotIntent");
            originalIntent.setExtrasClassLoader(getClass().getClassLoader());
            FilterableNotification notification = originalIntent.getParcelableExtra("notification");

            try {
                JSONObject jsonObject = filterableNotificationToJson(notification);

                String javascript = "cordova.require(\"cordova/plugin/plot\")._runNotificationHandler($handler)".replace("$handler", jsonObject.toString());

                webView.sendJavascript(javascript);
            } catch (JSONException e) {
                Log.e("PlotCordovaPlugin", "Failed to write JSON", e);
            }
        }
    }

}

