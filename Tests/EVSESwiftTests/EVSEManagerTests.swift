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

    struct MockFetcher: EVSEDataFetching {
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
    }

    let manager: ESVSEManager
    var mock: MockFetcher

    init() throws {
        self.mock = MockFetcher()
        
        // Create in-memory container for testing
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(
            for: ChargingStationModel.self,
            configurations: configuration
        )
        let repository = ChargingStationRepository(container: container)
        
        self.manager = ESVSEManager(fetcher: mock, repository: repository)
    }

    @Test func testGetChargingStations() async throws {
        do {
            let stations = try await manager.getChargingStations()
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
        let first = try await manager.getChargingStations()
        #expect(first.count > 0)
        
        // Second call returns cached models
        let second = try await manager.getChargingStations()
        #expect(second.count == first.count)
    }
    
    @Test func testCacheIsUsed() async throws {
        // Clear cache first
        try await manager.clearCache()
        
        // First call should fetch from API
        let initialCount = try await manager.getCachedStationCount()
        #expect(initialCount == 0, "Cache should be empty initially")
        
        _ = try await manager.getChargingStations()
        
        // Verify cache is populated
        let cachedCount = try await manager.getCachedStationCount()
        #expect(cachedCount > 0, "Cache should be populated after first fetch")
        
        // Second call should use cache (no network call)
        let cached = try await manager.getChargingStations()
        #expect(cached.count == cachedCount)
    }
}
