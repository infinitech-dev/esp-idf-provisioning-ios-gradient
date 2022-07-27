

import Foundation
import CoreBluetooth


//MARK: - CBCentralManager

protocol CBCentralManagerDelegate: AnyObject {
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
}

class CBCentralManager: NSObject {
    var org: CoreBluetooth.CBCentralManager!;
    weak var delegate: CBCentralManagerDelegate?
    
    var state: CBManagerState {
        return org.state;
    }
    
    init(delegate: CBCentralManagerDelegate?, queue: DispatchQueue?) {
        super.init();
        
        self.delegate = delegate;
        org = CoreBluetooth.CBCentralManager(delegate: self, queue: queue);
    }
    
    func cancelPeripheralConnection(_ peripheral: CBPeripheral) {
        ESPGradient.logAct("CENTRAL cancels peripheral connection: \(peripheral.org)")
        org.cancelPeripheralConnection(peripheral.org)
    }
    
    func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil) {
        ESPGradient.logAct("CENTRAL connects peripheral: \(peripheral.org)")
        org.connect(peripheral.org, options: options);
    }
    
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil) {
        ESPGradient.logAct("CENTRAL scans for peripherals with services: \(serviceUUIDs ?? [])")
        org.scanForPeripherals(withServices: serviceUUIDs, options: options);
    }
    
    func stopScan() {
        ESPGradient.logAct("CENTRAL stops scan!")
        org.stopScan();
    }
}

extension CBCentralManager: CoreBluetooth.CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CoreBluetooth.CBCentralManager) {
        ESPGradient.logEvt("CENTRAL did update state: \(central.state), ready: \(central.state == .poweredOn)")
        delegate?.centralManagerDidUpdateState(self);
    }
    
    func centralManager(_ central: CoreBluetooth.CBCentralManager, didDiscover peripheral: CoreBluetooth.CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name?.hasPrefix("RRHP") == true {
            var advertisementData = advertisementData;
            if let uuids = advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID] {
                advertisementData["kCBAdvDataServiceUUIDs"] = uuids.map({ $0.uuidString })
            }
            ESPGradient.logEvt("CENTRAL did discover peripheral: \(ToLogObj(peripheral.name)), advertisementData: \(advertisementData.debugDescription), rssi: \(RSSI)")
        }
        delegate?.centralManager(self, didDiscover: CBPeripheral(peripheral), advertisementData: advertisementData, rssi: RSSI);
    }
    
    func centralManager(_ central: CoreBluetooth.CBCentralManager, didConnect peripheral: CoreBluetooth.CBPeripheral) {
        ESPGradient.logEvt("CENTRAL did connect peripheral: \(ToLogObj(peripheral.name))")
        delegate?.centralManager(self, didConnect: CBPeripheral(peripheral));
    }
    
    func centralManager(_ central: CoreBluetooth.CBCentralManager, didFailToConnect peripheral: CoreBluetooth.CBPeripheral, error: Error?) {
        ESPGradient.logErr("CENTRAL did failed to connect peripheral: \(ToLogObj(peripheral.name))\n\t error: \(ToLogObj(error))")
        delegate?.centralManager(self, didFailToConnect: CBPeripheral(peripheral), error: error);
    }
    
    func centralManager(_ central: CoreBluetooth.CBCentralManager, didDisconnectPeripheral peripheral: CoreBluetooth.CBPeripheral, error: Error?) {
        if let error = error {
            ESPGradient.logErr("CENTRAL did disconnect peripheral: \(peripheral)\n\t error: \(ToLogObj(error))")
        }else{
            ESPGradient.logEvt("CENTRAL did disconnect peripheral: \(peripheral)")
        }
        delegate?.centralManager(self, didDisconnectPeripheral: CBPeripheral(peripheral), error: error);
    }
}

//MARK: - CBPeripheral

protocol CBPeripheralDelegate: AnyObject {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?)
}

open class CBPeripheral: NSObject {
    let org: CoreBluetooth.CBPeripheral;
    
    var identifier: UUID {
        return org.identifier
    }
    
    var name: String? {
        return org.name
    }
    
    var services: [CBService]? {
        return org.services
    }
    
    weak var delegate: CBPeripheralDelegate? {
        didSet {
            if delegate != nil {
                self.org.delegate = self;
            }else{
                self.org.delegate = nil;
            }
        }
    }
    
    init(_ org: CoreBluetooth.CBPeripheral) {
        self.org = org;
        super.init();
    }
    
