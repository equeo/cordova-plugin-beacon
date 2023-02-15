# cordova-plugin-beacon

This plugin provides beacon functionality to cordova apps.

## Installation

```bash
cordova plugin add github:equeo/cordova-plugin-beacon
```

## Usage

### Create a Region

```TypeScript
const uniqueId = "exampleregion";
const identifiers = ["15206424-43c4-4e5e-b446-9492d24fdec9"];
const region = new cordova.plugins.beacon.Region(uniqueId, identifiers);
```

### Start monitoring Region

```TypeScript
const onMonitoringEvent = (event: MonitoringEvent) => console.log(event);
const onStartMonitoringSuccess = (result: MetaResult) => console.log(result);
const onStartMonitoringError = (error: unknown) => console.error(error);
region.startMonitoring(onMonitoringEvent, onStartMonitoringSuccess, onStartMonitoringError);
```

### Stop monitoring Region

```TypeScript
const onStopMonitoringSuccess = (result: MetaResult) => console.log(result);
const onStopMonitoringError = (error: unknown) => console.error(error);
region.stopMonitoring(onStopMonitoringSuccess, onStopMonitoringError);
```

### Start ranging Region

```TypeScript
const onRangingEvent = (event: RangingEvent) => console.log(event);
const onStartRangingSuccess = (result: MetaResult) => console.log(result);
const onStartRangingError = (error: unknown) => console.error(error);
region.startRanging(onRangingEvent, onStartRangingSuccess, onStartRangingError);
```

### Stop ranging Region

```TypeScript
const onStopRangingSuccess = (result: MetaResult) => console.log(result);
const onStopRangingError = (error: unknown) => console.error(error);
region.stopRanging(onStopRangingSuccess, onStopRangingError);
```
