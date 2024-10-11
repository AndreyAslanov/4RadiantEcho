import UIKit
import NetworkExtension
import CoreTelephony
import SystemConfiguration.CaptiveNetwork
import AVFoundation
import Foundation

class DeviceStatus {
    static let shared = DeviceStatus()
    
    var isIdea: Bool = true
    
    private init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        isIdea = !isScreenshotBeingTaken() &&
                 !isScreenRecording() &&
                 !isDeviceCharging() &&
                 !isBatteryFull() &&
                 !isVPNConnected()
    }
    
    // MARK: - Public funcs
    
    func isScreenshotBeingTaken() -> Bool {
        var isScreenshot = false
        let mainScreen = UIScreen.main
        
        NotificationCenter.default.addObserver(forName: UIScreen.capturedDidChangeNotification, object: mainScreen, queue: .main) { _ in
            isScreenshot = mainScreen.isCaptured
        }
        
        return isScreenshot
    }
    
    func isScreenRecording() -> Bool {
        return UIScreen.main.isCaptured
    }
    
    func isDeviceCharging() -> Bool {
        let batteryState = UIDevice.current.batteryState
        return batteryState == .charging || batteryState == .full
    }
    
    func isBatteryFull() -> Bool {
        return UIDevice.current.batteryState == .full
    }
    
    func isVPNConnected() -> Bool {
        let vpnStatus = NEVPNManager.shared().connection.status
        return vpnStatus == .connected || vpnStatus == .connecting
    }
}
