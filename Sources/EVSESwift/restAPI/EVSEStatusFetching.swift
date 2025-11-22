
public protocol EVSEStatusFetching {
    func getEVSEStatuses() async throws -> EVSEStatuses
}
