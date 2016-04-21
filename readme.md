Plot PhoneGap Plugin
====================
Install Plot into your PhoneGap/Cordova/Ionic app quickly

Get location based notifications in your PhoneGap app! Now also supports iBeacons for iOS out of the box and for Android after also integrating our Android iBeacon plugin found here: [https://github.com/Plotprojects/plot-phonegap-plugin-androidibeacons](https://github.com/Plotprojects/plot-phonegap-plugin-androidibeacons)

### Supported platforms ###

This plugins requires PhoneGap 3.0.0 or higher.
This plugins supports both IOS 6 or newer, and Android 2.3 or newer.

### Phonegap Build ###

You have to add the following line to `config.xml` to add our plugin:

```<gap:plugin name="cordova-plotprojects" source="npm" version="1.x" />```

### Installation other environments ###

You can add the plugin to an existing project by executing the following command:

Phonegap: ```phonegap plugin add cordova-plotprojects```
 
Cordova/Ionic: ```cordova plugin add cordova-plotprojects```

### Integration and configuration ###

You can find the integration guide at our website:

| :book: [Integration Guide](http://www.plotprojects.com/phonegap-integration/) |
| :---: |

Additional settings are possible using the configuration file, an example is shown below. The publicToken and enableOnFirstRun fields are required, the notificationSmallIcon, notificationAccentColor and askPermissionAgainAfterDays options are Android only, the maxRegionsMonitored is an iOS only setting.

Information about these settings can be found in our extensive documentation, in chapter 1.4: [http://www.plotprojects.com/documentation#ConfigurationFile](http://www.plotprojects.com/documentation#ConfigurationFile)

```javascript
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

_plot.setCooldownPeriod(cooldownSeconds, successCallback, failureCallback)_

Updates the cooldown period.

_plot.getVersion(resultCallback, failureCallback)_

Returns the current version of the Plot plugin.

_plot.mailDebugLog(successCallback, failureCallback)_

Sends the collected debug log via mail. It will open your mail application to send the mail.

### Function reference - Segmentation ###

More information about this feature can be found on our documentation page: [http://www.plotprojects.com/documentation#phonegap_segmentation](http://www.plotprojects.com/documentation#phonegap_segmentation)

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
    notifications[i].data = "http://www.example.com";
  }
	return notifications;
};
```

### Notification Handler ###

To change the action when a notification has been received you can use the notificationHandler. This feature is available both on IOS and Android.
```javascript
//Optional, by default the data is treated as URL and opened in a separate application:
//Place this function BEFORE plot.init();
plot.notificationHandler = function(notification, data) {
  alert(data);
}
```

### More information ###
Website: [http://www.plotprojects.com/](http://www.plotprojects.com/)

Documentation: [http://www.plotprojects.com/documentation](http://www.plotprojects.com/documentation)

Android plugin: [http://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-android/](http://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-android/)

IOS plugin: [http://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-ios/](http://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-ios/)

### License ###
The source files included in the repository are released under the Apache License, Version 2.0.
