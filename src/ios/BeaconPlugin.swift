//
//  BeaconPlugin.swift
//  BeaconTest
//
//  Created by Zubair Hossain on 22.02.23.
//

import UIKit
import CoreLocation

let storedItemsKey = "storedItems"

@objc(BeaconPlugin) class BeaconPlugin: CDVPlugin, CLLocationManagerDelegate {

    var items = [Item]()
    var locationManager: CLLocationManager!
    

    override func pluginInitialize() {
        print("Inside Init")
        locationManager.delegate = self
        var authStatus = CLLocationManager.authorizationStatus()
        print("Auth Status", authStatus)
        locationManager.requestAlwaysAuthorization()
    }
    
   @objc(locationManager:) func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Auth Status", status)
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
   @objc(startScanning:) func startScanning() {
    
        print("Inside StartScanning")
        let uuid = UUID(uuidString: "e2c56db5-dffb-5a00-0000-d0f5a71096e1")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 1, minor: 1000, identifier: "Equeo_Beacon")

        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
        
    }
    
    @objc(locationManager:) func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            updateDistance(beacons[0].proximity)
        } else {
            updateDistance(.unknown)
        }
    }
    
   @objc(updateDistance:) func updateDistance(_ distance: CLProximity) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                print("Beacon distance is unknown")

            case .far:
                print("Beacon distance is far")
            case .near:
                print("Beacon distance is near")
            case .immediate:
                print("Beacon distance is immediate")
            @unknown default:
                print("Error in distance")
            }
        }
    }
    
    
//    func loadItems() {
//        print("Inside LoadItems")
//      guard let storedItems = UserDefaults.standard.array(forKey: storedItemsKey) as? [Data] else { return }
//      for itemData in storedItems {
//        guard let item = NSKeyedUnarchiver.unarchiveObject(with: itemData) as? Item else { continue }
//        items.append(item)
//         startMonitoringItem(item)
//      }
//    }
//    func startMonitoringItem(_ item: Item) {
//      let beaconRegion = item.asBeaconRegion()
//      locationManager.startMonitoring(for: beaconRegion)
//      locationManager.startRangingBeacons(in: beaconRegion)
//    }
//
//    func stopMonitoringItem(_ item: Item) {
//      let beaconRegion = item.asBeaconRegion()
//      locationManager.stopMonitoring(for: beaconRegion)
//      locationManager.stopRangingBeacons(in: beaconRegion)
//    }
}
