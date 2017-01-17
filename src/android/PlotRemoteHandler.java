/**
 * © 2017 Plot Projects
 * https://www.plotprojects.com
 */
package com.plotprojects.cordova;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.plotprojects.retail.android.BaseTrigger;
import com.plotprojects.retail.android.FilterableNotification;
import com.plotprojects.retail.android.Geotrigger;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

class PlotRemoteHandler {
    private final static String LOG_TAG = "PlotRemoteHandler";

    private final String SETTINGS_FILE = "filter-settings";
    private final String NOTIFICATION_FILTER = "notification-filter";
    private final String GEOTRIGGER_HANDLER = "geotrigger-handler";

    private final Context context;

    public PlotRemoteHandler(Context context) {
        this.context = context;
    }

    void setRemoteNotificationFilter(String filterUrl) {
        setRemoteUrl(NOTIFICATION_FILTER, filterUrl);
    }

    void setRemoteGeotriggerHandler(String filterUrl) {
        setRemoteUrl(GEOTRIGGER_HANDLER, filterUrl);
    }

    List<FilterableNotification> filterableNotifications(List<FilterableNotification> notifications) {
        String url = getRemoteUrl(NOTIFICATION_FILTER);
        if (url == null) {
            return notifications;
        }

        try {
            String body = triggerListToString(notifications, "notifications", new TypeSpecificFieldWriter<FilterableNotification>() {
                @Override
                public void writeFields(FilterableNotification filterableNotification, JSONObject obj) throws JSONException {
                    obj.put("message", filterableNotification.getMessage());
                }
            });

            String response = performHttpCall(url, body);

            return parseNotificationFilterResponse(response, notifications);
        } catch (IOException e) {
            Log.e(LOG_TAG, "Failure in remote notification filter", e);
            return Collections.emptyList();
        }
    }

    void sendGeotriggers(List<Geotrigger> list) {
        String url = getRemoteUrl(GEOTRIGGER_HANDLER);
        if (url == null) {
            return;
        }

        try {
            String body = triggerListToString(list, "geotriggers", new TypeSpecificFieldWriter<Geotrigger>() {
                @Override
                public void writeFields(Geotrigger geotrigger, JSONObject obj) throws JSONException {
                    obj.put("name", geotrigger.getName());
                }
            });

            performHttpCall(url, body);
        } catch (IOException e) {
            Log.e(LOG_TAG, "Failure in remote geotrigger handler", e);
        }
    }

    private <E extends BaseTrigger> String triggerListToString(List<E> triggers,
                                                               String fieldName,
                                                               TypeSpecificFieldWriter<E> typeSpecificFieldWriter) throws IOException {
        try {
            JSONArray items = new JSONArray();

            for (E t : triggers) {
                JSONObject row = new JSONObject();
                row.put("identifier", t.getId());
                row.put("data", t.getData());
                row.put("latitude", t.getGeofenceLatitude());
                row.put("longitude", t.getGeofenceLongitude());
                row.put("trigger", t.getTrigger());
                row.put("matchIdentifier", t.getMatchId());
                row.put("matchRange", t.getMatchRange());
                row.put("regionType", t.getRegionType());

                typeSpecificFieldWriter.writeFields(t, row);

                items.put(row);
            }

            JSONObject result = new JSONObject();
            result.put(fieldName, items);

            return result.toString();
        } catch (JSONException e) {
            throw new IOException("Failed to generate JSON for request", e);
        }
    }

    private List<FilterableNotification> parseNotificationFilterResponse(String response,
                                                                         List<FilterableNotification> passedNotifications) throws IOException {
        try {
            JSONObject jsonObject = new JSONObject(response);

            JSONArray notifications = jsonObject.getJSONArray("notifications");

            List<FilterableNotification> result = new ArrayList<FilterableNotification>();

            for (int i = 0; i < notifications.length(); i++) {
                JSONObject n = notifications.getJSONObject(i);

                String identifier = n.getString("identifier");

                boolean found = false;
                for (FilterableNotification filterableNotification : passedNotifications) {
                    if (filterableNotification.getId().equals(identifier)) {
                        found = true;

                        if (n.has("message")) {
                            filterableNotification.setMessage(n.getString("message"));
                        }
                        if (n.has("data")) {
                            filterableNotification.setData(n.getString("data"));
                        }
                        result.add(filterableNotification);

                        break;
                    }
                }

                if (!found) {
                    Log.i(LOG_TAG, "Unknown notification identifier: " + identifier);
                }
            }

            return result;

        } catch (JSONException e) {
            throw new IOException("Failed to parse JSON response", e);
        }
    }

    private String performHttpCall(String filterUrl, String body) throws IOException {
        URL url = new URL(filterUrl);

        Log.i(LOG_TAG, "Performing request to: " + filterUrl);

        HttpURLConnection connection = (HttpURLConnection) url.openConnection();

        try {
            connection.setRequestMethod("POST");

            connection.setRequestProperty("Content-Type", "application/json");
            connection.setRequestProperty("Accept", "application/json");

            connection.setDoInput(true);
            connection.setDoOutput(true);

            byte[] bodyBytes = body.getBytes("UTF-8");
            connection.setFixedLengthStreamingMode(bodyBytes.length);
            connection.getOutputStream().write(bodyBytes);

            int code = connection.getResponseCode();
            if (code >= 200 && code < 300) {
                return readInputstream(connection.getInputStream());
            } else {
                throw new IOException("Request failed: Unexpected status code - " + code);
            }
        } finally {
            try {
                connection.disconnect();
            } catch (Exception e) {
                //ignore
            }
        }
    }

    private String readInputstream(InputStream stream) throws IOException {
        ByteArrayOutputStream streamContents = new ByteArrayOutputStream();
        byte[] buffer = new byte[512];

        while (true) {
            int read = stream.read(buffer);
            if (read >= 0) {
                streamContents.write(buffer, 0, read);
            } else {
                break;
            }
        }
        stream.close();

        return new String(streamContents.toByteArray(), "UTF-8");
    }

    private void setRemoteUrl(String key, String url) {
        SharedPreferences sharedPref = context.getSharedPreferences(SETTINGS_FILE, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPref.edit();
        if (url == null) {
            editor.remove(key);
        } else {
            editor.putString(key, url);
        }
        editor.apply();
    }

    private String getRemoteUrl(String key) {
        SharedPreferences sharedPref = context.getSharedPreferences(SETTINGS_FILE, Context.MODE_PRIVATE);
        return sharedPref.getString(key, null);
    }

    private interface TypeSpecificFieldWriter<E> {
        void writeFields(E e, JSONObject obj) throws JSONException;
    }
}
