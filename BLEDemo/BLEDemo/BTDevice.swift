//
//  BTDevice.swift
//  BLEDemo
//
//  Created by Jindrich Dolezy on 11/04/2018.
//  Copyright © 2018 Dzindra. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol BTDeviceDelegate: class {
    func deviceConnected()
    func deviceReady()
    func deviceBlinkChanged(value: Bool)
    func deviceDisconnected()

}

class BTDevice: NSObject {
    static let blinkUUID = CBUUID(string: "e94f85c8-7f57-4dbd-b8d3-2b56e107ed60")
    static let textUUID = CBUUID(string: "326a9006-85cb-9195-d9dd-464cfbbae75a")
    
    private var blinkChar: CBCharacteristic? {
        didSet {
            if let char = oldValue {
                peripheral.setNotifyValue(false, for: char)
            }
            if let char = blinkChar {
                peripheral.readValue(for: char)
                peripheral.setNotifyValue(true, for: char)
                if let b = char.value?.parseBlink() {
                    _blink = b
                }
            }
        }
    }
    private var textChar: CBCharacteristic?
    private var _blink: Bool = false
    
    let peripheral: CBPeripheral
    weak var delegate: BTDeviceDelegate?
    var blink: Bool {
        get {
            return _blink
        }
        set {
            guard _blink != newValue else { return }
            
            _blink = newValue
            if let char = blinkChar {
                peripheral.writeValue(Data(bytes: [_blink ? 1 : 0]), for: char, type: .withResponse)
            }
        }
    }
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        super.init()
        
        peripheral.delegate = self
    }
    
    func send(text: String) {
        if let char = textChar, let data = text.data(using: .utf8) {
            peripheral.writeValue(data, for: char, type: .withoutResponse)
        }
    }
    
    // called from BTManager
    func connectedCallback() {
        peripheral.discoverServices(nil)
        delegate?.deviceConnected()
    }
    
    func disconnectedCallback() {
        
        delegate?.deviceDisconnected()
    }
    
}


extension BTDevice: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered services")
        peripheral.services?.forEach {
            print("  \($0)")
            peripheral.discoverCharacteristics(nil, for: $0)
        }
        print()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Discovered characteristics")
        service.characteristics?.forEach {
            print("   \($0)")
            
            if $0.uuid == BTDevice.blinkUUID {
                self.blinkChar = $0
            } else if $0.uuid == BTDevice.textUUID {
                self.textChar = $0
            }
        }
        print()
        
        delegate?.deviceReady()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Updated value for \(characteristic)")
        
        if characteristic.uuid == blinkChar?.uuid, let b = characteristic.value?.parseBlink() {
            _blink = b
            delegate?.deviceBlinkChanged(value: b)
        }
    }
}


extension Data {
    func parseBlink() -> Bool? {
        guard count == 1 else { return nil }
        
        return self[0] != 0 ? true : false
    }
}

