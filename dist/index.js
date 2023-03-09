"use strict";

var Region = /** @class */ (function () {
  function Region(uniqueId, identifiers, typeName) {
    if (typeName === void 0) {
      typeName = "BeaconRegion";
    }
    var _this = this;
    this.uniqueId = uniqueId;
    this.identifiers = identifiers;
    this.typeName = typeName;
    this.startMonitoring = function (cb, success, error) {
      return window.cordova.exec(
        function (result) {
          console.log("Log Result:", result.message, "Type:", result.type);
          if (result.type === "meta") return success(result);
          return cb(result);
        },
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
    this.startRanging = function (cb, success, error) {
      return window.cordova.exec(
        function (result) {
          if (result.type === "meta") return success(result);
          return cb(result);
        },
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
