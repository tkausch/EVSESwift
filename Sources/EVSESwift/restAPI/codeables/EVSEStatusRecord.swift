import Foundation

/// Represents a single EVSE status record with its ID and current status
public struct EVSEStatusRecord: Codable, Sendable {
    public let evseID: String
    public let evseStatus: EVSEStatus
    
    enum CodingKeys: String, CodingKey {
        case evseID = "EvseID"
        case evseStatus = "EVSEStatus"
    }
}
