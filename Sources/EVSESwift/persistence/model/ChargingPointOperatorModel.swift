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

/// A SwiftData persistent model for charging point operator data.
///
/// `ChargingPointOperatorModel` stores information about charging point operators
/// that provide real-time data through the ich-tanke-strom.ch infrastructure.
///
/// ## Usage
/// ```swift
/// let operator = ChargingPointOperatorModel(
///     operatorID: "CH*AIL",
///     name: "AIL",
///     startDate: Date(),
///     withRealTimeData: true
/// )
/// modelContext.insert(operator)
/// try modelContext.save()
/// ```
@Model
public final class ChargingPointOperatorModel {
    
    // MARK: - Core Properties
    
    /// The unique operator ID used in the ich-tanke-strom.ch infrastructure.
    @Attribute(.unique) public var operatorID: String
    
    /// The display name of the charging point operator.
    public var name: String
    
    /// The date when real-time data became available for this operator.
    public var startDate: Date?
    
    /// Networks included under this operator.
    public var includedNetworks: [String]
    
    /// Indicates whether this operator provides real-time data.
    public var withRealTimeData: Bool
    
    // MARK: - Metadata
    
    /// The timestamp when this record was created.
    public var createdAt: Date
    
    /// The timestamp when this record was last updated.
    public var updatedAt: Date
    
    // MARK: - Initializers
    
    /// Creates a new charging point operator model.
    ///
    /// - Parameters:
    ///   - operatorID: The unique operator identifier.
    ///   - name: The display name of the operator.
    ///   - startDate: The date when real-time data became available (optional).
    ///   - includedNetworks: Networks included under this operator (defaults to empty array).
    ///   - withRealTimeData: Whether this operator provides real-time data (defaults to true).
    public init(
        operatorID: String,
        name: String,
        startDate: Date? = nil,
        includedNetworks: [String] = [],
        withRealTimeData: Bool = true
    ) {
        self.operatorID = operatorID
        self.name = name
        self.startDate = startDate
        self.includedNetworks = includedNetworks
        self.withRealTimeData = withRealTimeData
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Convenience Methods
    
    /// Updates the timestamp to reflect the current date and time.
    public func touch() {
        self.updatedAt = Date()
    }
}

// MARK: - Conversions

extension ChargingPointOperatorModel {
    /// Creates a ChargingPointOperatorModel from a ChargingPointOperator struct.
    ///
    /// - Parameter operator: The ChargingPointOperator to convert.
    /// - Returns: A new ChargingPointOperatorModel instance.
    public convenience init(from operator: ChargingPointOperator) {
        self.init(
            operatorID: `operator`.operatorID,
            name: `operator`.name,
            startDate: `operator`.startDate,
            includedNetworks: `operator`.includedNetworks,
            withRealTimeData: `operator`.withRealTimeData
        )
    }
    
    /// Converts this model to a ChargingPointOperator struct.
    ///
    /// - Returns: A ChargingPointOperator struct representation.
    public func toOperator() -> ChargingPointOperator {
        return ChargingPointOperator(
            operatorID: operatorID,
            name: name,
            startDate: startDate,
            includedNetworks: includedNetworks,
            withRealTimeData: withRealTimeData
        )
    }
}
