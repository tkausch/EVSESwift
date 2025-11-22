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
public final class EVSEManager {
    private let dataFetcher: EVSEDataFetching & EVSEStatusFetching
    private let stationRepository: ChargingStationRepository
    private let operatorRepository: ChargingPointOperatorRepository
    
    /// Create a new manager with the default REST client and persistent cache.
    public init() throws {
        self.dataFetcher = ESVSERestClient()
        
        // Create persistent container for cache
        let container = try ModelContainer(
            for: ChargingStationModel.self,
            ChargingPointOperatorModel.self
        )
        self.stationRepository = ChargingStationRepository(container: container)
        self.operatorRepository = ChargingPointOperatorRepository(container: container)
    }

    /// Create a new manager with custom dependencies (useful for testing).
    ///
    /// - Parameters:
    ///   - fetcher: An instance of the REST client used to fetch data
    ///   - repository: A repository instance for caching (can use in-memory for testing)
    ///   - operatorRepository: A repository instance for operator data (can use in-memory for testing)
    init(
        fetcher: EVSEDataFetching & EVSEStatusFetching,
        repository: ChargingStationRepository,
        operatorRepository: ChargingPointOperatorRepository
    ) {
        self.dataFetcher = fetcher
        self.stationRepository = repository
        self.operatorRepository = operatorRepository
    }

    /// Fetches charging stations as models, using cache when available.
    ///
    /// This method returns cached `ChargingStationModel` data if it exists in the repository.
    /// If the cache is empty, it fetches fresh data from the API and populates the cache.
    ///
    /// - Parameter forceRefresh: If true, ignores cache and fetches fresh data from API
    /// - Returns: An array of `ChargingStationModel` from the persistent store
    /// - Throws: An error if fetching from API fails or repository operations fail
    public func findAll(forceRefresh: Bool = false) async throws -> [ChargingStationModel] {
        // Check cache first unless forceRefresh is requested
        if !forceRefresh {
            let cachedModels: [ChargingStationModel] = try await stationRepository.read(sortBy: SortDescriptor(\ChargingStationModel.chargingStationId))
            if !cachedModels.isEmpty {
                return cachedModels
            }
        }
        // Fetch fresh data from API - clear existing cache
        try await stationRepository.deleteAll()

        // Fetch fresh station data from API
        let root = try await dataFetcher.getEVSEData()
        let chargingStations = root.evseData.flatMap { $0.evseDataRecord }

        try await updateChargingStationCache(with: chargingStations)

        try await updateStatusOfAllChargingStations()

        // Return cached models
        return try await stationRepository.findAll()
    }


    public func updateStatusOfAllChargingStations() async throws {
        
        // Query all evseStatuses from charging stations by API
        let evseStatuses = try await dataFetcher.getEVSEStatuses()
        
        // extract all evseStatusRecords
        var allStatusRecords: [EVSEStatusRecord] = []
        for operatorStatus in evseStatuses.evseStatuses {
            allStatusRecords.append(contentsOf: operatorStatus.evseStatusRecords)
        }

        for evseStatus in allStatusRecords {
           if let chargingStation = try await stationRepository.findById(evseStatus.evseID) {
                chargingStation.status = evseStatus.evseStatus
                try await stationRepository.update(chargingStation) 
           }
        }

    }

    
    // MARK: - Query Methods
    
    /// Finds all charging stations in a specific city.
    ///
    /// - Parameter city: The city name to search for.
    /// - Returns: An array of charging stations in the specified city.
    /// - Throws: An error if the fetch operation fails.
    public func findByCity(_ city: String) async throws -> [ChargingStationModel] {
        return try await stationRepository.findByCity(city)
    }
    
    /// Finds all charging stations with a specific postal code.
    ///
    /// - Parameter postalCode: The postal code to search for.
    /// - Returns: An array of charging stations in the specified postal code area.
    /// - Throws: An error if the fetch operation fails.
    public func findByPostalCode(_ postalCode: String) async throws -> [ChargingStationModel] {
        return try await stationRepository.findByPostalCode(postalCode)
    }
    
    /// Finds all charging stations with a specific plug type.
    ///
    /// - Parameter plugType: The plug type to search for (e.g., "Type2", "CCS").
    /// - Returns: An array of charging stations with the specified plug type.
    /// - Throws: An error if the fetch operation fails.
    public func findByPlugType(_ plugType: String) async throws -> [ChargingStationModel] {
        return try await stationRepository.findByPlugType(plugType)
    }
    
    /// Finds a charging station by its unique identifier.
    ///
    /// - Parameter id: The charging station ID.
    /// - Returns: The charging station if found, nil otherwise.
    /// - Throws: An error if the fetch operation fails.
    public func findById(_ id: String) async throws -> ChargingStationModel? {
        return try await stationRepository.findById(id)
    }
    
    // MARK: - Charging Point Operator Methods
    
    /// Finds a charging point operator by its unique identifier.
    ///
    /// - Parameter id: The operator ID to search for.
    /// - Returns: The charging point operator if found, nil otherwise.
    /// - Throws: An error if the fetch operation fails.
    public func findOperatorById(_ id: String) async throws -> ChargingPointOperatorModel? {
        return try await operatorRepository.findById(id)
    }
    
    /// Finds operators by name (case-insensitive partial match).
    ///
    /// - Parameter name: The name to search for (partial match).
    /// - Returns: An array of matching charging point operators.
    /// - Throws: An error if the fetch operation fails.
    public func findOperatorsByName(_ name: String) async throws -> [ChargingPointOperatorModel] {
        return try await operatorRepository.findByName(name)
    }
    
    /// Retrieves all charging point operators.
    ///
    /// - Returns: An array of all operators sorted by name.
    /// - Throws: An error if the fetch operation fails.
    public func findAllOperators() async throws -> [ChargingPointOperatorModel] {
        return try await operatorRepository.findAll()
    }
    
    /// Counts the total number of charging point operators in the database.
    ///
    /// - Returns: The total count of operators.
    /// - Throws: An error if the fetch operation fails.
    public func countOperators() async throws -> Int {
        return try await operatorRepository.countOperators()
    }
    
    
    // MARK: - Private Methods
    
    private func updateChargingStationCache(with stations: [ChargingStation]) async throws {
        // Clear existing cache
        try await stationRepository.deleteAll()
        
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
        var models: [ChargingStationModel] = []
        for station in uniqueStations { 
            let chargingStationModel = ChargingStationModel(from: station) 
            chargingStationModel.hubOperator = try? await operatorRepository.findById(chargingStationModel.hubOperatorID)
            models.append(chargingStationModel)
        }
        try await stationRepository.create(models)
    }
}
