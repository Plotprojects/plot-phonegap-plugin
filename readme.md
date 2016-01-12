Plot PhoneGap Plugin
====================
Install Plot into your PhoneGap/Cordova app quickly

Get location based notifications in your PhoneGap app! Now also supports iBeacons for iOS out of the box and for Android after also integrating our Android iBeacon plugin found here: [https://github.com/Plotprojects/plot-phonegap-plugin-androidibeacons](https://github.com/Plotprojects/plot-phonegap-plugin-androidibeacons)

### Supported platforms ###

This plugins requires PhoneGap 3.0.0 or higher.
This plugins supports both IOS 6 or newer, and Android 2.3 or newer.

### Phonegap Build ###

You have to add the following line to `config.xml` to add our plugin:

```<gap:plugin name="cordova-plotprojects" source="npm" version="1.13.0" />```

### Installation other environments ###

You can add the plugin to an existing project by executing the following command:

Phonegap: ```phonegap plugin add cordova-plotprojects```
 
Cordova: ```cordova plugin add cordova-plotprojects```

### Integration and configuration ###

You can find the integration guide at our website: [http://www.plotprojects.com/phonegap-integration/](http://www.plotprojects.com/phonegap-integration/)

Additional settings are possible using the configuration file, an example is shown below. The publicToken and enableOnFirstRun fields are required, the notificationSmallIcon, notificationAccentColor and askPermissionAgainAfterDays options are Android only, the maxRegionsMonitored is an iOS only setting.

Information about these settings can be found in our extensive documentation, in chapter 1.4: [http://www.plotprojects.com/documentation#ConfigurationFile](http://www.plotprojects.com/documentation#ConfigurationFile)

```
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

_plot.enable()_

Enables Plot.

_plot.disable()_

Disables Plot.

_plot.isEnabled()_

Returns whether plot is enabled (read-only).

_plot.setCooldownPeriod(cooldownSeconds)_

Updates the cooldown period.

_plot.getVersion()_

Returns the current version of the Plot plugin.

_plot.mailDebugLog()_

Sends the collected debug log via mail. It will open your mail application to send the mail.

### Function reference - Segmentation ###

More information about this feature can be found on our documentation page: [http://www.plotprojects.com/documentation#phonegap_segmentation](http://www.plotprojects.com/documentation#phonegap_segmentation)

_plot.setStringSegmentationProperty(property, value)_

Sets a string property for the device on which notifications can be segmented.

_plot.setBooleanSegmentationProperty(property, value)_

Sets a boolean property for the device on which notifications can be segmented.

_plot.setIntegerSegmentationProperty(property, value)_

Sets an integer property for the device on which notifications can be segmented.

_plot.setDoubleSegmentationProperty(property, value)_

Sets a double property for the device on which notifications can be segmented.

_plot.setDateSegmentationProperty(property, value)_

Sets a date property for the device on which notifications can be segmented. Value should be a JavaScript Date.

### Notification Filter ###

To intercept notifications before they are shown you can use the filterCallback. This feature is only available on IOS.
```
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
```
//Optional, by default the data is treated as URL and opened in a separate application:
//Place this function BEFORE plot.init();
plot.notificationHandler = function(notification, data) {
  alert(data);
}
```

### Retrieving loaded notifications and geotriggers ###

You can retrieve the loaded notifications and geotriggers using the `loadedNotifications(callback)` and the `loadedGeotriggers(callback)` method.

```
plot.loadedNotifications(function(notifications) {
	
});

plot.loadedGeotriggers(function(geotriggers) {
	
});
```

### More information ###
Website: [http://www.plotprojects.com/](http://www.plotprojects.com/)

Documentation: [http://www.plotprojects.com/documentation](http://www.plotprojects.com/documentation)

Android plugin: [http://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-android/](http://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-android/)

IOS plugin: [http://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-ios/](http://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-ios/)

### License ###
The source files included in the repository are released under the Apache License, Version 2.0.
