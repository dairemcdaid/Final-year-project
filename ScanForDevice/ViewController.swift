//
//  ViewController.swift
//  ScanForDevice
//
//  Created by daire mc daid on 17/12/2017.
//  Copyright © 2017 daire mc daid. All rights reserved.
//

import UIKit
import CoreBluetooth
import FirebaseAuth

let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")
let heartRateCharacteristicCBUUID = CBUUID(string: "2A37")
var BPMArray = [Int]()

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // variables
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var timer = Timer()
    
    //properties
    @IBOutlet weak var displayGraph: UIButton!
    @IBOutlet weak var connection: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var logout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startManager()
        
        displayGraph.layer.cornerRadius = 10
        logout.layer.cornerRadius = 10
        
        heartRateLabel.font = UIFont.monospacedDigitSystemFont(ofSize: heartRateLabel.font!.pointSize, weight: .thin)

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
    }
    
    //log out of application

    @IBAction func logoutTapped(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            
            dismiss(animated: true, completion: nil)
            
        } catch
        {
            print("There was a problem logging out")
        }
    }
    
    

    
    func onHeartRateRecieved(_ heartRate: Int)
    {
        heartRateLabel.text = String(heartRate)
        
        // add heart rate values to array
        BPMArray.append(heartRate)
        
        // prints array values in output window horizontally
        //print(BPMArray , terminator:" ")
        //print("\n")
        
        let zero = 0
        
        while let removeZeroIndex = BPMArray.index(of: zero)
        {
            BPMArray.remove(at: removeZeroIndex)
        }
        
        
        // prints array values in output window horizontally
        print(BPMArray , terminator:" ")
        print("\n")
        
        //add all values of array and take away zero's at the start
        let total = BPMArray.reduce(0){$0 + $1}
        print(BPMArray.count)
        
        //let avgHeartRate = total / BPMArray.count
        //heartRateAvgLabel.text = String(avgHeartRate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startManager(){
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // checks if bluetooth on phone is switched on
    // and checks for peripheral
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if(central.state == CBManagerState.poweredOn)
        {
            connection.text = "Scanning..."
            self.timer.invalidate()
            self.centralManager?.scanForPeripherals( withServices: nil, options: nil)
            Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.stopScan), userInfo: nil, repeats: false)
        } else {
            print("BLE not on")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(peripheral.name != nil && peripheral.name! == "Daire-FUSE"){
            self.peripheral = peripheral
            self.centralManager.connect(self.peripheral, options: [CBConnectPeripheralOptionNotifyOnConnectionKey: true])
        }
        
    }
    
    // if peripheral is found
    // let user know
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        print("Connected to \(peripheral.name!)")
        connection.text = "Connected to: \(peripheral.name!)"
        self.stopScan()
    }
    
    //prints list of services found
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard let services = peripheral.services else
        {
            return
        }
        for service in services {
            //print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // discover what characteristics are available
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            //print(characteristic)
            
            if characteristic.properties.contains(.read)
            {
                //print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            
            if characteristic.properties.contains(.notify)
            {
                //print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        switch characteristic.uuid
        {
            
            case heartRateCharacteristicCBUUID: let bpm = heartRate(from: characteristic)
            onHeartRateRecieved(bpm)
            
            case bodySensorLocationCharacteristicCBUUID: let bodySensorLocation = bodyLocation(from: characteristic)
            timeLabel.text = bodySensorLocation
            
            default:
                    print("Unhandled Characteristic UUID: \(characteristic.uuid) \n")
            
        }
    }
    
    //determine where sensor is located
    
    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value, let byte = characteristicData.first else { return "Error" }
        
        switch byte
        {
            case 0: return "Other"
            case 1: return "Chest"
            case 2: return "Wrist"
            case 3: return "Finger"
            case 4: return "Hand"
            case 5: return "Ear lobe"
            case 6: return "Foot"
            
            default:
                return "Reserved for future use"
        }
        
    }
    
    //discover heart rate
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        
        if firstBitValue == 0
        {
            return Int(byteArray[1])
        }
        
        else
        {
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Connection failed", error!)
        connection.text = "failed to connect"
        self.stopScan()
    }
    
    // stop scanning
    @objc func stopScan(){
        self.centralManager.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if self.peripheral != nil{
            self.peripheral.delegate = nil
            self.peripheral = nil
        }
        print("did disconnect", error!)
        self.startManager()
    }

}

