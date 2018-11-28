//
//  BTManager.swift
//  BLEDemo
//
//  Created by Jindrich Dolezy on 11/04/2018.
//  Copyright © 2018 Dzindra. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol BTManagerDelegate: class {
    func didDiscover(device: BTDevice)
    func didEnableScan(on: Bool)
    func didChangeState(state: CBManagerState)
}


class BTManager: NSObject {
    private let manager: CBCentralManager
    private var seenDevices: [UUID:BTDevice] = [:]
    var devices: [BTDevice] {
        return Array(seenDevices.values)
    }
    var state: CBManagerState {
        return manager.state
    }
    weak var delegate: BTManagerDelegate?
    
    
    var scanning: Bool = false {
        didSet {
            if (oldValue == scanning) {
                return
            }
            print("Manager: scan state set to \(scanning)")
            if (scanning) {
                manager.scanForPeripherals(withServices: [BTUUIDs.blinkService], options: nil)
            } else {
                manager.stopScan()
            }
            delegate?.didEnableScan(on: scanning)
        }
    }
    
    
    override init() {
        manager = CBCentralManager(delegate: nil, queue: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        super.init()
        manager.delegate = self
    }
    
}


extension BTManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Manager: state \(manager.state)")
        
        switch manager.state {
        case .unknown,.resetting:
            break
        case .poweredOn:
            scanning = true
        default:
            scanning = false
            seenDevices = [:]
        }
        
        delegate?.didChangeState(state: manager.state)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Manager: connected \(peripheral)")
        seenDevices[peripheral.identifier]?.connectedCallback()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Manager: failed connect \(peripheral), error \(String(describing: error))")
        seenDevices[peripheral.identifier]?.errorCallback(error: error)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Manager: disconnected \(peripheral), error \(String(describing: error))")
        seenDevices[peripheral.identifier]?.disconnectedCallback()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if seenDevices[peripheral.identifier] == nil {
            print("Manager: discovered \(peripheral), rssi: \(RSSI)")
            let device = BTDevice(peripheral: peripheral, manager: manager)
            seenDevices[peripheral.identifier] = device
            delegate?.didDiscover(device: device)
        } else {
            print("Manager: seen again \(peripheral)")
        }
    }
    
    
}
