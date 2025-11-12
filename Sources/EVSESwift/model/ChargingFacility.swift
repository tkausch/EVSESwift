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

/// Details about a specific charging facility at a charging station.
///
/// `ChargingFacility` represents a single charging connector or outlet at a charging station,
/// including information about its power output and connection type.
public struct ChargingFacility: Codable, Sendable {

    private enum CodingKeys: String, CodingKey {
        case power = "power"
        case powerType = "powertype"
        case amperage = "Amperage"
        case voltage = "Voltage"
    }

    /// The maximum power output of the charging facility in kilowatts (kW).
    ///
    /// This value indicates the charging power capability. For example:
    /// - 3.7 kW for a single-phase AC charger
    /// - 11 kW for a three-phase AC charger
    /// - 50 kW or higher for fast DC charging
    let power: Double?

    /// The maximum electrical current (amperage) available at the charging facility in amperes (A).
    ///
    /// This represents the maximum current that can be drawn from the charger.
    /// For example:
    /// - 16 A for a standard single-phase charger
    /// - 32 A for a higher capacity charger
    /// - 250+ A for ultra-fast DC chargers
    let amperage: Double?

    /// The electrical voltage at the charging facility in volts (V).
    ///
    /// Common voltage levels include:
    /// - 230 V for single-phase AC charging (Europe)
    /// - 400 V for three-phase AC charging (Europe)
    /// - 600 V or higher for DC fast charging systems
    let voltage: Double?

    /// The type of charging power (e.g., "AC", "DC", "CHAdeMO").
    ///
    /// Common power types include:
    /// - AC: Alternating current charging
    /// - DC: Direct current fast charging
    /// - CHAdeMO: Japanese DC charging standard
    /// - Type2: European charging connector for AC
    let powerType: String?

    // Custom decoding to handle power, amperage, voltage as String or Double
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode power - can be Double, String, or missing
        if let p = try? container.decodeIfPresent(Double.self, forKey: .power) {
            self.power = p
        } else if let s = try? container.decodeIfPresent(String.self, forKey: .power) {
            guard let p = Double(s) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .power, in: container,
                    debugDescription: "Cannot convert power string to Double")
            }
            self.power = p
        } else {
            self.power = nil
        }

        // Decode amperage - can be Double, String, or missing
        if let a = try? container.decodeIfPresent(Double.self, forKey: .amperage) {
            self.amperage = a
        } else if let s = try? container.decodeIfPresent(String.self, forKey: .amperage) {
            guard let a = Double(s) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .amperage, in: container,
                    debugDescription: "Cannot convert amperage string to Double")
            }
            self.amperage = a
        } else {
            self.amperage = nil
        }

        // Decode voltage - can be Double, String, or missing
        if let v = try? container.decodeIfPresent(Double.self, forKey: .voltage) {
            self.voltage = v
        } else if let s = try? container.decodeIfPresent(String.self, forKey: .voltage) {
            guard let v = Double(s) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .voltage, in: container,
                    debugDescription: "Cannot convert voltage string to Double")
            }
            self.voltage = v
        } else {
            self.voltage = nil
        }

        self.powerType = try container.decodeIfPresent(String.self, forKey: .powerType)
    }

    // Custom encoding
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(power, forKey: .power)
        try container.encodeIfPresent(amperage, forKey: .amperage)
        try container.encodeIfPresent(voltage, forKey: .voltage)
        try container.encodeIfPresent(powerType, forKey: .powerType)
    }
}
