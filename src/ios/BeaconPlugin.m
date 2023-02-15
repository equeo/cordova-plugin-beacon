#import "BeaconPlugin.h"

@implementation BeaconPlugin {

}

# pragma mark CDVPlugin

- (void)pluginInitialize
{
    [self initEventQueue];
    [self pauseEventPropagationToDom]; // Before the DOM is loaded we'll just keep collecting the events and fire them later.

    [self initLocationManager];
    [self initPeripheralManager];
    
    self.debugLogEnabled = true;
    self.debugNotificationsEnabled = false;
    
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    if (manager != self.locationManager) return;
    NSLog(@"didEnter Region");
    [self.queue addOperationWithBlock:^{
        
        [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
            
            
            
            NSMutableDictionary* dict = [NSMutableDictionary new];
            [dict setObject:[self jsCallbackNameForSelector:(_cmd)] forKey:@"eventType"];
            [dict setObject:[self mapOfRegion:region] forKey:@"region"];
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
            [pluginResult setKeepCallbackAsBool:YES];
            return pluginResult;

        } :nil :NO :self.delegateCallbackId];
    }];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {

    if (manager != self.locationManager) return;

    NSLog(@"didExitRegion");
    [self.queue addOperationWithBlock:^{
        
        [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
            
          
            
            NSMutableDictionary* dict = [NSMutableDictionary new];
            [dict setObject:[self jsCallbackNameForSelector:(_cmd)] forKey:@"eventType"];
            [dict setObject:[self mapOfRegion:region] forKey:@"region"];
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
            [pluginResult setKeepCallbackAsBool:YES];
            return pluginResult;
            
        } :nil :NO :self.delegateCallbackId];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {

    if (manager != self.locationManager) return;
    NSLog(@"didStartMonitoringForRegion");

    [self.queue addOperationWithBlock:^{
        
        [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
            
            
            
            NSMutableDictionary* dict = [NSMutableDictionary new];
            [dict setObject:[self jsCallbackNameForSelector :_cmd] forKey:@"eventType"];
            [dict setObject:[self mapOfRegion:region] forKey:@"region"];
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
            [pluginResult setKeepCallbackAsBool:YES];
            return pluginResult;
            
        } :nil :NO :self.delegateCallbackId];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    if (manager != self.locationManager) return;
    NSLog(@"didRangeBeacons");

    NSMutableArray* beaconsMapsArray = [NSMutableArray new];
    for (CLBeacon* beacon in beacons) {
        NSDictionary* dictOfBeacon = [self mapOfBeacon:beacon];
        [beaconsMapsArray addObject:dictOfBeacon];
    }
    
    [self.queue addOperationWithBlock:^{
        
        [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
            
            
            
            NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
            [dict setObject:[self jsCallbackNameForSelector :_cmd] forKey:@"eventType"];
            [dict setObject:[self mapOfRegion:region] forKey:@"region"];
            [dict setObject:beaconsMapsArray forKey:@"beacons"];
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
            [pluginResult setKeepCallbackAsBool:YES];
            return pluginResult;
            
        } :nil :NO :self.delegateCallbackId];
    }];
}