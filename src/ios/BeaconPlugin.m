#import "BeaconPlugin.h"

@implementation BeaconPlugin {
    
}

# pragma mark CDVPlugin

- (void)pluginInitialize
{
    [self initEventQueue];
    [self pauseEventPropagationToDom]; // Before the DOM is loaded we'll just keep collecting the events and fire them later.
    [self initLocationManager];
    
}

- (void) initEventQueue {
    
    self.queue = [NSOperationQueue new];
    self.queue.maxConcurrentOperationCount = 1; // Don't hit the DOM too hard.
    
    
}
- (void) pauseEventPropagationToDom {
    [self checkEventQueue];
    [self.queue setSuspended:YES];
}

- (void) initLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}
- (void) checkEventQueue {
    if (self.queue != nil) {
        return;
    }
    self.queue = [NSOperationQueue new];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLCircularRegion *)region {
    
    if (manager != self.locationManager) return;
    [self.queue addOperationWithBlock:^{
        
        [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
            
            
            NSMutableDictionary* dict = [NSMutableDictionary new];
            [dict setObject:[self jsCallbackNameForSelector:(_cmd)] forKey:@"eventType"];
           
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
            [pluginResult setKeepCallbackAsBool:YES];
            return pluginResult;

        } :nil :NO :self.delegateCallbackId];
    }];
}


- (void)isBluetoothEnabled: (CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
        
        //this should be sufficient - otherwise will need to add a centralmanager reference
        BOOL isEnabled = self->_peripheralManager.state == CBManagerStatePoweredOn;
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isEnabled];
        [result setKeepCallbackAsBool:YES];
        NSLog( @"isBluetoothEnabled '%@'", result );
        return result;
        
    } :command];
}

- (void)enableBluetooth: (CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [result setKeepCallbackAsBool:YES];
        NSLog( @"enableBluetooth '%@'", result );
        return result;
        
    } :command];
}

- (void)disableBluetooth: (CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [result setKeepCallbackAsBool:YES];
        return result;
        
    } :command];
}

- (void)startMonitoring:(CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
        
        NSError* error;
        CLRegion* region = [self parseRegion:command returningError:&error];
        if (region == nil) {
            if (error != nil) {
                
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:error.userInfo];
            } else {
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unknown error."];
            }
        } else {
            [self->_locationManager startMonitoringForRegion:region];
            
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [result setKeepCallbackAsBool:YES];
            NSLog( @"startMonitoring '%@'", result );
            return result;
        }
    } :command];
}

- (void)startRanging:(CDVInvokedUrlCommand*)command {
    [self _handleCallSafely:^CDVPluginResult *(CDVInvokedUrlCommand *command) {
        
        NSError* error;
        CLRegion* region = [self parseRegion:command returningError:&error];
        if (region == nil) {
            if (error != nil) {
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:error.userInfo];
            } else {
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unknown error."];
            }
        } else {
            NSString *uuidString = @"e2c56db5-dffb-5a00-0000-d0f5a71096e1";
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
            CLBeaconIdentityConstraint *beaconIdentityConstraint = [[CLBeaconIdentityConstraint alloc] initWithUUID:uuid];
            
            [self->_locationManager startRangingBeaconsSatisfyingConstraint:beaconIdentityConstraint];
            
            
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [result setKeepCallbackAsBool:YES];
            NSLog( @"startRanging '%@'", result );
            return result;
        }
    } :command];
}





#pragma mark Parsing

