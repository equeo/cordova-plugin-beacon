'use strict';

var Region = /** @class */ (function () {
    function Region(uniqueId, identifiers) {
        var _this = this;
        this.uniqueId = uniqueId;
        this.identifiers = identifiers;
        this.startMonitoring = function (cb, success, error) {
            return window.cordova.exec(function (result) {
                if (result.type === "meta")
                    return success(result);
                return cb(result);
            }, error, "BeaconPlugin", "startMonitoring", [_this]);
        };
        this.stopMonitoring = function (success, error) {
            return window.cordova.exec(success, error, "BeaconPlugin", "stopMonitoring", [
                _this,
            ]);
        };
        this.startRanging = function (cb, success, error) {
            return window.cordova.exec(function (result) {
                if (result.type === "meta")
                    return success(result);
                return cb(result);
            }, error, "BeaconPlugin", "startRanging", [_this]);
        };
        this.stopRanging = function (success, error) {
            return window.cordova.exec(success, error, "BeaconPlugin", "stopRanging", [_this]);
        };
    }
    return Region;
}());

exports.Region = Region;
