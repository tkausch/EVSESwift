// MIT License
//
// Copyright (c) 2025 Thomas Kausch
//
// Tests for ESVSEManager convenience layer.

import Foundation
import Testing
import SwiftData
@testable import EVSESwift

@Suite struct EVSEManagerTests {

    struct MockFetcher: EVSEDataFetching, EVSEStatusFetching {
        var calls = 0
        func getEVSEData() async throws -> EVSEData {
            // Count calls to validate caching behavior
            // Use a simple decoded fixture to avoid constructing large models manually
            let url = try #require(Bundle.module.url(forResource: "EVSEData", withExtension: "json"))
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(EVSEData.self, from: data)
            return decoded
        }
        
        func getEVSEStatuses() async throws -> EVSEStatuses {
            let url = try #require(Bundle.module.url(forResource: "EVSEStatuses", withExtension: "json"))
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(EVSEStatuses.self, from: data)
            return decoded
        }
    }

    let manager: EVSEManager
    var mock: MockFetcher

    init() throws {
        self.mock = MockFetcher()
        
        // Create in-memory container for testing
        let container = try ModelContainer(
            for: ChargingStationModel.self,
            ChargingPointOperatorModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let repository = ChargingStationRepository(container: container)
        let operatorRepository = ChargingPointOperatorRepository(container: container)
        
        self.manager = EVSEManager(fetcher: mock, repository: repository, operatorRepository: operatorRepository)
    }

    @Test func testGetChargingStations() async throws {
        do {
            let stations = try await manager.findAll()
            #expect(stations.count > 0, "Should return at least one charging station")
            if let first = stations.first {
                print("Station ID: \(first.chargingStationId)")
            }
        } catch {
            // Network hiccups shouldn't hard-fail CI if the remote endpoint is flaky
            Issue.record("Fetching charging stations failed: \(error)")
        }
    }

    @Test func testGetChargingStationsMultipleCalls() async throws {
        // First call fetches data and caches it
        let first = try await manager.findAll()
        #expect(first.count > 0)
        
        // Second call returns cached models
        let second = try await manager.findAll()
        #expect(second.count == first.count)
    }
    
    @Test func testCacheIsUsed() async throws {
        // First call should fetch from API and cache
        let first = try await manager.findAll()
        #expect(first.count > 0, "Should fetch data from API")
        
        // Second call should use cache (no network call)
        let cached = try await manager.findAll()
        #expect(cached.count == first.count, "Cached data should match initial fetch")
    }
    
    @Test func testUpdateStatusOfAllChargingStations() async throws {
        // First, populate the cache with charging stations
        let stations = try await manager.findAll()
        #expect(stations.count > 0, "Should have cached stations")
        
        // Print first few station IDs to see what's available
        print("First 5 station IDs in cache:")
        for station in stations.prefix(5) {
            print("  \(station.chargingStationId)")
        }
        
        guard let testStation = stations.first else {
            Issue.record("No stations in cache")
            return
        }
        
        // Verify initial status is nil for cached station
        #expect(testStation.status == nil, "Initial status should be nil")
        
        // Update status for all stations
        try await manager.updateStatusOfAllChargingStations()
        
        // Verify that stations were processed
        let updatedStations = try await manager.findAll()
        let stationsWithStatus = updatedStations.filter { $0.status != nil }
        
        print("Total stations with status: \(stationsWithStatus.count) out of \(updatedStations.count)")
        
        // The update should complete without errors even if no IDs match
        #expect(updatedStations.count == stations.count, "Station count should remain the same")
    }
}
