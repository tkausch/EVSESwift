// MIT License
//
// Copyright (c) 2025 Thomas Kausch
//
// This test suite validates the EVSE REST client using the public data.geo.admin.ch endpoint.

import Foundation
import Testing
@testable import EVSESwift

@Suite struct EVSERestClientTests {

    let client: ESVSERestClient

    init() {
        self.client = ESVSERestClient()
    }

    /// Calls the live EVSE endpoint and checks that at least one record is returned.
    /// Note: If the network is unavailable, this test will record an issue instead of failing hard.
    @Test func testGetEVSEData() async throws {
        do {
            let root = try await client.getEVSEData()
            #expect(root.evseData.count > 0, "EVSEData should contain records")
            if let first = root.evseData.first?.evseDataRecord.first {
                print("First station ID: \(first.chargingStationId)")
            }
            print("Fetched \(root.evseData.count) EVSE data records from remote endpoint")
        } catch {
            Issue.record("Network fetch failed for getEVSEData(): \(error)")
        }
    }
}
