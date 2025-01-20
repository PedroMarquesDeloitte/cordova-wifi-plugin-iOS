var exec = require('cordova/exec');

exports.connectToWifi = function (ssid, password, success, error) {
    exec(success, error, 'WifiConnectPlugin', 'connectToWifi', [ssid, password]);
};

exports.checkWifi = function (ssid, success, error) {
    exec(success, error, 'WifiConnectPlugin', 'getWiFiSSID', ssid);
};