    public static func == (lhs: CBPeripheral, rhs: CBPeripheral) -> Bool {
        return lhs.org == rhs.org;
    }
    
    var logId: String {
        name ?? identifier.uuidString
    }
    
    func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        ESPGradient.logAct("P(\(logId)) discovers services: \(serviceUUIDs ?? [])");
        org.discoverServices(serviceUUIDs);
    }
    
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        ESPGradient.logAct("P(\(logId)) discovers characteristics: \(characteristicUUIDs ?? []) for service: \(service.uuid)");
        org.discoverCharacteristics(characteristicUUIDs, for: service);
    }
    
    open func discoverDescriptors(for characteristic: CBCharacteristic) {
        ESPGradient.logAct("P(\(logId)) discovers descriptors for characteristic \(characteristic.uuid)");
        org.discoverDescriptors(for: characteristic);
    }
    
    func readValue(for characteristic: CBCharacteristic) {
        ESPGradient.logAct("P(\(logId)) reads value from characteristic \(characteristic.uuid)");
        org.readValue(for: characteristic);
    }
    
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        ESPGradient.logAct("P(\(logId)) writes value '\(data.hexEncodedString())' to characteristic \(characteristic.uuid), with response: \(type == .withResponse)");
        org.writeValue(data, for: characteristic, type: type)
    }
    
    func readValue(for descriptor: CBDescriptor) {
        ESPGradient.logAct("P(\(logId)) reads value from descriptor \(descriptor.log)");
        org.readValue(for: descriptor)
    }
}

extension CBPeripheral: CoreBluetooth.CBPeripheralDelegate {
    public func peripheral(_ peripheral: CoreBluetooth.CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            ESPGradient.logErr("P(\(logId)) did fail to discover services, error: \(error)");
        }else{
            let services = peripheral.services ?? []
            ESPGradient.logEvt("P(\(logId)) did discover services \(services.map({ $0.uuid }))");
        }
        delegate?.peripheral(self, didDiscoverServices: error)
    }
  
    public func peripheral(_ peripheral: CoreBluetooth.CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            ESPGradient.logErr("P(\(logId)) did fail to discover characteristics for service: \(service.uuid), error: \(error)");
        }else{
            let characteristics = service.characteristics ?? []
            ESPGradient.logEvt("P(\(logId)) did discover characteristics \(characteristics.map({ $0.uuid })) for service: \(service.uuid)");
        }
        delegate?.peripheral(self, didDiscoverCharacteristicsFor: service, error: error);
    }
    
    public func peripheral(_ peripheral: CoreBluetooth.CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            ESPGradient.logEvt("P(\(logId)) did fail to update value for characteristic \(characteristic.uuid), error: \(error)");
        }else{
            ESPGradient.logEvt("P(\(logId)) did update value '\(characteristic.value?.hexEncodedString() ?? "(null)")' for characteristic \(characteristic.uuid)");
        }
        delegate?.peripheral(self, didUpdateValueFor: characteristic, error: error);
    }
    
    public func peripheral(_ peripheral: CoreBluetooth.CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            ESPGradient.logEvt("P(\(logId)) did fail to write value for characteristic \(characteristic.uuid), error: \(error)");
        }else{
            ESPGradient.logEvt("P(\(logId)) did write value '\(characteristic.value?.hexEncodedString() ?? "(null)")' for characteristic \(characteristic.uuid)");
        }
        delegate?.peripheral(self, didWriteValueFor: characteristic, error: error);
    }
    
    public func peripheral(_ peripheral: CoreBluetooth.CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            ESPGradient.logEvt("P(\(logId)) did fail to discover descriptors, error: \(error)");
        }else{
            let descriptors = characteristic.descriptors ?? [];
            ESPGradient.logEvt("P(\(logId)) did discover descriptors \(descriptors.map({ $0.log })) for characteristic \(characteristic.uuid)");
        }
        delegate?.peripheral(self, didDiscoverDescriptorsFor: characteristic, error: error);
    }
    
    public func peripheral(_ peripheral: CoreBluetooth.CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let error = error {
            ESPGradient.logEvt("P(\(logId)) did fail to update value for descriptor \(descriptor.description), error: \(error)");
        }else{
            ESPGradient.logEvt("P(\(logId)) did update value '\(ToLogObj(descriptor.value))' for descriptor \(descriptor.log)");
        }
        delegate?.peripheral(self, didUpdateValueFor: descriptor, error: error);
    }
}

extension CBDescriptor {
    var log: String {
        "descriptor_of_\(ToLogObj(characteristic?.uuid))"
    }
}
