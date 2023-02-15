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
declare class Region {
    readonly uniqueId: string;
    readonly identifiers: string[];
    constructor(uniqueId: string, identifiers: string[]);
    startMonitoring: (cb: (event: MonitoringResult) => void, success: (result: MetaResult) => void, error: (error: unknown) => void) => void;
    stopMonitoring: (success: () => void, error: () => void) => void;
    startRanging: (cb: (event: RangingResult) => void, success: (result: MetaResult) => void, error: (error: unknown) => void) => void;
    stopRanging: (success: () => void, error: () => void) => void;
}
export { Region };
