//
//  ViewController.swift
//  BLEDemo
//
//  Created by Jindrich Dolezy on 11/04/2018.
//  Copyright © 2018 Dzindra. All rights reserved.
//

import UIKit
import UserNotifications


class DeviceVC: UIViewController {
    
    enum ViewState: Int {
        case disconnected
        case connected
        case ready
    }
    
//    var device: BTDevice? {
//        didSet {
//            navigationItem.title = device?.name ?? "Device"
//            device?.delegate = self
//        }
//    }
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var blinkSwitch: UISwitch!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    
    var viewState: ViewState = .disconnected {
        didSet {
            switch viewState {
            case .disconnected:
                statusLabel.text = "Disconnected"
                blinkSwitch.isEnabled = false
                blinkSwitch.isOn = false
                speedSlider.isEnabled = false
                disconnectButton.isEnabled = false
                serialLabel.isHidden = true
            case .connected:
                statusLabel.text = "Probing..."
                blinkSwitch.isEnabled = false
                blinkSwitch.isOn = false
                speedSlider.isEnabled = false
                disconnectButton.isEnabled = true
                serialLabel.isHidden = true
            case .ready:
                statusLabel.text = "Ready"
                blinkSwitch.isEnabled = true
                disconnectButton.isEnabled = true
                serialLabel.isHidden = false
                speedSlider.isEnabled = true
                
//                if let b = device?.blink {
//                    blinkSwitch.isOn = b
//                }
//                if let s = device?.speed {
//                    speedSlider.value = Float(s)
//                }
//                serialLabel.text = device?.serial ?? "reading..."
            }
        }
    }
    
//    deinit {
//        device?.disconnect()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewState = .disconnected
    }

    @IBAction func disconnectAction() {
//        device?.disconnect()
    }

    @IBAction func blinkChanged(_ sender: Any) {
//        device?.blink = blinkSwitch.isOn
    }

    @IBAction func speedChanged(_ sender: UISlider) {
//        device?.speed = Int(speedSlider.value)
    }
}

extension DeviceVC: BTDeviceDelegate {
    func deviceSerialChanged(value: String) {
        serialLabel.text = value
    }
    
    func deviceSpeedChanged(value: Int) {
        speedSlider.value = Float(value)
    }
    
    func deviceConnected() {
        viewState = .connected
    }
    
    func deviceDisconnected() {
        viewState = .disconnected
    }
    
    func deviceReady() {
        viewState = .ready
    }
    
    func deviceBlinkChanged(value: Bool) {
        blinkSwitch.setOn(value, animated: true)
        
        if UIApplication.shared.applicationState == .background {
            let content = UNMutableNotificationContent()
            content.title = "ESP Blinky"
            content.body = value ? "Now blinking" : "Not blinking anymore"
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("DeviceVC: failed to deliver notification \(error)")
                }
            }
        }
    }
    
    
}
