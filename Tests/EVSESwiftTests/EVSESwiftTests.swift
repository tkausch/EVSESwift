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

@Suite struct EVSEDataTests {

    var evseData: EVSEData

    /// Initialize test suite and load EVSEData.json
    init() throws {

        let jsonUrl = try #require(
            Bundle.module.url(forResource: "EVSEData", withExtension: "json"))

        // Load the JSON data from file
        let jsonData = try Data(contentsOf: jsonUrl)

        // Decode the JSON data to EVSEData model
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601Flexible
      

        self.evseData = try decoder.decode(EVSEData.self, from: jsonData)
    }

    /// Test loading and parsing EVSEData.json file
    @Test func testEVSEDataParsing() async throws {
        // Verify that data was loaded successfully
        #expect(evseData.evseData.count > 0, "EVSEData should contain records")

        // Log the number of records loaded
        print("Successfully loaded \(evseData.evseData.count) EVSE data records")
    }

    /// Test parsing of individual charging stations from EVSEData
    @Test func testChargingStationParsing() async throws {

        // Get the first EVSE data record
        guard let firstRecord = evseData.evseData.first else {
            Issue.record("EVSEData contains no records")
            return
        }

        #expect(
            firstRecord.evseDataRecord.count > 0, "First record should contain charging stations")

        // Verify the first charging station has required properties
        if let firstStation = firstRecord.evseDataRecord.first {
            #expect(!firstStation.chargingStationId.isEmpty, "Charging station should have an ID")
            #expect(!firstStation.plugs.isEmpty, "Charging station should have plugs")
            #expect(
                firstStation.chargingFacilities.count > 0, "Charging station should have facilities"
            )
            #expect(
                firstStation.authenticationModes.count > 0,
                "Charging station should have auth modes")

            print("First charging station ID: \(firstStation.chargingStationId)")
            print("Available plugs: \(firstStation.plugs.joined(separator: ", "))")
            print("Charging facilities: \(firstStation.chargingFacilities.count)")
        }
    }

    /// Test parsing of address information
    @Test func testAddressParsing() async throws {

        // Get the first charging station
        guard let firstRecord = evseData.evseData.first,
            let firstStation = firstRecord.evseDataRecord.first
        else {
            Issue.record("Could not find charging station in data")
            return
        }

        let address = firstStation.address

        // Verify address has expected properties
        #expect(!address.city.isEmpty, "Address should have a city")
        #expect(!address.country.isEmpty, "Address should have a country")

        print("Location: \(address.city), \(address.country)")
    }

    /// Test parsing of charging facilities with power information
    @Test func testChargingFacilityParsing() async throws {

        // Find a station with charging facilities
        guard let firstRecord = evseData.evseData.first,
            let stationWithFacilities = firstRecord.evseDataRecord.first(where: {
                $0.chargingFacilities.count > 0
            })
        else {
            Issue.record("Could not find station with charging facilities")
            return
        }

        // Verify facilities
        for (index, facility) in stationWithFacilities.chargingFacilities.enumerated() {
            print("Facility \(index): Power=\(facility.power)kW, Type=\(facility.powerType ?? "Unknown")")
        }

        #expect(
            stationWithFacilities.chargingFacilities.count > 0,
            "Station should have at least one facility")
    }

    /// Test parsing of geographic coordinates
    @Test func testGeoCoordinateParsing() async throws {

        // Get the first charging station
        guard let firstRecord = evseData.evseData.first,
            let firstStation = firstRecord.evseDataRecord.first
        else {
            Issue.record("Could not find charging station in data")
            return
        }

        let geoCoordinates = firstStation.geoCoordinates

        // Verify coordinates
        if let coords = geoCoordinates.google, !coords.isEmpty {
            print("Station coordinates: \(coords)")
        }
    }
    
    /// Test parsing of lastUpdate date field
    @Test func testLastUpdateParsing() async throws {

        // Get stations and verify lastUpdate field
        var stationsWithLastUpdate = 0
        var dateFormats: [String] = []
        
        for record in evseData.evseData {
            for station in record.evseDataRecord.prefix(3) {
                if let lastUpdate = station.lastUpdate {
                    stationsWithLastUpdate += 1
                    
                    // Format date for display
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    dateFormats.append(formatter.string(from: lastUpdate))
                }
            }
        }
        
        #expect(stationsWithLastUpdate > 0, "Should have stations with lastUpdate dates")
        
        print("Stations with lastUpdate: \(stationsWithLastUpdate)")
        if !dateFormats.isEmpty {
            print("Sample lastUpdate dates:")
            for (index, dateStr) in dateFormats.prefix(3).enumerated() {
                print("  \(index + 1). \(dateStr)")
            }
        }
    }
}