- (CLRegion*) parseRegion:(CDVInvokedUrlCommand*) command returningError:(out NSError **)error {
    
    NSDictionary* dict = command.arguments[0];
    NSLog(@"Dict %@",dict);
    NSString* typeName = [dict objectForKey:@"typeName"];
    if (typeName == nil) {
        *error = [self parseErrorWithDescription:@"'typeName' is missing, cannot parse CLRegion."];
        return nil;
    }
    
    NSString* identifier = [dict objectForKey:@"identifier"];
    if (identifier == nil) {
        *error = [self parseErrorWithDescription:@"'identifier' is missing, cannot parse CLRegion."];
        return nil;
    }
  
    if ([typeName isEqualToString:@"BeaconRegion"]) {
        return [self parseBeaconRegionFromMap:dict andIdentifier:identifier returningError:error];
    } else {
        NSString* description = [NSString stringWithFormat:@"unsupported CLRegion subclass: %@", typeName];
        *error = [self parseErrorWithDescription: description];
        return nil;
    }
}
- (CLBeaconRegion*) parseBeaconRegionFromMap:(NSDictionary*) dict andIdentifier:(NSString*) identifier returningError:(out NSError **)error {
    CLBeaconRegion *region;
    if ([self isBelowIos7]) {
        *error = [self parseErrorWithDescription:@"CLBeaconRegion only supported on iOS 7 and above."];
        return nil;
    }
    NSString *uuidString = [dict objectForKey:@"uniqueId"];
    if (uuidString == nil) {
        *error = [self parseErrorWithDescription:@"'uuid' is missing, cannot parse CLBeaconRegion."];
        return nil;
    }
    if (uuidString != nil) {
        NSLog(@"'uuidString' is %@ ", uuidString);
    }
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    if (uuid == nil) {
        NSString* description = [NSString stringWithFormat:@"'uuid' %@ is not a valid UUID. Cannot parse CLBeaconRegion.", uuidString];
        *error = [self parseErrorWithDescription:description];
        return nil;
    } else {
        NSLog(@"'uuid' is %@ ", uuid);
    }
    
    NSNumber *major = [dict objectForKey:@"major"];
    NSNumber *minor = [dict objectForKey:@"minor"];
    
    if (major == nil && minor == nil) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];
    } else if (major != nil && minor == nil){
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:[major doubleValue] identifier:identifier];
    } else if (major != nil && minor != nil) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:[major doubleValue] minor:[minor doubleValue] identifier:identifier];
    } else {
        *error = [self parseErrorWithDescription:@"Unsupported combination of 'major' and 'minor' parameters."];
        return nil;
    }

    NSNumber *notifyFlag = [dict objectForKey:@"notifyEntryStateOnDisplay"];
    
    if (notifyFlag != nil) {
        BOOL notify = [notifyFlag boolValue];
        region.notifyEntryStateOnDisplay = notify;
        NSString *notifyValue = notify ? @"Yes" : @"No";
        NSLog(@"using notifyEntryStateOnDisplay BOOL for this region with value %@.", notifyValue);
    }
    
    if (region == nil) {
        *error = [self parseErrorWithDescription:@"CLBeaconRegion parsing failed for unknown reason."];
    }
    return region;
}


#pragma mark Utilities

- (NSError*) parseErrorWithDescription:(NSString*) description {
    return [self errorWithCode:CDV_LOCATION_MANAGER_INPUT_PARSE_ERROR andDescription:description];
}

- (NSError*) errorWithCode: (int)code andDescription:(NSString*) description {

    NSMutableDictionary* details;
    if (description != nil) {
        details = [NSMutableDictionary dictionary];
        [details setValue:description forKey:NSLocalizedDescriptionKey];
       
    }
    
    return [[NSError alloc] initWithDomain:@"CDVLocationManager" code:code userInfo:details];
}

- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral {
    
}
- (BOOL) isBelowIos7 {
    return [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0;
}
- (void) _handleCallSafely: (CDVPluginCommandHandler) unsafeHandler : (CDVInvokedUrlCommand*) command  {
    [self _handleCallSafely:unsafeHandler :command :true];
}

- (void) _handleCallSafely: (CDVPluginCommandHandler) unsafeHandler : (CDVInvokedUrlCommand*) command : (BOOL) runInBackground :(NSString*) callbackId {
    if (runInBackground) {
        [self.commandDelegate runInBackground:^{
            @try {
                [self.commandDelegate sendPluginResult:unsafeHandler(command) callbackId:callbackId];
            }
            @catch (NSException * exception) {
                [self _handleExceptionOfCommand:command :exception];
            }
        }];
    } else {
        @try {
            [self.commandDelegate sendPluginResult:unsafeHandler(command) callbackId:callbackId];
        }
        @catch (NSException * exception) {
            [self _handleExceptionOfCommand:command :exception];
        }
    }
}

- (void) _handleCallSafely: (CDVPluginCommandHandler) unsafeHandler : (CDVInvokedUrlCommand*) command : (BOOL) runInBackground {
    [self _handleCallSafely:unsafeHandler :command :true :command.callbackId];
    
}
- (void) _handleExceptionOfCommand: (CDVInvokedUrlCommand*) command : (NSException*) exception {
    NSLog(@"Uncaught exception: %@", exception.description);
    NSLog(@"Stack trace: %@", [exception callStackSymbols]);

    // When calling without a request (LocationManagerDelegate callbacks) from the client side the command can be null.
    if (command == nil) {
        return;
    }
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.description];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSString*) jsCallbackNameForSelector: (SEL) selector {
    NSString* fullName = NSStringFromSelector(selector);
    
    NSString* shortName = [fullName stringByReplacingOccurrencesOfString:@"locationManager:" withString:@""];
    shortName = [shortName stringByReplacingOccurrencesOfString:@":error:" withString:@""];

    NSRange range = [shortName rangeOfString:@":"];
    
    while(range.location != NSNotFound) {
        shortName = [shortName stringByReplacingCharactersInRange:range withString:@""];
        if (range.location < shortName.length) {
            NSString* upperCaseLetter = [[shortName substringWithRange:range] uppercaseString];
            shortName = [shortName stringByReplacingCharactersInRange:range withString:upperCaseLetter];
        }

        range = [shortName rangeOfString:@":"];
    };
    
    
    return shortName;
}




@end

