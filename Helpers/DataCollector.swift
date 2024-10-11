import Foundation
import UIKit

struct UserInfo: Codable {
    let gfdokPS: String
    let gdpsjPjg: String
    let poguaKFP: String
    let gpaMFOfa: String
    let gciOFm: String
    let bcpJFs: String
    let GOmblx: String
    let G0pxum: String
    let Fpvbduwm: Bool
    let Fpbjcv: String
    let StwPp: Bool
    let KDhsd: Bool
    let bvoikOGjs: [String: String]
    let gfpbvjsoM: Int
    let gfdosnb: [String]
    let bpPjfns: String
    let biMpaiuf: Bool
    let oahgoMAOI: Bool
}

class DataCollector {
    
    static func collectData() -> UserInfo {
        return UserInfo(
            gfdokPS: UIDevice.current.name,
            gdpsjPjg: UIDevice.current.model,
            poguaKFP: UIDevice.current.identifierForVendor?.uuidString ?? "",
            gpaMFOfa: getWiFiAddress() ?? "null",
            gciOFm: getCarrierName() ?? "null",
            bcpJFs: UIDevice.current.systemVersion,
            GOmblx: Locale.current.languageCode ?? "",
            G0pxum: TimeZone.current.identifier,
            Fpvbduwm: UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full,
            Fpbjcv: getTotalMemory(),
            StwPp: isScreenshotting(),
            KDhsd: isScreenRecording(),
            bvoikOGjs: checkAppPresence(),
            gfpbvjsoM: Int(UIDevice.current.batteryLevel * 100),
            gfdosnb: getAvailableKeyboards(),
            bpPjfns: Locale.current.regionCode ?? "",
            biMpaiuf: Locale.current.usesMetricSystem,
            oahgoMAOI: UIDevice.current.batteryState == .full
        )
    }
    
    private static func getWiFiAddress() -> String? {
        return nil
    }
    
    private static func getCarrierName() -> String? {
        return nil
    }
    
    private static func getTotalMemory() -> String {
        return ""
    }
    
    private static func isScreenshotting() -> Bool {
        return false
    }
    
    private static func isScreenRecording() -> Bool {
        return false
    }
    
    private static func checkAppPresence() -> [String: String] {
        let apps = ["WhatsApp": "er1", "Instagram": "er3", "Facebook": "er4", "YouTube": "er5", "Telegram": "er2"]
        var result: [String: String] = [:]
        for (app, code) in apps {
            let urlScheme = "\(app.lowercased())://"
            if UIApplication.shared.canOpenURL(URL(string: urlScheme)!) {
                result[app] = code
            } else {
                result[app] = "false"
            }
        }
        return result
    }
    
    private static func getAvailableKeyboards() -> [String] {
        let keyboards = UITextInputMode.activeInputModes
        return keyboards.map { $0.primaryLanguage ?? "Unknown" }
    }
}
