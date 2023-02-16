"use strict";

var Region = /** @class */ (function () {
<<<<<<< HEAD
  function Region(uniqueId, identifier, minor, major) {
    var _this = this;
    this.uniqueId = uniqueId;
    this.typeName = "BeaconRegion";
    this.identifier = identifier;
    this.minor = minor;
    this.major = major;
    this.startMonitoring = function (success, error) {
      return window.cordova.exec(
        success,
        error,
        "BeaconPlugin",
        "startMonitoring",
        [_this]
      );
    };
    this.stopMonitoring = function (success, error) {
      return window.cordova.exec(
        success,
        error,
        "BeaconPlugin",
        "stopMonitoring",
        [_this]
      );
    };
    this.startRanging = function (success, error) {
      return window.cordova.exec(
        success,
        error,
        "BeaconPlugin",
        "startRanging",
        [_this]
      );
    };
    this.stopRanging = function (success, error) {
      return window.cordova.exec(
        success,
        error,
        "BeaconPlugin",
        "stopRanging",
        [_this]
      );
    };
  }
  return Region;
})();
=======
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
>>>>>>> 9727cc15196e430e7c22b424060602139af68970

exports.Region = Region;
