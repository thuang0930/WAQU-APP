//
//  BLEManager.swift
//  WAQU
//
//  Created by Ting-Kai Huang on 9/18/21.
//

import SwiftUICharts
import Foundation
import CoreBluetooth
import UserNotifications
import SwiftUI

struct Peripheral: Identifiable {
    let id: Int
    let name: String
    let rssi: Int
}


class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    var myCentral: CBCentralManager!
    var myPeripheral: CBPeripheral!
    var cTemperature: CBCharacteristic!
    var cTemperature2: CBCharacteristic!
    var cHumidity: CBCharacteristic!
    var cHumidity2: CBCharacteristic!
    var cCO2: CBCharacteristic!
    var cCO22: CBCharacteristic!
    var cPM25: CBCharacteristic!
    var cPM252: CBCharacteristic!
    var setTime: String = "1"
    var hour: String = ""
    var minute: String = ""
    var limit: Int = 0
    var limit_co2: Int = 0
    var limit_pm25: Int = 0
    var battery_alert_limit: Int = 0
    var humidity_array: [Double] = []
    var co2_array: [Double] = []
    var pm25_array: [Double] = []
    struct Constants {
        static var temph = ""
        static var templ = ""
        static var co2l = ""
        static var co2h = ""
        static var humidityh = ""
        static var humidityl = ""
        static var pm25l = ""
        static var pm25h = ""
        //static var tempInt = 32
        //static var co2Int = 32
        //static var humidityInt = 32
        //static var pm25Int = 32
    }
    @Published var tempInt: Double = 32
    @Published var co2Int: Double = 32
    @Published var humidityInt: Double = 32
    @Published var pm25Int: Double = 32
    @Published var tempRound = ""
    @Published var co2Round = ""
    @Published var humidityRound = ""
    @Published var pm25Round = ""
    @Published var tempC: Double = 32
    @Published var tempCRound = ""

    
    //@Published var tempPoints: [Double] = []
    //@Published var co2Points: [Double] = []
    //@Published var humidityPoints: [Double] = []
    //@Published var pm25Points: [Double] = [0,0,0,0,0]
    // Legend
    let pm25 = Legend(color: .purple, label: "PM2.5")
    let temp = Legend(color: .yellow, label: "Temp")
    let co2 = Legend(color: .red, label: "CO2")
    let humidity = Legend(color: .gray, label: "Humidity")
    // DataPoint
    @Published var pm25Points: [DataPoint] = []
    @Published var tempPoints: [DataPoint] = []
    @Published var co2Points: [DataPoint] = []
    @Published var humidityPoints: [DataPoint] = []
   
    /*
    @Published var points: [DataPoint] = [
        //.init(value: 1, label: "1", legend: pm25),
        
        .init(value: pm25Points[0], label: "\(pm25Points[0])", legend: pm25),
        
        .init(value: pm25Points[1], label: "\(pm25Points[1])", legend: pm25),
        .init(value: pm25Points[2], label: "\(pm25Points[2])", legend: pm25),
        .init(value: pm25Points[3], label: "\(pm25Points[3])", legend: pm25),
        .init(value: pm25Points[4], label: "\(pm25Points[4])", legend: pm25),
         
    ]
     */

    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    
    
    override init(){
        super.init()
        
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }
    
    func pm25PostNotification(){
        let setTimeDouble = (setTime as NSString).doubleValue //string to double
        let content = UNMutableNotificationContent()
        if pm25Int <= 150 && pm25Int >= 101 {
            content.title = "Warning: High PM2.5 Level"
            content.body = "The PM2.5 level is \(pm25Int)! The air quality in this area is unhealthy and dangerous for sensitive groups! Please leave this area!"
        }
        else if pm25Int <= 200 && pm25Int > 150 {
            content.title = "Warning: Dangerous PM2.5 Level"
            content.body = "Caution! The PM2.5 level is \(pm25Int)! The air quality in this area is extremely unhealthy! Please leave this area immediately!"
        }
        else {
            return
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: setTimeDouble, repeats: false)
        let id = "reminder-\(UUID())"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    
    func co2PostNotification(){
        let setTimeDouble = (setTime as NSString).doubleValue //string to double
        let content = UNMutableNotificationContent()
        if co2Int <= 2000 && co2Int >= 1000 {
            content.title = "Warning: High CO2 Levels"
            content.body = "The CO2 level is \(co2Int) ppm! This level of CO2 indicates poor air quality. Please be aware of how your body reacts and move to a safer area if possible."
        }
        else if co2Int <= 5000 && co2Int > 2000 {
            content.title = "Warning: Dangerous CO2 Levels"
            content.body = "Caution! The CO2 level is \(co2Int) ppm! This level of CO2 can cause headaches, loss of attention, and an increased heartrate! Please leave this area as soon as possible!"
        }
        else if co2Int > 5000 {
            content.title = "Warning: Toxic CO2 Levels"
            content.body = "CAUTION! PLEASE LEAVE THIS AREA IMMEDIATELY!!! Oxygen deprivation could occur!"
        }
        else {
            return
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: setTimeDouble, repeats: false)
        let id = "reminder-\(UUID())"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    
    func batteryNotification(){
        let setTimeDouble = (setTime as NSString).doubleValue //string to double
        let content = UNMutableNotificationContent()
        content.title = "Low Battery Warning"
        content.body = "The battery is running low! Please replace the battery!"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: setTimeDouble, repeats: false)
        let id = "reminder-\(UUID())"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    /*
    func dailyWeatherReport() {
        //let setTimeDouble = (setTime as NSString).doubleValue //string to double
        var dateComponents = DateComponents()
        dateComponents.hour = Int(hour)
        dateComponents.minute = Int(minute)
        let content = UNMutableNotificationContent()
        content.title = "Daily Weather Report"
        content.body = "The temperature is \(tempRound)°F/\(tempCRound)°C. The humidity is \(humidityInt)%. The CO2 level is \(co2Int)ppm. The PM2.5 level is \(pm25Int). "
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let id = "reminder-\(UUID())"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    */
    func dailyWeatherReport() {
        let setTimeDouble = (setTime as NSString).doubleValue //string to double
        let content = UNMutableNotificationContent()
        content.title = "Daily Weather Report"
        content.body = "The temperature is \(tempRound)°F/\(tempCRound)°C. The humidity is \(humidityInt)%. The CO2 level is \(co2Int)ppm. The PM2.5 level is \(pm25Int). "
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: setTimeDouble, repeats: false)
        let id = "reminder-\(UUID())"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
        }
        else {
            isSwitchedOn = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //var peripheralName: String!
        
        if let pname = peripheral.name {
            if  pname == "WAQU"  {
                self.myCentral.stopScan()
                
                self.myPeripheral = peripheral
                self.myPeripheral.delegate = self
                
                self.myCentral.connect(peripheral, options: nil)
            }
        }
        /*
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else{
            peripheralName = "Unknown"
        }
        
        let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue)
        print(newPeripheral)
        peripherals.append(newPeripheral)
        */
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.myPeripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let peripheralServices = peripheral.services  {
            //print("list of services")
            for service in peripheralServices {
                //print(service.uuid)
                //print(service.uuid.uuidString)
                
                if service.uuid == CBUUID(string: "BABE"){
                    self.myPeripheral.discoverCharacteristics(nil, for: service)
                }
                else if service.uuid == CBUUID(string: "FFF0"){
                    self.myPeripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let serviceCharacteristics = service.characteristics {
            //print("list of characteristics")
            for characteristic in serviceCharacteristics {
                //print(characteristic)
                if characteristic.uuid == CBUUID(string: "0000FFF1-0000-1000-8000-00805F9B34FB"){ //0000FFF1-0000-1000-8000-00805F9B34FB
                    self.cTemperature = characteristic
                    //self.myPeripheral.readValue(for: cTemperature)
                    self.myPeripheral.setNotifyValue(true, for: cTemperature)
                }
                else if characteristic.uuid == CBUUID(string: "0000FFF2-0000-1000-8000-00805F9B34FB"){
                    self.cHumidity = characteristic
                    //self.myPeripheral.readValue(for: cHumidity)
                    self.myPeripheral.setNotifyValue(true, for: cHumidity)
                }
                else if characteristic.uuid == CBUUID(string: "0000FFF3-0000-1000-8000-00805F9B34FB"){
                    self.cCO2 = characteristic
                    //self.myPeripheral.readValue(for: cCO2)
                    self.myPeripheral.setNotifyValue(true, for: cCO2)
                }
                else if characteristic.uuid == CBUUID(string: "0000FFF4-0000-1000-8000-00805F9B34FB"){
                    self.cPM25 = characteristic
                    //self.myPeripheral.readValue(for: cPM25)
                    self.myPeripheral.setNotifyValue(true, for: cPM25)
                }
//                else if characteristic.uuid == CBUUID(string: "0000FFF5-0000-1000-8000-00805F9B34FB"){ //0000FFF1-0000-1000-8000-00805F9B34FB
//                    self.cTemperature2 = characteristic
//                    //self.myPeripheral.readValue(for: cTemperature)
//                    self.myPeripheral.setNotifyValue(true, for: cTemperature2)
//                }
//                else if characteristic.uuid == CBUUID(string: "0000FFF6-0000-1000-8000-00805F9B34FB"){ //0000FFF1-0000-1000-8000-00805F9B34FB
//                    self.cHumidity2 = characteristic
//                    //self.myPeripheral.readValue(for: cTemperature)
//                    self.myPeripheral.setNotifyValue(true, for: cHumidity2)
//                }
                else if characteristic.uuid == CBUUID(string: "0000FFF5-0000-1000-8000-00805F9B34FB"){ //0000FFF1-0000-1000-8000-00805F9B34FB
                    self.cCO22 = characteristic
                    //self.myPeripheral.readValue(for: cTemperature)
                    self.myPeripheral.setNotifyValue(true, for: cCO22)
                }
                else if characteristic.uuid == CBUUID(string: "0000FFF6-0000-1000-8000-00805F9B34FB"){ //0000FFF1-0000-1000-8000-00805F9B34FB
                    self.cPM252 = characteristic
                    //self.myPeripheral.readValue(for: cTemperature)
                    self.myPeripheral.setNotifyValue(true, for: cPM252)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let date = Date()
        let components = Calendar.current.dateComponents([.hour,.minute], from: date)
        if Int(hour) == components.hour && Int(minute) == components.minute && limit < 1{
            self.dailyWeatherReport()
            limit += 1
        }
        if Int(hour) == components.hour && Int(minute) != components.minute{
            limit = 0
        }
        //print(hour + " " + minute)
        /*
        if characteristic.uuid == cTemperature2.uuid {
            if let data = characteristic.value {
                print("Temperature Measurement")
                Constants.temph = data.map { String(format: "%02x", $0)}.joined()
                print(Constants.temph)
                /*
                let hexToDecimalTemp = Int(Constants.temph, radix: 16)!
                tempInt = Double(hexToDecimalTemp)// convert to Int here first
                tempRound = String(format: "%.0f",tempInt)
                tempC = (tempInt-32)*5/9
                tempCRound = String(format: "%.0f",tempC)
                //ContentView.SensorReadings.temp = tempInt
                print(tempInt)
                if tempPoints.count < 10 {
                    
                    tempPoints.append(.init(value: tempInt, label: "\(tempRound)°F", legend: temp))
                }
                else {
                    tempPoints.removeFirst()
                    tempPoints.append(.init(value: tempInt, label: "\(tempRound)°F", legend: temp))
                }
                 */
            }
        }
         */
       if characteristic.uuid == cTemperature.uuid {
            if let data = characteristic.value {
                Constants.templ = data.map { String(format: "%02x", $0)}.joined()
                let hexToDecimalTemp = Int(Constants.templ, radix: 16)!
                print(hexToDecimalTemp)
                tempInt = Double(hexToDecimalTemp)// convert to Int here first
                tempRound = String(format: "%.0f",tempInt)
                tempC = (tempInt-32)*5/9
                tempCRound = String(format: "%.0f",tempC)
                //ContentView.SensorReadings.temp = tempInt
                print(tempInt)
                if tempPoints.count < 10 {
                    
                    tempPoints.append(.init(value: tempInt, label: "\(tempRound)°F", legend: temp))
                }
                else {
                    tempPoints.removeFirst()
                    tempPoints.append(.init(value: tempInt, label: "\(tempRound)°F", legend: temp))
                }
            }
        }
        else if characteristic.uuid == cHumidity.uuid {
            if let data = characteristic.value {
                print("Humidity Measurement")
                Constants.humidityl = data.map { String(format: "%02x", $0)}.joined()
                print(Constants.humidityl)
                let hexToDecimalHumidity = Int(Constants.humidityl, radix: 16)!
                humidityInt = Double(hexToDecimalHumidity)
                if humidity_array.count < 10 {
                    humidity_array.append(humidityInt)
                }
                else {
                    humidity_array.removeFirst()
                    humidity_array.append(humidityInt)
                }
                var array_sum = 0.0
                for i in humidity_array {
                    array_sum = i + array_sum
                }
                let humidity_avg = array_sum / Double(humidity_array.count)
                humidityRound = String(format: "%.0f",humidity_avg)
                //ContentView.SensorReadings.humidity = humidityInt
                print(humidityInt)
                if humidityPoints.count < 10 {

                    humidityPoints.append(.init(value: humidityInt, label: "\(humidityRound)%", legend: humidity))
                }
                else {
                    humidityPoints.removeFirst()
                    humidityPoints.append(.init(value: humidityInt, label: "\(humidityRound)%", legend: humidity))
                }
            }
        }
        /*
        else if characteristic.uuid == cHumidity2.uuid {
            if let data = characteristic.value {
                print("Humidity Measurement")
                Constants.humidityh = data.map { String(format: "%02x", $0)}.joined()
                print(Constants.humidityh)
                let hexToDecimalHumidity = Int(Constants.humidityh + Constants.humidityl, radix: 16)!
                print(hexToDecimalHumidity)
                humidityInt = Double(hexToDecimalHumidity)
                if humidity_array.count < 10 {
                    humidity_array.append(humidityInt)
                }
                else {
                    humidity_array.removeFirst()
                    humidity_array.append(humidityInt)
                }
                var array_sum = 0.0
                for i in humidity_array {
                    array_sum = i + array_sum
                }
                let humidity_avg = array_sum / Double(humidity_array.count)
                //humidityInt = (Double(hexToDecimalHumidity)/1000) * 45.7143 - 22.8571
                humidityRound = String(format: "%.0f",humidity_avg)
                //ContentView.SensorReadings.humidity = humidityInt
                print(humidityInt)
                if humidityPoints.count < 10 {
                    humidityPoints.append(.init(value: humidityInt, label: "\(humidityRound)%", legend: humidity))
                }
                else {
                    humidityPoints.removeFirst()
                    humidityPoints.append(.init(value: humidityInt, label: "\(humidityRound)%", legend: humidity))
                }
            }
        }
         */
        else if characteristic.uuid == cCO2.uuid {
            if let data = characteristic.value {
                print("CO2 Measurement")
                Constants.co2l = data.map { String(format: "%02x", $0)}.joined()
                print(Constants.co2l)
                /*
                let hexToDecimalCo2 = Int(Constants.co2, radix: 16)!
                co2Int = Double(hexToDecimalCo2)
                co2Round = String(format: "%.0f",co2Int)
                //ContentView.SensorReadings.co2 = co2Int
                print(co2Int)
                if co2Points.count < 10 {
                    
                    co2Points.append(.init(value: co2Int, label: "\(co2Round)ppm", legend: co2))
                }
                else {
                    co2Points.removeFirst()
                    co2Points.append(.init(value: co2Int, label: "\(co2Round)ppm", legend: co2))
                }
                 
                self.co2PostNotification()
                 */
            }
        }
        else if characteristic.uuid == cCO22.uuid {
            if let data = characteristic.value {
                print("CO2 Measurement")
                Constants.co2h = data.map { String(format: "%02x", $0)}.joined()
                print(Constants.co2h)
                let hexToDecimalCo2 = Int(Constants.co2h + Constants.co2l, radix: 16)!
                co2Int = Double(hexToDecimalCo2)
                if co2_array.count < 10 {
                    co2_array.append(co2Int)
                }
                else {
                    co2_array.removeFirst()
                    co2_array.append(co2Int)
                }
                var array_sum = 0.0
                for i in co2_array {
                    array_sum = i + array_sum
                }
                let co2_avg = array_sum / Double(co2_array.count)
                if co2_avg < 2000 {
                    limit_co2 = 0
                }
                if co2_avg < 4500 {
                    battery_alert_limit = 0
                }
                co2Round = String(format: "%.0f",co2_avg)
                //ContentView.SensorReadings.co2 = co2Int
                print(co2Int)
                if co2Points.count < 10 {
                    co2Points.append(.init(value: co2Int, label: "\(co2Round)ppm", legend: co2))
                }
                else {
                    co2Points.removeFirst()
                    co2Points.append(.init(value: co2Int, label: "\(co2Round)ppm", legend: co2))
                }
                if co2_avg >= 2000 {
                    if limit_co2 == 0{
                        self.co2PostNotification()
                        limit_co2 += 1
                    }
                }
                if co2_avg >= 4500 {
                    if battery_alert_limit == 0{
                        self.batteryNotification()
                        battery_alert_limit += 1
                    }
                }
            }
        }
        else if characteristic.uuid == cPM25.uuid {
            if let data = characteristic.value {
                print("PM25 Measurement")
                Constants.pm25l = data.map { String(format: "%02x", $0)}.joined()
                print(Constants.pm25l)
                /*
                let hexToDecimalPm25 = Int(Constants.pm25h + Constants.pm25l, radix: 16)!
                pm25Int = Double(hexToDecimalPm25)
                pm25Round = String(format: "%.0f",pm25Int)
                //ContentView.SensorReadings.pm25 = Constants.pm25Int //I assign the changing values to the variable in ContentView
                print(pm25Int)
                if pm25Points.count < 10 {
                    
                    pm25Points.append(.init(value: pm25Int, label: "\(pm25Round)", legend: pm25))
                }
                else {
                    pm25Points.removeFirst()
                    pm25Points.append(.init(value: pm25Int, label: "\(pm25Round)", legend: pm25))
                }
                 
                self.pm25PostNotification()
                 */
                //print(points)
            }
        }
        else if characteristic.uuid == cPM252.uuid {
            if let data = characteristic.value {
                print("PM25 Measurement")
                Constants.pm25h = data.map { String(format: "%02x", $0)}.joined()
                print(Constants.pm25h)
                let hexToDecimalPm25 = Int(Constants.pm25h + Constants.pm25l, radix: 16)!
                pm25Int = Double(hexToDecimalPm25)
                if pm25_array.count < 10 {
                    pm25_array.append(pm25Int)
                }
                else {
                    pm25_array.removeFirst()
                    pm25_array.append(pm25Int)
                }
                var array_sum = 0.0
                for i in pm25_array {
                    array_sum = i + array_sum
                }
                let pm25_avg = array_sum / Double(pm25_array.count)
                if pm25_avg <= 100 {
                    limit_pm25 = 0
                }
                pm25Round = String(format: "%.0f",pm25_avg)
                //ContentView.SensorReadings.pm25 = Constants.pm25Int //I assign the changing values to the variable in ContentView
                print(pm25Int)
                if pm25Points.count < 10 {
                    pm25Points.append(.init(value: pm25Int, label: "\(pm25Round)", legend: pm25))
                }
                else {
                    pm25Points.removeFirst()
                    pm25Points.append(.init(value: pm25Int, label: "\(pm25Round)", legend: pm25))
                }
                if pm25_avg > 100 {
                    if limit_pm25 == 0{
                        self.pm25PostNotification()
                        limit_pm25 += 1
                    }
                }
                //print(points)
            }
        }
    }
    /*
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        myCentral.scanForPeripherals(withServices: nil, options: nil)
    }
    */
    func disconnectPeripheral () {
        myCentral.cancelPeripheralConnection(myPeripheral)
    }
    func startScanning(){
        print("startScanning")
        myCentral.scanForPeripherals(withServices: nil, options: nil)
        //myCentral.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    func stopScanning() {
        print("stopScanning")
        myCentral.stopScan()
        disconnectPeripheral()
        
    }
}
