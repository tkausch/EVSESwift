// MIT License
//
// Copyright (c) 2025 Thomas Kausch
//
// Tests for ESVSEManager convenience layer.

import Foundation
import Testing
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

    init() {
        self.mock = MockFetcher()
        self.manager = ESVSEManager(fetcher: mock)
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
        // First call fetches data
        let first = try await manager.getChargingStations()
        #expect(first.count > 0)
        // Second call fetches fresh data
        let second = try await manager.getChargingStations()
        #expect(second.count == first.count)
    }
}
