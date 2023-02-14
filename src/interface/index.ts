declare global {
  interface Window {
    cordova: {
      plugins: {
        beacon: {
          Region: Region;
        };
      };
    };
  }
}

class Region {
  constructor(
    public readonly identifier: string,
    public readonly uuid: string | null,
    public readonly minor?: string,
    public readonly major?: string
  ) {}

  startMonitoring = (
    cb: (event: unknown) => void,
    success: () => void,
    error: () => void
  ) => null;
  stopMonitoring = (success: () => void, error: () => void) => null;

  startRanging = (
    cb: (event: unknown) => void,
    success: () => void,
    error: () => void
  ) => null;
  stopRanging = (success: () => void, error: () => void) => null;
}

export { Region };
