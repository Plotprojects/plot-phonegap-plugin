Plot PhoneGap Plugin
====================
Install Plot into your PhoneGap/Cordova app quickly

Get location based notifications in your PhoneGap app! Now also experimental support for iBeacon in the iOS version.

### Supported platforms ###

This plugins requires PhoneGap 3.0.0 or higher.
This plugins supports both IOS and Android.

### Installation ###

You can add the plugin to an existing project by executing the following command:
```phonegap local plugin add https://github.com/Plotprojects/plot-phonegap-plugin/```
or 
```cordova plugin add https://github.com/Plotprojects/plot-phonegap-plugin/```
in case you are using Cordova.
or add this to your config.xml if you are using PhoneGap Build:
```<gap:plugin name="com.plotprojects.cordova" source="plugins.cordova.io" />```

The following snippet has to be added to the first page that is loaded to initialize Plot:
```
<script type="text/javascript">
document.addEventListener("deviceready", deviceReady, true);
function deviceReady() {
  var plot = cordova.require("cordova/plugin/plot");
  var config = plot.exampleConfiguration;
  config.publicKey = "REPLACE_ME"; //put your public key here
  plot.init(config);
}
</script>
```

You can obtain the public key at: http://www.plotprojects.com/

To intercept notifications before they are shown you can use the filterCallback. This feature is only available on IOS.
```
//Optional, by default all notifications are sent:
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
