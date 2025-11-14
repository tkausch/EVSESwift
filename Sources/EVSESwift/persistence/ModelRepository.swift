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

/// A specialized repository protocol for managing SwiftData persistent models.
///
/// `ModelRepository` extends the base `Repository` protocol with SwiftData-specific functionality.
/// Conforming types must provide a `ModelContainer` which is used to create contexts for database operations.
///
/// All operations create their own `ModelContext` to ensure thread-safe access to the database.
protocol ModelRepository<T>: Repository where T: PersistentModel {
    /// The model container used for all database operations.
    var container: ModelContainer { get }
}

extension ModelRepository {
    
    func create<T: PersistentModel>(_ items: [T]) async throws {
        let context = ModelContext(container)
        for item in items {
            context.insert(item)
        }
        try context.save()
    }
    
    func create<T: PersistentModel>(_ item: T) async throws {
        let context = ModelContext(container)
        context.insert(item)
        try context.save()
    }
    
    func read<T: PersistentModel>(sortBy sortDescriptors: SortDescriptor<T>...) async throws -> [T] {
        let context = ModelContext(container)
        let fetchDescriptor = FetchDescriptor<T>(
            sortBy: sortDescriptors
        )
        return try context.fetch(fetchDescriptor)
    }
    
    func update<T: PersistentModel>(_ item: T) async throws {
        let context = ModelContext(container)
        context.insert(item)
        try context.save()
    }
    
    func delete<T: PersistentModel>(_ item: T) async throws {
        let context = ModelContext(container)
        let idToDelete = item.persistentModelID
        try context.delete(model: T.self, where: #Predicate { item in
            item.persistentModelID == idToDelete
        })
        try context.save()
    }
}