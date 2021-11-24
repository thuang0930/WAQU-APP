//
//  ViewController.swift
//  WAQU
//
//  Created by Ting-Kai Huang on 9/11/21.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var waqu: CBPeripheral?
    
    let serviceUUID = CBUUID(string: "180A")
    let waquCharacteristicUUID = CBUUID(string: "FFF0")
    @IBOutlet weak var tempLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager()
        centralManager.delegate = self
    }
    
    //MARK: - Central manager delegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber){
        centralManager.stopScan()
        waqu = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    //MARK: - Peripheral delegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let service = peripheral.services?.first(where: { $0.uuid == serviceUUID}){
            peripheral.discoverCharacteristics([waquCharacteristicUUID], for: service)
        }
    }
    
    func  peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristic = service.characteristics?.first(where: { $0.uuid == waquCharacteristicUUID}) {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            let weight: Int = data.withUnsafeBytes{ $0.pointee }
            tempLabel.text = String(weight) + " g"
        }
    }
}
