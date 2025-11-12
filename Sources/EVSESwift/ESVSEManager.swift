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
    private var cachedStations: [ChargingStation]? = nil

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
    /// - Parameter useCache: When true (default), returns cached stations if present. Otherwise fetches from network.
    /// - Returns: A flattened array of `ChargingStation` decoded from the dataset.
    public func getChargingStations(useCache: Bool = true) async throws -> [ChargingStation] {
        if useCache, let cachedStations {
            return cachedStations
        }

    let root = try await dataFetcher.getEVSEData()
        // Flatten EVSEData -> [EVSEDataRecord] -> [ChargingStation]
        let stations = root.evseData.flatMap { $0.evseDataRecord }
        // Always store latest result so subsequent calls can benefit from cache
        self.cachedStations = stations
        return stations
    }

    /// Clears the in-memory cache of charging stations.
    public func clearCache() {
        self.cachedStations = nil
    }
}
