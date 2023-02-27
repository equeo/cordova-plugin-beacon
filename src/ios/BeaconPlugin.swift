//
//  BeaconPlugin.swift
//  BeaconTest
//
//  Created by Zubair Hossain on 22.02.23.
//

import UIKit
import CoreLocation
import CoreBluetooth

let storedItemsKey = "storedItems"

@available(iOS 13.0, *)
@objc(BeaconPlugin) class BeaconPlugin : CDVPlugin, CLLocationManagerDelegate, CBPeripheralManagerDelegate {

    var locationManager: CLLocationManager?
    var peripheralManager: CBPeripheralManager?
    var beaconConstraints = [CLBeaconIdentityConstraint: [CLBeacon]]()
    var beacons = [CLProximity: [CLBeacon]]()

    override func pluginInitialize() {
        print("Init is fired!")
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            print("[BeaconPlugin] - denied authorization")
            break

        case .authorizedWhenInUse:
            print("[BeaconPlugin] - received when in use authorization")
            break

        case .authorizedAlways:
            print("[BeaconPlugin] - received always usage authorization")
            print("[BeaconPlugin] - starting significant location change monitoring")

            // locationManager.startMonitoringSignificantLocationChanges();
            break

        case .notDetermined:
            print("[BeaconPlugin] - status not determined")
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[BeaconPlugin] - did fail with error was called")
    }

    @objc(startMonitoring:)
    func startMonitoring(_ command: CDVInvokedUrlCommand) {
        let data = command.arguments[0] as! NSDictionary;
        let uuid = UUID(uuidString: data["uniqueId"] as! String)!;
        let constraint = CLBeaconIdentityConstraint(uuid: uuid)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: uuid.uuidString)
        self.locationManager?.startMonitoring(for: beaconRegion)
        let result = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }

    /// - Tag: didRange
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        print("beacons", beacons)
    }
}
