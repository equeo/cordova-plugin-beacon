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
declare class Region {
    readonly identifier: string;
    readonly uuid: string | null;
    readonly minor?: string | undefined;
    readonly major?: string | undefined;
    constructor(identifier: string, uuid: string | null, minor?: string | undefined, major?: string | undefined);
    startMonitoring: (cb: (event: unknown) => void, success: () => void, error: () => void) => null;
    stopMonitoring: (success: () => void, error: () => void) => null;
    startRanging: (cb: (event: unknown) => void, success: () => void, error: () => void) => null;
    stopRanging: (success: () => void, error: () => void) => null;
}
export { Region };
