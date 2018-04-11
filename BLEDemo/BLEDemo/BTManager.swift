//
//  BTManager.swift
//  BLEDemo
//
//  Created by Jindrich Dolezy on 11/04/2018.
//  Copyright © 2018 Dzindra. All rights reserved.
//

import Foundation
import CoreBluetooth



class BTManager: NSObject {
    static let serviceUUID = CBUUID(string: "9a8ca9ef-e43f-4157-9fee-c37a3d7dc12d")
    
    let manager: CBCentralManager
    weak var delegate: BTDeviceDelegate? {
        didSet {
            device?.delegate = delegate
        }
    }
    var device: BTDevice?
    
    
    override init() {
        manager = CBCentralManager(delegate: nil, queue: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        
        super.init()
        
        manager.delegate = self
    }
    
    func disconnect() {
        if let device = device {
            manager.cancelPeripheralConnection(device.peripheral)
        }
    }
    
    func startScan() {
        manager.scanForPeripherals(withServices: [BTManager.serviceUUID], options: nil)
    }
    
}


extension BTManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch manager.state {
        case .unknown,.resetting:
            break
        case .poweredOn:
            print("Start scan")
            startScan()
        default:
            print("Manager state \(manager.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral)")
        
        if let device = device, device.peripheral == peripheral {
            device.connectedCallback()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed connect to \(peripheral), error \(String(describing: error))")
        
        if device != nil {
            device = nil
            startScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral), error \(String(describing: error))")
        
        if let device = device, device.peripheral == peripheral {
            device.disconnectedCallback()
            self.device = nil
            startScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral), advertisment \(advertisementData), rssi: \(RSSI)")
        
        if device == nil {
            print("Connecting to \(peripheral)")
            
            device = BTDevice(peripheral: peripheral)
            device?.delegate = delegate
            
            manager.connect(peripheral, options: nil)
            manager.stopScan()
        }
    }
    
    
}
