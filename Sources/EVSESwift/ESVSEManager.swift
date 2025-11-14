// MIT License
//
// Copyright (c) 2025 Thomas Kausch
//
// A simple high-level manager that wraps `ESVSERestClient` and provides
// convenience APIs to retrieve ChargingStation models.

import Foundation

/// High-level facade for querying EVSE charging stations.
public final class ESVSEManager {
    private let dataFetcher: EVSEDataFetching

    /// Create a new manager with the default REST client.
    public init() {
        self.dataFetcher = ESVSERestClient()
    }

    /// Create a new manager with a custom client (useful for testing).
    /// - Parameter client: An instance of the REST client used to fetch data.
    public init(fetcher: EVSEDataFetching = ESVSERestClient()) {
        self.dataFetcher = fetcher
    }

    /// Fetches all charging stations available from the public dataset.
    /// - Returns: A flattened array of `ChargingStation` decoded from the dataset.
    public func getChargingStations() async throws -> [ChargingStation] {
        let root = try await dataFetcher.getEVSEData()
        // Flatten EVSEData -> [EVSEDataRecord] -> [ChargingStation]
        let stations = root.evseData.flatMap { $0.evseDataRecord }
        return stations
    }
}
