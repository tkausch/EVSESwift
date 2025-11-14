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

    /// Calls the live EVSE status endpoint and checks that at least one operator status record is returned.
    /// Note: If the network is unavailable, this test will record an issue instead of failing hard.
    @Test func testGetEVSEStatuses() async throws {
        do {
            let root = try await client.getEVSEStatuses()
            #expect(root.evseStatuses.count > 0, "EVSEStatuses should contain operator records")
            
            // Count total status records
            let totalRecords = root.evseStatuses.reduce(0) { $0 + $1.evseStatusRecords.count }
            
            if let firstOperator = root.evseStatuses.first {
                print("First operator: \(firstOperator.operatorName) (\(firstOperator.operatorID))")
                print("Status records for first operator: \(firstOperator.evseStatusRecords.count)")
            }
            
            print("Fetched \(root.evseStatuses.count) operator status records from remote endpoint")
            print("Total EVSE status records: \(totalRecords)")
            
            // Verify we have some status records
            #expect(totalRecords > 0, "Should have at least one EVSE status record")
        } catch {
            Issue.record("Network fetch failed for getEVSEStatuses(): \(error)")
        }
    }
}
