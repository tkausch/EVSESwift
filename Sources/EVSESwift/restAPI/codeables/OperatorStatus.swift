import Foundation

/// Represents the status information for all EVSEs operated by a specific operator
public struct OperatorStatus: Codable, Sendable {
    public let evseStatusRecords: [EVSEStatusRecord]
    public let operatorID: String
    public let operatorName: String
    
    enum CodingKeys: String, CodingKey {
        case evseStatusRecords = "EVSEStatusRecord"
        case operatorID = "OperatorID"
        case operatorName = "OperatorName"
    }
}
