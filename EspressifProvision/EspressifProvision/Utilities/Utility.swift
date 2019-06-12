//
//  Utility.swift
//  EspressifProvision
//
//  Created by Vikas Chandra on 03/06/19.
//  Copyright © 2019 Espressif. All rights reserved.
//

import CoreBluetooth
import Foundation

class Utility {
    static let deviceNamePrefix = Bundle.main.infoDictionary?["BLEDeviceNamePrefix"] as! String

    var deviceName = "ESP Device"
    var configPath: String?
    var versionPath: String?
    var scanPath: String?
    var sessionPath: String?
    var peripheralConfigured = false
    var sessionCharacteristic: CBCharacteristic!
    var configUUIDMap: [String: CBCharacteristic] = [:]
    var deviceVersionInfo: NSDictionary?

    func processDescriptor(descriptor: CBDescriptor) {
        if let value = descriptor.value as? String {
            if value.contains(Constants.scanCharacteristic) {
                scanPath = value
                configUUIDMap.updateValue(descriptor.characteristic, forKey: scanPath!)
            } else if value.contains(Constants.sessionCharacterstic) {
                sessionPath = value
                peripheralConfigured = true
                sessionCharacteristic = descriptor.characteristic
                configUUIDMap.updateValue(descriptor.characteristic, forKey: sessionPath!)
            } else if value.contains(Constants.configCharacterstic) {
                configPath = value
                configUUIDMap.updateValue(descriptor.characteristic, forKey: configPath!)
            } else if value.contains(Constants.versionCharacterstic) {
                versionPath = value
                configUUIDMap.updateValue(descriptor.characteristic, forKey: versionPath!)
            }
        }
    }
}