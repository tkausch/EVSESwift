
public protocol EVSEStatusesFetching {
    func getEVSEStatuses() async throws -> EVSEStatuses
}
