'use strict';

var Region = /** @class */ (function () {
    function Region(identifier, uuid, minor, major) {
        this.identifier = identifier;
        this.uuid = uuid;
        this.minor = minor;
        this.major = major;
        this.startMonitoring = function (cb, success, error) { return null; };
        this.stopMonitoring = function (success, error) { return null; };
        this.startRanging = function (cb, success, error) { return null; };
        this.stopRanging = function (success, error) { return null; };
    }
    return Region;
}());

exports.Region = Region;
