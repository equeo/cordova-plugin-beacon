#import <Cordova/CDV.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// #import "LMLogger.h"

typedef CDVPluginResult* (^CDVPluginCommandHandler)(CDVInvokedUrlCommand*);

const double CDV_LOCATION_MANAGER_DOM_DELEGATE_TIMEOUT = 30.0;
const int CDV_LOCATION_MANAGER_INPUT_PARSE_ERROR = 100;

@interface BeaconPlugin : CDVPlugin<CLLocationManagerDelegate, CBPeripheralManagerDelegate> {

}

@property (retain) NSOperationQueue *queue;

@property (retain) CLLocationManager *locationManager;

@property (retain) NSString* delegateCallbackId;



@property (retain) CBPeripheralManager *peripheralManager;
@property (retain) CLRegion *advertisedBeaconRegion;
@property (retain) NSDictionary *advertisedPeripheralData;


/*
 *  onDomDelegateReady:
 *
 *  Discussion:
 *      Called from the DOM by the LocationManager Javascript object when it's delegate has been set.
 *      This is to notify the native layer that it can start sending queued up events, like didEnterRegion, 
 *      didDetermineState, etc.
 *
 *      Without this mechanism, the messages would get lost in background mode, because the native layer
 *      has no way of knowing when the consumer Javascript code will actually set it's delegate on the
 *      LocationManager of the DOM.
 */


- (void)isBluetoothEnabled:(CDVInvokedUrlCommand*)command;
- (void)enableBluetooth:(CDVInvokedUrlCommand*)command;
- (void)disableBluetooth:(CDVInvokedUrlCommand*)command;
- (void)startMonitoring:(CDVInvokedUrlCommand*)command;
- (void)startRanging:(CDVInvokedUrlCommand*)command;




@end
