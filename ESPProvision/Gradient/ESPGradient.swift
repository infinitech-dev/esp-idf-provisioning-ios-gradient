

import Foundation

public protocol ESPGradientDelegate: AnyObject {
    func espGradient(onLogging: String);
}

public class ESPGradient {
    public static weak var delegate: ESPGradientDelegate? = nil
    
    public static func log(_ s: String) {
        delegate?.espGradient(onLogging: s);
    }
}
