package com.plotprojects.cordova;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import com.plotprojects.retail.android.FilterableNotification;
import com.plotprojects.retail.android.Plot;
import com.plotprojects.retail.android.PlotConfiguration;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

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

    private void handleIntent(Intent intent) {
        if (intent != null && intent.hasExtra("originalPlotIntent")) {
            Intent originalIntent = intent.getParcelableExtra("originalPlotIntent");
            originalIntent.setExtrasClassLoader(getClass().getClassLoader());
            FilterableNotification notification = originalIntent.getParcelableExtra("notification");

            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("id", notification.getId());
                jsonObject.put("message", notification.getMessage());
                jsonObject.put("data", notification.getData());

                String javascript = "cordova.require(\"cordova/plugin/plot\")._runNotificationHandler($handler)".replace("$handler", jsonObject.toString());

                webView.sendJavascript(javascript);
            } catch (JSONException e) {
                Log.e("PlotCordovaPlugin", "Failed to write JSON", e);
            }
        }
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
        } else if ("setEnableBackgroundModeWarning".equals(action)) {
            // Not available on Android
            callbackContext.success();
        } else if ("getVersion".equals(action)) {
            this.getVersion(callbackContext);
        } else if ("defaultNotificationHandler".equals(action)) {
            this.defaultNotificationHandler(args, callbackContext);
        } else {
            return false;
        }
        return true;
    }

    private void initPlot(JSONArray args, CallbackContext callbackContext) {
        try {
            JSONObject jsonConfiguration;
            try {
                jsonConfiguration = args.getJSONObject(0);
            } catch (JSONException e) {
                callbackContext.error("Configuration not specified or not specified correctly.");
                return;
            }
            String publicKey;
            try {
                publicKey = jsonConfiguration.getString("publicKey");
            } catch (JSONException e) {
                callbackContext.error("Public key not specified or not specified correctly.");
                return;
            }
            PlotConfiguration configuration = new PlotConfiguration(publicKey);
            try {
                if (jsonConfiguration.has("cooldownPeriod"))
                    configuration.setCooldownPeriod(jsonConfiguration.getInt("cooldownPeriod"));
            } catch (JSONException e) {
                callbackContext.error("Cooldown period not specified correctly.");
                return;
            }
            try {
                if (jsonConfiguration.has("enableOnFirstRun"))
                    configuration.setEnableOnFirstRun(jsonConfiguration.getBoolean("enableOnFirstRun"));
            } catch (JSONException e) {
                callbackContext.error("Enable on first run not specified correctly.");
                return;
            }
            Plot.init(cordova.getActivity(), configuration);
            callbackContext.success();
        } catch (Exception e) {
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

}

