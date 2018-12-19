Plot PhoneGap Plugin
====================
Install Plot into your PhoneGap/Cordova/Ionic app quickly

Get location based notifications in your PhoneGap app! Now also supports iBeacons for iOS out of the box and for Android after also integrating our Android iBeacon plugin found here: [https://github.com/Plotprojects/plot-phonegap-plugin-androidibeacons](https://github.com/Plotprojects/plot-phonegap-plugin-androidibeacons)

### Supported platforms ###

This plugins requires Cordova 8.0.0 or higher.
This plugin requires Cordova-Android 7.1.4 or higher.
This plugins supports both IOS 10 or newer, and Android 4.0 or newer.

### Phonegap Build ###

You have to add the following line to `config.xml` to add our plugin:

```<gap:plugin name="cordova-plotprojects" source="npm" version="3.x" />```

### Installation other environments ###

You can add the plugin to an existing project by executing the following command:

Phonegap: ```phonegap plugin add cordova-plotprojects```

Cordova/Ionic: ```cordova plugin add cordova-plotprojects```

### Integration and configuration ###

You can find the integration guide at our website:

| :book: [Integration Guide](https://www.plotprojects.com/phonegap-integration/) |
| :---: |

Additional settings are possible using the configuration file, an example is shown below. The publicToken and enableOnFirstRun fields are required, the notificationSmallIcon, notificationAccentColor and askPermissionAgainAfterDays options are Android only, the maxRegionsMonitored is an iOS only setting.

Information about these settings can be found in our extensive documentation, in chapter 1.4: [https://www.plotprojects.com/documentation#ConfigurationFile](https://www.plotprojects.com/documentation#ConfigurationFile)

```json
{
  "publicToken": "REPLACE_ME",
  "enableOnFirstRun": true,
  "notificationSmallIcon": "ic_mood_white_24dp",
  "notificationAccentColor": "#01579B",
  "askPermissionAgainAfterDays": 3,
  "maxRegionsMonitored": 20
}
```

### Function reference ###

All functions return `undefined` and have either a successCallback or a resultCallback to return the result. These methods are called when the operation is successfully performed.
When the method returns a result then this will be passed as an argument in the result callback. Also every function has a failureCallback which contains the error information when
an operation failed. Only one of these two methods will be called. The successCallbacks and the failureCallbacks are optional arguments. The resultCallback is required.

_plot.init(configuration, successCallback, failureCallback)_

Initialises Plot. You must call this method before using the other methods. The configuration parameter is optional. When specified it has to be an object with one or more of the
following properties:

| Parameter | Type | Optional | Description |
|---|---|---|---|
| remoteNotificationFilter | String | yes | Sets the url of the remote notification filter. See the section about Notification Filter chapter for more info. For best results use an url starting with `https://. |
| remoteGeotriggerHandler | String | yes | Sets the url of the remote geotrigger handler. See the section about Notification Filter chapter for more info. For best results use an url starting with `https://. |

_plot.enable(successCallback, failureCallback)_

Enables Plot.

_plot.disable(successCallback, failureCallback)_

Disables Plot.

_plot.isEnabled(resultCallback, failureCallback)_

Returns whether plot is enabled (read-only).

Example:
```javascript
plot.isEnabled(function(enabled) {
	var plotEnabledState = enabled ? "enabled" : "disabled";
	console.log("Plot is " + plotEnabledState);
}, function (err) {
	console.log("Failed to determine whether Plot is enabled: " + err);
});
```
_plot.getVersion(resultCallback, failureCallback)_

Returns the current version of the Plot plugin.

_plot.mailDebugLog(successCallback, failureCallback)_

Sends the collected debug log via mail. It will open your mail application to send the mail.

### Function reference - Segmentation ###

More information about this feature can be found on our documentation page: [https://www.plotprojects.com/documentation#phonegap_segmentation](https://www.plotprojects.com/documentation#phonegap_segmentation)

_plot.setStringSegmentationProperty(property, value, successCallback, failureCallback)_

Sets a string property for the device on which notifications can be segmented.

_plot.setBooleanSegmentationProperty(property, value, successCallback, failureCallback)_

Sets a boolean property for the device on which notifications can be segmented.

_plot.setIntegerSegmentationProperty(property, value, successCallback, failureCallback)_

Sets an integer property for the device on which notifications can be segmented.

_plot.setDoubleSegmentationProperty(property, value, successCallback, failureCallback)_

Sets a double property for the device on which notifications can be segmented.

_plot.setDateSegmentationProperty(property, value, successCallback, failureCallback)_

Sets a date property for the device on which notifications can be segmented. Value should be a JavaScript Date.

### Function reference - Notifications and geotriggers ###

_plot.loadedNotifications(resultCallback, failureCallback)_

Retrieve a list of notifications currently loaded. Please note that it may take some time if Plot is started for the first time before the notifications are loaded.

_plot.loadedGeotriggers(resultCallback, failureCallback)_

Retrieve a list of geotriggers currently loaded. Please note that it may take some time if Plot is started for the first time before the geotriggers are loaded.

_plot.sentNotifications(resultCallback, failureCallback)_

Retrieve a list of the last 100 sent notifications. It is also possible to clear this list by calling `clearSentNotifications()`.

_plot.sentGeotriggers(resultCallback, failureCallback)_

Retrieve a list of the last 100 sent geotriggers. It is also possible to clear this list by calling `clearSentGeotriggers()`.

_plot.clearSentNotifications(successCallback, failureCallback)_

Clears the list of sent notifications.

_plot.clearSentGeotriggers(successCallback, failureCallback)_

Clears the list of sent geotriggers.

### Notification Filter ###

To intercept notifications before they are shown you can use the filterCallback. This feature is only available on IOS.
```javascript
//Optional, by default all notifications are sent:
//Place this function BEFORE plot.init();
plot.filterCallback = function(notifications) {
  for (var i = 0; i < notifications.length; i++) {
    notifications[i].message = "NewMessage";
    notifications[i].data = "https://www.example.com";
  }
	return notifications;
};
```
The remote notification filter and the filterCallback cannot be combined. When the remote notification filter is enabled, the filterCallback is no longer used.

### Notification Handler ###

To change the action when a notification has been received you can use the notificationHandler. This feature is available both on IOS and Android.
```javascript
//Optional, by default the data is treated as URL and opened in a separate application:
//Place this function BEFORE plot.init();
plot.notificationHandler = function(notification, data) {
  alert(data);
};
```

### Remote Notification Filter / Remote Geotrigger Handler ###

It is possible to implement a remote notification filter and/or a remote geotrigger handler in your app. When the device enters the geofence area of a notification or geotrigger,
the corresponding remote endpoint is called using a *HTTP POST* request. The body contains a list of all notifications/geotriggers triggered in a JSON format. This feature is
specificly for the Cordova/Phonegap plugin of Plot and works the same for both iOS and Android. Performing requests to a HTTP endpoint will increase the battery usage of your app.
Therefore it is recommended to keep the number of triggers low.

The remote notification filter makes it possible to change the text of the notification message or change the data field, so the action is changed when the user taps on the
notification. Other properties of the notification cannot be changed using the filter. Messages for the remote notification filter are identified on the `identifier` field. It is also possible to prevent notification from being shown by leaving out a specific
notification in the response.  When the response doesn't include one or more notifications that were listed in the request, then those notification will be filtered
  out and won't be shown to the user. When no internet connection is available or when the remote endpoint doesn't respond with a correct response the won't show a notification. It is
possible that the request is then tried again at a later time. When an endpoint returns a notification is not guaranteed that the notification is shown on the device.

**Enabling remote notification filter and handler:**

This feature is enabled by passing the URL of the http(s) endpoint in the `plot.init(configuration)` call. Use `remoteNotificationFilter` for the remote notification filter and
`remoteGeotriggerHandler` for the geotrigger handler. When those fields are not present the remote filter/handler is disabled. It is possible to include some metadata in the url, 
for example a _user identifier_.

Due to more [strict App Store requirements](https://developer.apple.com/news/?id=12212016b) related to the user's privacy, it is strongly recommended to use an url that starts with
`https://` instead of `http://`. You can still use `http://` urls during development. Also for Android using `https` has benefits, such as the guarantee you're talking to the right
host and preventing the message being intercepted.

```javascript
plot.init(
  {
    "remoteNotificationFilter": "https://www.example.com/myRemoteNotificationFilter?userId=625DEECB-5A77-4C1C-80F4-286704CDB256",
    "remoteGeotriggerHandler": "https://www.example.com/myRemoteGeotriggerHandler?userId=625DEECB-5A77-4C1C-80F4-286704CDB256"
  },
  function() { console.log("success"); },
  function(err) { console.log("failed"); console.log(err); }
);
```

**Remote Notification Request format (created by the plugin):**
```javascript
{
   "notifications":[{
         "identifier":"53d…", //Identifier to use in the response
         "message":"…",
         "data":"…",
         … //other fields
   }, …
   ]
}
```

**Remote Notification Response format (should be created by your http endpoint):**
```javascript
{
 "notifications": [{ //only add return notifications that have to be shown to the user
   "identifier": "53d…", //required, must equal the identifier from the request
   "message": "Replaced message", //optional, leave out to leave unchanged
   "data": "Replaced data" //optional, leave out to leave unchanged
 }, …
 ]
}
```

The remote geotrigger handler makes it possible to get informed when a device enters an area you're monitoring using geotriggers. When the request to the specified endpoint fails
it isn't retried. The response from the endpoint is ignored.

**Remote Geotrigger Handler format (created by the plugin):**
```javascript
{
   "geotriggers":[
      {
         "identifier":"51b…",
         "data":"This is the data field",
         "name":"Office geotrigger",
         … //other fields
      }
   ]
}
```

**Example remote notification filter request from the plugin**
```json
{
   "notifications":[
      {
         "identifier":"53d1172499404553b7866a8a3b50f043;5cf8dda440b2463690d0a27a92e1a7ec",
         "data":"",
         "latitude":52.343879,
         "longitude":4.916599799999972,
         "trigger":"enter",
         "matchIdentifier":"72496958-d17b-4fc5-a66e-9b698beb4507",
         "matchRange":500,
         "regionType":"geofence",
         "message":"Office notification!"
      }
   ]
}
```

**Example remote notification filter responses**
Replace the notification message and the data field:
```json
{
 "notifications": [{
   "identifier": "53d1172499404553b7866a8a3b50f043;5cf8dda440b2463690d0a27a92e1a7ec",
   "message": "Replaced message!",
   "data": "Replaced data!"
 }]
}
```

Don't show any notifications:
```json
{
 "notifications": []
}
```

**Example remote geotrigger request**
```json
{
   "geotriggers":[
      {
         "identifier":"51bb194a65ea42509bda93a004de9ce0;5cf8dda440b2463690d0a27a92e1a7ec",
         "data":"This is the data field",
         "latitude":52.343879,
         "longitude":4.916599799999972,
         "trigger":"enter",
         "matchIdentifier":"330fe158-6d53-485b-9051-5ce8bf7ef8e0",
         "matchRange":500,
         "regionType":"geofence",
         "name":"Office geotrigger"
      }
   ]
}
```

### More information ###
Website: [https://www.plotprojects.com/](https://www.plotprojects.com/)

Documentation: [https://www.plotprojects.com/documentation](https://www.plotprojects.com/documentation)

Android plugin: [https://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-android/](https://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-android/)

IOS plugin: [https://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-ios/](https://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-ios/)

### License ###
The source files included in the repository are released under the Apache License, Version 2.0.
