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
   
}


//extension BTManager: CBCentralManagerDelegate {
//
//}
