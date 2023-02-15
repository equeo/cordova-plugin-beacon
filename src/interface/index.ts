declare global {
  interface Window {
    cordova: {
      plugins: {
        beacon: {
          Region: Region;
        };
      };
      exec: <T, E>(
        success: (result: T) => void,
        errror: (error: E) => void,
        service: string,
        action: string,
        params: unknown[]
      ) => void;
    };
  }
}

interface Beacon {
  identifiers: string[];
}

interface MetaResult {
  type: "meta";
  message: unknown;
}

interface MonitoringResult {
  type: "monitor";
  message: Region;
}

interface RangingResult {
  type: "range";
  message: {
    beacons: Beacon[];
  } & Region;
}

type CordovaExecResult<T> = MetaResult | T;

class Region {
  constructor(
    public readonly uniqueId: string,
    public readonly identifiers: string[]
  ) {}

  startMonitoring = (
    cb: (event: MonitoringResult) => void,
    success: (result: MetaResult) => void,
    error: (error: unknown) => void
  ) =>
    window.cordova.exec(
      (result: CordovaExecResult<MonitoringResult>) => {
        if (result.type === "meta") return success(result);
        return cb(result as MonitoringResult);
      },
      error,
      "BeaconPlugin",
      "startMonitoring",
      [this]
    );
  stopMonitoring = (success: () => void, error: () => void) =>
    window.cordova.exec(success, error, "BeaconPlugin", "stopMonitoring", [
      this,
    ]);

  startRanging = (
    cb: (event: RangingResult) => void,
    success: (result: MetaResult) => void,
    error: (error: unknown) => void
  ) =>
    window.cordova.exec(
      (result: CordovaExecResult<RangingResult>) => {
        if (result.type === "meta") return success(result);
        return cb(result);
      },
      error,
      "BeaconPlugin",
      "startRanging",
      [this]
    );
  stopRanging = (success: () => void, error: () => void) =>
    window.cordova.exec(success, error, "BeaconPlugin", "stopRanging", [this]);
}

export { Region };
