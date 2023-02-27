//
//  BeaconPlugin.swift
//  BeaconTest
//
//  Created by Zubair Hossain on 22.02.23.
//

import UIKit
import CoreLocation
import CoreBluetooth

@available(iOS 13.0, *)
@objc(BeaconPlugin) class BeaconPlugin : CDVPlugin, CLLocationManagerDelegate, CBPeripheralManagerDelegate {

    var locationManager: CLLocationManager?
    var peripheralManager: CBPeripheralManager?

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
            case .unknown:
                print("Bluetooth Device is UNKNOWN")
            case .unsupported:
                print("Bluetooth Device is UNSUPPORTED")
            case .unauthorized:
                print("Bluetooth Device is UNAUTHORIZED")
            case .resetting:
                print("Bluetooth Device is RESETTING")
            case .poweredOff:
                print("Bluetooth Device is POWERED OFF")
            case .poweredOn:
                print("Bluetooth Device is POWERED ON")
            @unknown default:
                print("Unknown State")
            }
    }

    override func pluginInitialize() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }

    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        print("[MyPlugin] - received a location update")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            print("[MyPlugin] - denied authorization")
            break

        case .authorizedWhenInUse:
            print("[MyPlugin] - received when in use authorization")
            break

        case .authorizedAlways:
            print("[MyPlugin] - received always usage authorization")
            print("[MyPlugin] - starting significant location change monitoring")

            locationManager?.startMonitoringSignificantLocationChanges();
            break

        case .notDetermined:
            print("[MyPlugin] - status not determined")
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[MyPlugin] - did fail with error was called")
    }

    @objc(startMonitoring:)
    func startMonitoring(_ command: CDVInvokedUrlCommand) {
        let data = command.arguments[0] as! NSDictionary;
        let uuid = UUID(uuidString: data["uniqueId"] as! String)!;

        let constraint = CLBeaconIdentityConstraint(uuid: uuid)
        // self.beaconConstraints[constraint] = []

        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: uuid.uuidString)
        self.locationManager?.startMonitoring(for: beaconRegion)

        // let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "addBeacon!")
        // self.commandDelegate.send(result, callbackId: command.callbackId)
    }

    // - Tag: didDetermineState
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        let beaconRegion = region as? CLBeaconRegion
        if state == .inside {
            // Start ranging when inside a region.
            manager.startRangingBeacons(satisfying: beaconRegion!.beaconIdentityConstraint)
        } else {
            // Stop ranging when not inside a region.
            manager.stopRangingBeacons(satisfying: beaconRegion!.beaconIdentityConstraint)
        }
    }


    /// - Tag: didRange
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        /*
         Beacons are categorized by proximity. A beacon can satisfy
         multiple constraints and can be displayed multiple times.
         */
        print("beacons", beacons)
    }
}
