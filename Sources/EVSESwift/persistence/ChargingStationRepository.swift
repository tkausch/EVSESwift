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
import SwiftData

/// A repository for managing ChargingStation persistent models.
///
/// This class provides asynchronous CRUD operations for ChargingStationModel entities.
/// All database operations create their own context for isolation.
class ChargingStationRepository: ModelRepository {
   
    typealias T = ChargingStationModel
    
    let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
}

// MARK: - Custom Query Methods

extension ChargingStationRepository {
    
    /// Finds all charging stations in a specific city.
    ///
    /// - Parameter city: The city name to search for.
    /// - Returns: An array of charging stations in the specified city.
    /// - Throws: An error if the fetch operation fails.
    func findByCity(_ city: String) async throws -> [ChargingStationModel] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ChargingStationModel>(
            predicate: #Predicate { station in
                station.address?.city == city
            },
            sortBy: [SortDescriptor(\ChargingStationModel.stationName)]
        )
        return try context.fetch(descriptor)
    }
    
    /// Finds all charging stations with a specific plug type.
    ///
    /// - Parameter plugType: The plug type to search for (e.g., "Type2", "CCS").
    /// - Returns: An array of charging stations with the specified plug type.
    /// - Throws: An error if the fetch operation fails.
    func findByPlugType(_ plugType: String) async throws -> [ChargingStationModel] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ChargingStationModel>(
            predicate: #Predicate { station in
                station.plugs.contains(plugType)
            },
            sortBy: [SortDescriptor(\ChargingStationModel.address?.city)]
        )
        return try context.fetch(descriptor)
    }
    
    /// Finds a charging station by its unique identifier.
    ///
    /// - Parameter id: The charging station ID.
    /// - Returns: The charging station if found, nil otherwise.
    /// - Throws: An error if the fetch operation fails.
    func findById(_ id: String) async throws -> ChargingStationModel? {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ChargingStationModel>(
            predicate: #Predicate { station in
                station.chargingStationId == id
            }
        )
        return try context.fetch(descriptor).first
    }
    
    /// Finds all 24-hour accessible charging stations.
    ///
    /// - Returns: An array of charging stations that are open 24 hours.
    /// - Throws: An error if the fetch operation fails.
    func find24HourStations() async throws -> [ChargingStationModel] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ChargingStationModel>(
            predicate: #Predicate { station in
                station.isOpen24Hours == true
            },
            sortBy: [SortDescriptor(\ChargingStationModel.address?.city)]
        )
        return try context.fetch(descriptor)
    }
    
    /// Finds all charging stations using renewable energy.
    ///
    /// - Returns: An array of charging stations that use renewable energy.
    /// - Throws: An error if the fetch operation fails.
    func findRenewableEnergyStations() async throws -> [ChargingStationModel] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ChargingStationModel>(
            predicate: #Predicate { station in
                station.renewableEnergy == true
            },
            sortBy: [SortDescriptor(\ChargingStationModel.address?.city)]
        )
        return try context.fetch(descriptor)
    }
    
    /// Finds all charging stations in a specific country.
    ///
    /// - Parameter country: The country name to search for.
    /// - Returns: An array of charging stations in the specified country.
    /// - Throws: An error if the fetch operation fails.
    func findByCountry(_ country: String) async throws -> [ChargingStationModel] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ChargingStationModel>(
            predicate: #Predicate { station in
                station.address?.country == country
            },
            sortBy: [
                SortDescriptor(\ChargingStationModel.address?.city),
                SortDescriptor(\ChargingStationModel.stationName)
            ]
        )
        return try context.fetch(descriptor)
    }
    
    /// Finds all charging stations with a specific postal code.
    ///
    /// - Parameter postalCode: The postal code to search for.
    /// - Returns: An array of charging stations in the specified postal code area.
    /// - Throws: An error if the fetch operation fails.
    func findByPostalCode(_ postalCode: String) async throws -> [ChargingStationModel] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ChargingStationModel>(
            predicate: #Predicate { station in
                station.address?.postalCode == postalCode
            },
            sortBy: [SortDescriptor(\ChargingStationModel.stationName)]
        )
        return try context.fetch(descriptor)
    }
    
    /// Counts the total number of charging stations in the database.
    ///
    /// - Returns: The total count of charging stations.
    /// - Throws: An error if the fetch operation fails.
    func countStations() async throws -> Int {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ChargingStationModel>()
        return try context.fetchCount(descriptor)
    }
    
    /// Deletes all charging stations from the database.
    ///
    /// - Throws: An error if the delete operation fails.
    func deleteAll() async throws {
        let context = ModelContext(container)
        try context.delete(model: ChargingStationModel.self)
        try context.save()
    }
}
