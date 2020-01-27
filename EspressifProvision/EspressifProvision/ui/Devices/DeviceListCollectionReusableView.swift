//
//  DeviceListCollectionReusableView.swift
//  EspressifProvision
//
//  Created by Vikas Chandra on 06/01/20.
//  Copyright © 2020 Espressif. All rights reserved.
//

import UIKit

protocol DeviceListHeaderProtocol {
    func deviceInfoClicked(nodeID: String)
}

class DeviceListCollectionReusableView: UICollectionReusableView {
    @IBOutlet var headerLabel: UILabel!
    var nodeID = ""
    var delegate: DeviceListHeaderProtocol?

    @IBAction func infoClicked(_: Any) {
        delegate?.deviceInfoClicked(nodeID: nodeID)
    }
}
