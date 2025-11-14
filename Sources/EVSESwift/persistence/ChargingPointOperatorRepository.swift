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

/// A repository for managing ChargingPointOperator persistent models.
///
/// This class provides asynchronous CRUD operations for ChargingPointOperatorModel entities.
/// All database operations create their own context for isolation.
public class ChargingPointOperatorRepository: ModelRepository {
   
    public typealias T = ChargingPointOperatorModel
    
    public let container: ModelContainer
    
    public init(container: ModelContainer) {
        self.container = container
    }
}

// MARK: - Custom Query Methods

extension ChargingPointOperatorRepository {
    
    /// Finds a charging point operator by its unique identifier.
    ///
    /// - Parameter id: The operator ID to search for.
    /// - Returns: The charging point operator if found, nil otherwise.
    /// - Throws: An error if the fetch operation fails.
    public func findById(_ id: String) async throws -> ChargingPointOperatorModel? {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ChargingPointOperatorModel>(
            predicate: #Predicate { op in
                op.operatorID == id
            }
        )
        return try context.fetch(descriptor).first
    }
    
    /// Finds operators by name (case-insensitive partial match).
    ///
    /// - Parameter name: The name to search for (partial match).
    /// - Returns: An array of matching charging point operators.
    /// - Throws: An error if the fetch operation fails.
    public func findByName(_ name: String) async throws -> [ChargingPointOperatorModel] {
        let context = ModelContext(container)
        let lowercasedName = name.lowercased()
        let descriptor = FetchDescriptor<ChargingPointOperatorModel>(
            sortBy: [SortDescriptor(\ChargingPointOperatorModel.name)]
        )
        let allOperators = try context.fetch(descriptor)
        return allOperators.filter { $0.name.lowercased().contains(lowercasedName) }
    }
    
    /// Finds all operators that provide real-time data.
    ///
    /// - Returns: An array of operators with real-time data support.
    /// - Throws: An error if the fetch operation fails.
    public func findWithRealTimeData() async throws -> [ChargingPointOperatorModel] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ChargingPointOperatorModel>(
            predicate: #Predicate { op in
                op.withRealTimeData == true
            },
            sortBy: [SortDescriptor(\ChargingPointOperatorModel.name)]
        )
        return try context.fetch(descriptor)
    }
    
    /// Finds all operators without real-time data.
    ///
    /// - Returns: An array of operators without real-time data support.
    /// - Throws: An error if the fetch operation fails.
    public func findWithoutRealTimeData() async throws -> [ChargingPointOperatorModel] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ChargingPointOperatorModel>(
            predicate: #Predicate { op in
                op.withRealTimeData == false
            },
            sortBy: [SortDescriptor(\ChargingPointOperatorModel.name)]
        )
        return try context.fetch(descriptor)
    }
    
    /// Retrieves all charging point operators.
    ///
    /// - Returns: An array of all operators sorted by name.
    /// - Throws: An error if the fetch operation fails.
    public func findAll() async throws -> [ChargingPointOperatorModel] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ChargingPointOperatorModel>(
            sortBy: [SortDescriptor(\ChargingPointOperatorModel.name)]
        )
        return try context.fetch(descriptor)
    }
    
    /// Counts the total number of charging point operators in the database.
    ///
    /// - Returns: The total count of operators.
    /// - Throws: An error if the fetch operation fails.
    public func countOperators() async throws -> Int {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ChargingPointOperatorModel>()
        return try context.fetchCount(descriptor)
    }
    
    /// Deletes all charging point operators from the database.
    ///
    /// - Throws: An error if the delete operation fails.
    public func deleteAll() async throws {
        let context = ModelContext(container)
        try context.delete(model: ChargingPointOperatorModel.self)
        try context.save()
    }
    
    /// Populates the database with all predefined charging point operators.
    ///
    /// This method loads all operators from `ChargingPointOperator.all` and stores them in the database.
    /// Existing operators with the same ID will be skipped.
    ///
    /// - Returns: The number of operators added to the database.
    /// - Throws: An error if the operation fails.
    public func loadDefaults() async throws -> Int {
        let context = ModelContext(container)
        var addedCount = 0
        
        for operatorItem in ChargingPointOperator.all {
            // Check if operator already exists
            let operatorID = operatorItem.operatorID
            let descriptor = FetchDescriptor<ChargingPointOperatorModel>(
                predicate: #Predicate { op in
                    op.operatorID == operatorID
                }
            )
            let existing = try context.fetch(descriptor)
            
            if existing.isEmpty {
                let model = ChargingPointOperatorModel(from: operatorItem)
                context.insert(model)
                addedCount += 1
            }
        }
        
        try context.save()
        return addedCount
    }
}
