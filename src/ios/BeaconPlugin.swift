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


    var items = [Item]()

    @objc(test:)
    func test(_ command: CDVInvokedUrlCommand) {

    }
    

    @objc(addBeacon:)
    func addBeacon(item: Item) {
    items.append(item)
    startMonitoringItem(item)
    persistItems()
  }
    
@objc(startScanning)
func startScanning() {
    print("Start Scanning is fired!!")
        let uuid = UUID(uuidString: "e2c56db5-dffb-5a00-0000-d0f5a71096e1")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 1, minor: 1000, identifier: "Equeo_Beacon")

        locationManager!.startMonitoring(for: beaconRegion)
        locationManager!.startRangingBeacons(in: beaconRegion)
    }

  func persistItems() {
    var itemsData = [Data]()
    for item in items {
      let itemData = NSKeyedArchiver.archivedData(withRootObject: item)
      itemsData.append(itemData)
    }
    UserDefaults.standard.set(itemsData, forKey: storedItemsKey)
    UserDefaults.standard.synchronize()
  }

  func startMonitoringItem(_ item: Item) {
    let beaconRegion = item.asBeaconRegion()
    locationManager!.startMonitoring(for: beaconRegion)
    locationManager!.startRangingBeacons(in: beaconRegion)
  }

    override func pluginInitialize() {
        print("Init is fired!")
        locationManager = CLLocationManager()
        locationManager!.requestWhenInUseAuthorization()
        peripheralManager = CBPeripheralManager()

        loadItems()
        startScanning()
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

            // locationManager.startMonitoringSignificantLocationChanges();
            break

        case .notDetermined:
            print("[MyPlugin] - status not determined")
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[MyPlugin] - did fail with error was called")
    }


    func loadItems() {
      guard let storedItems = UserDefaults.standard.array(forKey: storedItemsKey) as? [Data] else { return }
      for itemData in storedItems {
        guard let item = NSKeyedUnarchiver.unarchiveObject(with: itemData) as? Item else { continue }
        items.append(item)
          let result: () =  startMonitoringItem(item)
          startMonitoringItem(item)
          print("Start Monitoring result: ",result)
      }
    }

 

    func stopMonitoringItem(_ item: Item) {
      let beaconRegion = item.asBeaconRegion()
      locationManager!.stopMonitoring(for: beaconRegion)
      locationManager!.stopRangingBeacons(in: beaconRegion)
    }

}
