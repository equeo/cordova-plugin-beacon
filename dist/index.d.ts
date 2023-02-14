declare global {
    interface Window {
        cordova: {
            plugins: {
                beacon: {
                    Region: Region;
                };
            };
            exec: <T, E>(success: (result: T) => void, errror: (error: E) => void, service: string, action: string, params: unknown[]) => void;
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
type RangingResult = MonitoringResult & {
    beacons: Beacon[];
};
declare class Region {
    readonly uniqueId: string;
    readonly identifier: string | null;
    readonly minor?: string | undefined;
    readonly major?: string | undefined;
    constructor(uniqueId: string, identifier: string | null, minor?: string | undefined, major?: string | undefined);
    startMonitoring: (success: (event?: MonitoringResult | null) => void, error: (error: unknown) => void) => void;
    stopMonitoring: (success: () => void, error: () => void) => void;
    startRanging: (success: (event?: RangingResult | null) => void, error: (error: unknown) => void) => void;
    stopRanging: (success: () => void, error: () => void) => void;
}
export { Region };
