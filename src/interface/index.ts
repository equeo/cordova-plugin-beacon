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

type RegionObject = Pick<
  Region,
  {
    [Key in keyof Region]: Region[Key] extends Function ? never : Key;
  }[keyof Region]
>;

interface Beacon {
  identifiers: string[];
}

interface MetaResult {
  type: "meta";
  message: unknown;
}

interface MonitoringEvent {
  type: "monitor";
  message: { state: 0 | 1 } & RegionObject;
}

interface RangingEvent {
  type: "range";
  message: {
    beacons: Beacon[];
  } & Omit<RegionObject, "identifiers">;
}

type CordovaExecResult<T> = MetaResult | T;

class Region {
  constructor(
    public readonly uniqueId: string,
    public readonly identifiers: string[],
    public readonly typeName: string = "BeaconRegion"
  ) {}

  startMonitoring = (
    cb: (event: MonitoringEvent) => void,
    success: (result: MetaResult) => void,
    error: (error: unknown) => void
  ) =>
    window.cordova.exec(
      (result: CordovaExecResult<MonitoringEvent>) => {
        if (result.type === "meta") return success(result);
        return cb(result as MonitoringEvent);
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
    cb: (event: RangingEvent) => void,
    success: (result: MetaResult) => void,
    error: (error: unknown) => void
  ) =>
    window.cordova.exec(
      (result: CordovaExecResult<RangingEvent>) => {
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
