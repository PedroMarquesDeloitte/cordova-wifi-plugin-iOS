import NetworkExtension
import Foundation
import UIKit
import SystemConfiguration.CaptiveNetwork

@objc(WifiConnectPlugin)
class WifiConnectPlugin: CDVPlugin {
    
    @objc(connectToWifi:)
    func connectToWifi(command: CDVInvokedUrlCommand) {
        let ssid = command.argument(at: 0) as? String ?? ""
        let password = command.argument(at: 1) as? String ?? ""
        
        if ssid.isEmpty {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "SSID cannot be empty.")
            self.commandDelegate.send(result, callbackId: command.callbackId)
            return
        }
        
        if password.isEmpty {
            // Create Wi-Fi configuration without password
            let configuration = NEHotspotConfiguration(ssid: ssid)
            NEHotspotConfigurationManager.shared.apply(configuration) { (error) in
                if let error = error {
                    self.commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription), callbackId: command.callbackId)
                } else {
                    self.commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Connected to \(ssid)"), callbackId: command.callbackId)
                }
            }
        } else {
            // Create Wi-Fi configuration
            let configuration = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
            
            NEHotspotConfigurationManager.shared.apply(configuration) { (error) in
                if let error = error {
                    self.commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription), callbackId: command.callbackId)
                } else {
                    self.commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Connected to \(ssid)"), callbackId: command.callbackId)
                }
            }
        }
    }
}

@objc(WifiCheckPlugin)
class WifiCheckPlugin: UIViewController {
    
	@objc(checkWifi:)
    override func viewDidLoad(command: CDVInvokedUrlCommand) {
        super.viewDidLoad()
        let ssid = command.argument(at: 0) as? String ?? ""
		
        // Calls function to verify Wi-Fi Network
        if let conn_ssid = getWiFiSSID() {
            print("Connected to: \(conn_ssid)")
            
            // Verify if the connected SSID is the same we want to check
            if conn_ssid == ssid {
                print("You are connected!")
            } else {
                print("You are not connected.")
            }
        } else {
            print("It was not possible to verify the SSID.")
        }
    }
    
    func getWiFiSSID() -> String? {
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let dict = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? {
                    if let conn_ssid = dict[kCNNetworkInfoKeySSID as String] as? String {
                        return conn_ssid
                    }
                }
            }
        }
        return nil
    }
}
