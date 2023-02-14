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

interface MonitoringResult {
  readonly uniqueId: string;
  readonly identifier: string | null;
  readonly minor?: string;
  readonly major?: string;
}

type RangingResult = MonitoringResult & { beacons: Beacon[] };

class Region {
  constructor(
    public readonly uniqueId: string,
    public readonly identifier: string | null,
    public readonly minor?: string,
    public readonly major?: string
  ) {}

  startMonitoring = (
    success: (event?: MonitoringResult | null) => void,
    error: (error: unknown) => void
  ) =>
    window.cordova.exec(success, error, "BeaconPlugin", "startMonitoring", [
      this,
    ]);
  stopMonitoring = (success: () => void, error: () => void) =>
    window.cordova.exec(success, error, "BeaconPlugin", "stopMonitoring", [
      this,
    ]);

  startRanging = (
    success: (event?: RangingResult | null) => void,
    error: (error: unknown) => void
  ) =>
    window.cordova.exec(success, error, "BeaconPlugin", "startRanging", [this]);
  stopRanging = (success: () => void, error: () => void) =>
    window.cordova.exec(success, error, "BeaconPlugin", "stopRanging", [this]);
}

export { Region };
