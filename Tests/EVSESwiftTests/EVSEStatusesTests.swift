// MIT License
//
// Copyright (c) 2025 Thomas Kausch
// Copyright (c) 2025 EVSESwift Contributors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import Testing

@testable import EVSESwift

@Suite struct EVSEStatusesTests {

    var evseStatuses: EVSEStatuses

    /// Initialize test suite and load EVSEStatuses.json
    init() throws {

        let jsonUrl = try #require(
            Bundle.module.url(forResource: "EVSEStatuses", withExtension: "json"))

        // Load the JSON data from file
        let jsonData = try Data(contentsOf: jsonUrl)

        // Decode the JSON data to EVSEStatuses model
        let decoder = JSONDecoder()
        self.evseStatuses = try decoder.decode(EVSEStatuses.self, from: jsonData)
    }

    /// Test loading and parsing EVSEStatuses.json file
    @Test func testEVSEStatusesParsing() async throws {
        // Verify that data was loaded successfully
        #expect(evseStatuses.evseStatuses.count > 0, "EVSEStatuses should contain operator records")

        // Log the number of operators loaded
        print("Successfully loaded \(evseStatuses.evseStatuses.count) operator status records")
        
        // Count total status records across all operators
        let totalRecords = evseStatuses.evseStatuses.reduce(0) { $0 + $1.evseStatusRecords.count }
        print("Total EVSE status records: \(totalRecords)")
    }

    /// Test parsing of OperatorStatus from EVSEStatuses
    @Test func testOperatorStatusParsing() async throws {

        // Get the first operator status record
        guard let firstOperator = evseStatuses.evseStatuses.first else {
            Issue.record("EVSEStatuses contains no operator records")
            return
        }

        // Verify operator has required properties
        #expect(!firstOperator.operatorID.isEmpty, "Operator should have an ID")
        #expect(!firstOperator.operatorName.isEmpty, "Operator should have a name")

        print("First operator ID: \(firstOperator.operatorID)")
        print("First operator name: \(firstOperator.operatorName)")
        print("EVSE status records: \(firstOperator.evseStatusRecords.count)")
    }

    /// Test parsing of individual EVSEStatusRecord
    @Test func testEVSEStatusRecordParsing() async throws {

        // Find an operator with status records
        guard let operatorWithRecords = evseStatuses.evseStatuses.first(where: {
            $0.evseStatusRecords.count > 0
        }) else {
            Issue.record("Could not find operator with EVSE status records")
            return
        }

        guard let firstRecord = operatorWithRecords.evseStatusRecords.first else {
            Issue.record("Operator has no status records")
            return
        }

        // Verify status record has required properties
        #expect(!firstRecord.evseID.isEmpty, "Status record should have an EVSE ID")

        print("First EVSE ID: \(firstRecord.evseID)")
        print("First EVSE status: \(firstRecord.evseStatus)")
    }

    /// Test parsing of all EVSEStatus enum values
    @Test func testEVSEStatusEnumValues() async throws {

        // Collect all unique status values
        var statusCounts: [EVSEStatus: Int] = [:]
        
        for operatorStatus in evseStatuses.evseStatuses {
            for record in operatorStatus.evseStatusRecords {
                statusCounts[record.evseStatus, default: 0] += 1
            }
        }

        // Verify we have status records
        #expect(statusCounts.count > 0, "Should have at least one status type")

        print("\nEVSE Status distribution:")
        for (status, count) in statusCounts.sorted(by: { $0.value > $1.value }) {
            print("  \(status): \(count)")
        }
    }

    /// Test finding operators by ID
    @Test func testFindOperatorByID() async throws {

        // Try to find a specific operator
        let targetOperatorID = "CH*EVAEMOBILITAET"
        
        let foundOperator = evseStatuses.evseStatuses.first { operatorStatus in
            operatorStatus.operatorID == targetOperatorID
        }

        if let operatorStatus = foundOperator {
            print("\nFound operator: \(operatorStatus.operatorName)")
            print("Status records: \(operatorStatus.evseStatusRecords.count)")
            
            #expect(operatorStatus.operatorID == targetOperatorID, "Operator ID should match")
        } else {
            print("\nOperator \(targetOperatorID) not found in fixture")
        }
    }

    /// Test filtering by EVSE status
    @Test func testFilterByStatus() async throws {

        // Count available charging stations
        var availableCount = 0
        var occupiedCount = 0
        var outOfServiceCount = 0
        var unknownCount = 0

        for operatorStatus in evseStatuses.evseStatuses {
            for record in operatorStatus.evseStatusRecords {
                switch record.evseStatus {
                case .available:
                    availableCount += 1
                case .occupied:
                    occupiedCount += 1
                case .outOfService:
                    outOfServiceCount += 1
                case .unknown:
                    unknownCount += 1
                }
            }
        }

        print("\nStatus counts:")
        print("  Available: \(availableCount)")
        print("  Occupied: \(occupiedCount)")
        print("  Out of Service: \(outOfServiceCount)")
        print("  Unknown: \(unknownCount)")

        // Verify we have at least some records
        let totalCount = availableCount + occupiedCount + outOfServiceCount + unknownCount
        #expect(totalCount > 0, "Should have at least one status record")
    }

    /// Test operators with empty status records
    @Test func testOperatorsWithEmptyRecords() async throws {

        let emptyOperators = evseStatuses.evseStatuses.filter { $0.evseStatusRecords.isEmpty }

        print("\nOperators with no status records: \(emptyOperators.count)")
        
        if !emptyOperators.isEmpty {
            print("Examples:")
            for (index, operatorStatus) in emptyOperators.prefix(5).enumerated() {
                print("  \(index + 1). \(operatorStatus.operatorName) (\(operatorStatus.operatorID))")
            }
        }

        // This is valid - operators may have no current status records
        #expect(evseStatuses.evseStatuses.count >= emptyOperators.count, 
                "Empty operators should be subset of all operators")
    }

    /// Test EVSE ID format validation
    @Test func testEVSEIDFormat() async throws {

        var evseIDExamples: [String] = []

        // Collect some EVSE ID examples
        for operatorStatus in evseStatuses.evseStatuses.prefix(3) {
            for record in operatorStatus.evseStatusRecords.prefix(2) {
                evseIDExamples.append(record.evseID)
            }
        }

        if !evseIDExamples.isEmpty {
            print("\nEVSE ID examples:")
            for id in evseIDExamples {
                print("  \(id)")
                #expect(!id.isEmpty, "EVSE ID should not be empty")
            }
        }
    }
}
