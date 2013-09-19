cordova.define("cordova/plugin/plot", function(require, exports, module) {
	plot = {};
	plot.exampleConfiguration = { "publicKey": "", "cooldownPeriod": -1, "enableOnFirstRun": true, "enableBackgroundModeWarning": true };
	plot.init = function(configuration, successCallback, failureCallback) {
		 cordova.exec(successCallback, failureCallback, "PlotCordovaPlugin", "initPlot", [configuration]);
	};
	plot.enable = function(successCallback, failureCallback) {
		 cordova.exec(successCallback, failureCallback, "PlotCordovaPlugin", "enable", []);
	};
	plot.disable = function(successCallback, failureCallback) {
		 cordova.exec(successCallback, failureCallback, "PlotCordovaPlugin", "disable", []);
	};
	plot.isEnabled = function(successCallback, failureCallback) {
		 cordova.exec(successCallback, failureCallback, "PlotCordovaPlugin", "isEnabled", []);
	};
	plot.setCooldownPeriod = function(cooldownSeconds, successCallback, failureCallback) {
		 cordova.exec(successCallback, failureCallback, "PlotCordovaPlugin", "setCooldownPeriod", [cooldownSeconds]);
	};
	plot.setEnableBackgroundModeWarning = function(enableWarning, successCallback, failureCallback) {
		 cordova.exec(successCallback, failureCallback, "PlotCordovaPlugin", "setEnableBackgroundModeWarning", [enableWarning]);
	};
	plot.getVersion = function(successCallback, failureCallback) {
		 cordova.exec(successCallback, failureCallback, "PlotCordovaPlugin", "getVersion", []);
	};
	module.exports = plot;
});

