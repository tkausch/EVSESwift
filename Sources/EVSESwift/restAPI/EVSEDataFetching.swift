// MIT License
// Abstraction for fetching EVSEData to enable mocking and testing without live network calls.
import Foundation

public protocol EVSEDataFetching {
    func getEVSEData() async throws -> EVSEData
}
