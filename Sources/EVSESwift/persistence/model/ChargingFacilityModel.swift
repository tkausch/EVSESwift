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

/// A SwiftData persistent model for charging facility (outlet) specifications.
///
/// `ChargingFacilityModel` represents a single charging connector or outlet at a charging station,
/// storing power output specifications and connection type information in the local database.
@Model
final class ChargingFacilityModel {
    
    /// The maximum power output of the charging facility in kilowatts (kW).
    ///
    /// Examples:
    /// - 3.7 kW for single-phase AC charger
    /// - 11 kW for three-phase AC charger
    /// - 50 kW or higher for fast DC charging
    var power: Double?
    
    /// The maximum electrical current (amperage) in amperes (A).
    ///
    /// Examples:
    /// - 16 A for standard single-phase
    /// - 32 A for higher capacity
    /// - 250+ A for ultra-fast DC
    var amperage: Double?
    
    /// The electrical voltage in volts (V).
    ///
    /// Common values:
    /// - 230 V for single-phase AC (Europe)
    /// - 400 V for three-phase AC (Europe)
    /// - 600 V+ for DC fast charging
    var voltage: Double?
    
    /// The type of charging power (e.g., "AC", "DC", "CHAdeMO", "Type2").
    var powerType: String?
    
    /// The charging station this facility belongs to.
    var station: ChargingStationModel?
    
    // MARK: - Initialization
    
    /// Creates a new charging facility model with the specified power specifications.
    ///
    /// - Parameters:
    ///   - power: The maximum power output in kilowatts.
    ///   - amperage: The maximum current in amperes.
    ///   - voltage: The voltage in volts.
    ///   - powerType: The type of charging power.
    init(
        power: Double? = nil,
        amperage: Double? = nil,
        voltage: Double? = nil,
        powerType: String? = nil
    ) {
        self.power = power
        self.amperage = amperage
        self.voltage = voltage
        self.powerType = powerType
    }
    
    /// Creates a SwiftData model from an API transfer object.
    ///
    /// - Parameter facility: The API charging facility object to convert.
    convenience init(from facility: ChargingFacility) {
        self.init(
            power: facility.power,
            amperage: facility.amperage,
            voltage: facility.voltage,
            powerType: facility.powerType
        )
    }
}
