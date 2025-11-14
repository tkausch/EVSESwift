import Foundation

/// Indicates whether dynamic status information is available for a charging station
public enum DynamicInfoAvailable: String, Codable, Sendable {
    case yes = "true"
    case no = "false"
    case auto = "auto"
    
    public init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "true":
            self = .yes
        case "false":
            self = .no
        case "auto":
            self = .auto
        default:
            return nil
        }
    }
}
