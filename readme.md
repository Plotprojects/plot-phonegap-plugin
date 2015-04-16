Plot PhoneGap Plugin
====================
Install Plot into your PhoneGap/Cordova app quickly

Get location based notifications in your PhoneGap app! Now also experimental support for iBeacon in the iOS version.

### Supported platforms ###

This plugins requires PhoneGap 3.0.0 or higher.
This plugins supports both IOS 6 or newer, and Android 2.3 or newer.

### Installation ###

You can add the plugin to an existing project by executing the following command:

Phonegap: ```phonegap local plugin add https://github.com/Plotprojects/plot-phonegap-plugin/```
 
Cordova: ```cordova plugin add https://github.com/Plotprojects/plot-phonegap-plugin/```

Or add this to your config.xml when you are using PhoneGap Build:
```<gap:plugin name="com.plotprojects.cordova" source="plugins.cordova.io" />```

The following snippet has to be added to the first page that is loaded to initialize Plot:
```
<script type="text/javascript">
document.addEventListener("deviceready", deviceReady, true);
function deviceReady() {
  var plot = cordova.require("cordova/plugin/plot");
  plot.init({});
}
</script>
```

Before you can use this plugin you have to put `plotconfig.json` in the `www/` folder. You can obtain your `plotconfig.json` with your own public token for free at: http://www.plotprojects.com/getourplugin/ 

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

To change the action when a notification has been received you can use the notificationHandler. This feature is available both on IOS and Android.
```
//Optional, by default the data is treated as URL and opened in a separate application:
//Place this function BEFORE plot.init();
plot.notificationHandler = function(notification, data) {
  alert(data);
}
```

### More information ###
Website: http://www.plotprojects.com/

Documentation: http://www.plotprojects.com/support

Android plugin: http://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-android/

IOS plugin: http://www.plotprojects.com/developing-a-cordova-phonegap-plugin-for-ios/

### License ###
The source files included in the repository are released under the Apache License, Version 2.0.
