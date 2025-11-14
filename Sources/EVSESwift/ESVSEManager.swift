// MIT License
//
// Copyright (c) 2025 Thomas Kausch
//
// A simple high-level manager that wraps `ESVSERestClient` and provides
// convenience APIs to retrieve ChargingStation models with persistent caching.

import Foundation
import SwiftData

/// High-level facade for querying EVSE charging stations with persistent caching.
///
/// `ESVSEManager` provides a simple API to fetch charging stations from the remote API
/// and automatically caches them in a persistent SwiftData store. Once cached, all subsequent
/// calls return the cached `ChargingStationModel` data until explicitly cleared.
public final class ESVSEManager {
    private let dataFetcher: EVSEDataFetching
    private let repository: ChargingStationRepository
    
    /// Create a new manager with the default REST client and persistent cache.
    public init() throws {
        self.dataFetcher = ESVSERestClient()
        
        // Create persistent container for cache
        let container = try ModelContainer(
            for: ChargingStationModel.self
        )
        self.repository = ChargingStationRepository(container: container)
    }

    /// Create a new manager with custom dependencies (useful for testing).
    ///
    /// - Parameters:
    ///   - fetcher: An instance of the REST client used to fetch data
    ///   - repository: A repository instance for caching (can use in-memory for testing)
    init(
        fetcher: EVSEDataFetching,
        repository: ChargingStationRepository
    ) {
        self.dataFetcher = fetcher
        self.repository = repository
    }

    /// Fetches charging stations as models, using cache when available.
    ///
    /// This method returns cached `ChargingStationModel` data if it exists in the repository.
    /// If the cache is empty, it fetches fresh data from the API and populates the cache.
    ///
    /// - Parameter forceRefresh: If true, ignores cache and fetches fresh data from API
    /// - Returns: An array of `ChargingStationModel` from the persistent store
    /// - Throws: An error if fetching from API fails or repository operations fail
    public func getChargingStations(forceRefresh: Bool = false) async throws -> [ChargingStationModel] {
        // Check cache first unless forceRefresh is requested
        if !forceRefresh {
            let cachedModels = try await repository.read(sortBy: SortDescriptor(\ChargingStationModel.chargingStationId))
            if !cachedModels.isEmpty {
                return cachedModels
            }
        }
        
        // Fetch fresh data from API
        let root = try await dataFetcher.getEVSEData()
        let stations = root.evseData.flatMap { $0.evseDataRecord }
        
        // Update cache
        try await updateCache(with: stations)
        
        // Return cached models
        return try await repository.read(sortBy: SortDescriptor(\ChargingStationModel.chargingStationId))
    }
    
    /// Clears all cached charging stations.
    public func clearCache() async throws {
        try await repository.deleteAll()
    }
    
    /// Returns the number of cached stations.
    public func getCachedStationCount() async throws -> Int {
        return try await repository.countStations()
    }
    
    // MARK: - Private Methods
    
    private func updateCache(with stations: [ChargingStation]) async throws {
        // Clear existing cache
        try await repository.deleteAll()
        
        // Remove duplicates based on chargingStationId
        var uniqueStations: [ChargingStation] = []
        var seenIds = Set<String>()
        
        for station in stations {
            if !seenIds.contains(station.chargingStationId) {
                uniqueStations.append(station)
                seenIds.insert(station.chargingStationId)
            }
        }
        
        // Convert to models and save
        let models = uniqueStations.map { ChargingStationModel(from: $0) }
        try await repository.create(models)
    }
}
