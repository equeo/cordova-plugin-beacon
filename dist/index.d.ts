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
type RegionObject = Pick<Region, {
    [Key in keyof Region]: Region[Key] extends Function ? never : Key;
}[keyof Region]>;
interface Beacon {
    identifiers: string[];
}
interface MetaResult {
    type: "meta";
    message: unknown;
}
interface MonitoringEvent {
    type: "monitor";
    message: {
        state: 0 | 1;
    } & RegionObject;
}
interface RangingEvent {
    type: "range";
    message: {
        beacons: Beacon[];
    } & Omit<RegionObject, "identifiers">;
}
declare class Region {
    readonly uniqueId: string;
    readonly identifiers: string[];
    constructor(uniqueId: string, identifiers: string[]);
    startMonitoring: (cb: (event: MonitoringEvent) => void, success: (result: MetaResult) => void, error: (error: unknown) => void) => void;
    stopMonitoring: (success: () => void, error: () => void) => void;
    startRanging: (cb: (event: RangingEvent) => void, success: (result: MetaResult) => void, error: (error: unknown) => void) => void;
    stopRanging: (success: () => void, error: () => void) => void;
}
export { Region };
