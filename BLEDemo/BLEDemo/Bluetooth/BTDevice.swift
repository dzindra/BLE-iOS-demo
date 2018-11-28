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
    func deviceSpeedChanged(value: Int)
    func deviceSerialChanged(value: String)
    func deviceDisconnected()

}

class BTDevice: NSObject {
    
}


extension BTDevice: CBPeripheralDelegate {
    
}


