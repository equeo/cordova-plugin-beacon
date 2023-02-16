"use strict";

var Region = /** @class */ (function () {
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

exports.Region = Region;
