//
//  BeaconPlugin.swift
//  BeaconTest
//
//  Created by Zubair Hossain on 22.02.23.
//

import UIKit
import CoreLocation

let storedItemsKey = "storedItems"

class BeaconPlugin: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items = [Item]()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      locationManager.delegate = self
      locationManager.requestAlwaysAuthorization()
      
      loadItems()
    }
    
    func loadItems() {
      guard let storedItems = UserDefaults.standard.array(forKey: storedItemsKey) as? [Data] else { return }
      for itemData in storedItems {
        guard let item = NSKeyedUnarchiver.unarchiveObject(with: itemData) as? Item else { continue }
        items.append(item)
          var result: () =  startMonitoringItem(item)
//        startMonitoringItem(item)
          
          print("Start Monitoring result: ",result)
      }
    }
    func startMonitoringItem(_ item: Item) {
      let beaconRegion = item.asBeaconRegion()
      locationManager.startMonitoring(for: beaconRegion)
      locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func stopMonitoringItem(_ item: Item) {
      let beaconRegion = item.asBeaconRegion()
      locationManager.stopMonitoring(for: beaconRegion)
      locationManager.stopRangingBeacons(in: beaconRegion)
    }
}
