import Foundation

/// Represents the operational status of an EVSE (Electric Vehicle Supply Equipment)
public enum EVSEStatus: String, Codable, Sendable {
    case available = "Available"
    case outOfService = "OutOfService"
    case unknown = "Unknown"
    case occupied = "Occupied"
    
    public init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "available":
            self = .available
        case "outofservice":
            self = .outOfService
        case "unknown", "evsenotfound":
            self = .unknown
        case "occupied":
            self = .occupied
        default:
            return nil
        }
    }
}
