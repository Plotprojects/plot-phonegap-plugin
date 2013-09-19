
Plot PhoneGap Plugin
====================
Install Plot into your PhoneGap/Cordova app quickly

### Supported platforms ###

This plugins requires PhoneGap 3.0.0 or higher.
This plugins supports both IOS and Android.

### Installation ###

You can add the plugin to an existing project by executing the following command:
```phonegap local plugin add https://github.com/Plotprojects/plot-phonegap-plugin/```

The following snippet has to be added to the first page that is loaded to initialze Plot:
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

### More information ###
http://www.plotprojects.com/

### License ###
The source files included in the repository are released under the Apache License, Version 2.0.
