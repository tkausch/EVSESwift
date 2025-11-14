import Foundation

/// Root container for EVSE status data from all operators
public struct EVSEStatuses: Codable, Sendable {
    public let evseStatuses: [OperatorStatus]
    
    enum CodingKeys: String, CodingKey {
        case evseStatuses = "EVSEStatuses"
    }
}
