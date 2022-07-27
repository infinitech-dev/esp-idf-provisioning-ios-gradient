

import Foundation

public protocol ESPGradientDelegate: AnyObject {
    func espGradient(onLogging: String);
}

public class ESPGradient {
    public static weak var delegate: ESPGradientDelegate? = nil
    
    public static func log(_ s: String, function: String = #function, line: Int = #line) {
        delegate?.espGradient(onLogging: s);
    }
    
    public static func logAct(_ s: String, function: String = #function, line: Int = #line) {
        log("[ACTION] \(s)", function: function, line: line)
    }
    
    public static func logEvt(_ s: String, function: String = #function, line: Int = #line) {
        log("[EVENT_] \(s)", function: function, line: line)
    }
    
    public static func logErr(_ s: String, function: String = #function, line: Int = #line) {
        log("[ERROR_] \(s)", function: function, line: line)
    }
}

func ToLogObj(_ obj: Any?) -> String {
    return obj.map({ String(describing: $0) }) ?? "(none)"
}

func JSONDesc(from obj: Any?) -> String {
    guard let obj = obj else { return "(null)" }
    if JSONSerialization.isValidJSONObject(obj) {
        do {
            var options: JSONSerialization.WritingOptions = [];
            if #available(iOS 13.0, *) { options.insert(.withoutEscapingSlashes) }
            let data = try JSONSerialization.data(withJSONObject: obj, options: options)
            return String(data: data, encoding: .utf8) ?? "(Invalid)"
        }catch let error {
            return "ERROR: \(error)"
        }
    }
    
    return "(plain) \(obj)"
}
