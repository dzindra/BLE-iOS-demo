//
//  ViewController.swift
//  BLEDemo
//
//  Created by Jindrich Dolezy on 11/04/2018.
//  Copyright © 2018 Dzindra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum ViewState: Int {
        case disconnected
        case connected
        case ready
    }
    
    var manager: BTManager!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var blinkSwitch: UISwitch!
    @IBOutlet weak var disconnectButton: UIButton!
    
    var viewState: ViewState = .disconnected {
        didSet {
            switch viewState {
            case .disconnected:
                statusLabel.text = "Disconnected"
                blinkSwitch.isEnabled = false
                blinkSwitch.isOn = false
                disconnectButton.isEnabled = false
            case .connected:
                statusLabel.text = "Probing..."
                blinkSwitch.isEnabled = false
                blinkSwitch.isOn = false
                disconnectButton.isEnabled = true
            case .ready:
                statusLabel.text = "Ready"
                blinkSwitch.isEnabled = true
                disconnectButton.isEnabled = true
                
                if let b = manager.device?.blink {
                    blinkSwitch.isOn = b
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = BTManager()
        manager.delegate = self
    }

    @IBAction func disconnectAction() {
        manager.disconnect()
    }
    
    @IBAction func blinkChanged(_ sender: Any) {
        manager.device?.blink = blinkSwitch.isOn
    }
    
}

extension ViewController: BTDeviceDelegate {
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
    }
    
    
}
