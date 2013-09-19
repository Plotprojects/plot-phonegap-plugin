package com.plotprojects.cordova;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.plotprojects.retail.android.Plot;
import com.plotprojects.retail.android.PlotConfiguration;

public class PlotCordovaPlugin extends CordovaPlugin {

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

}

