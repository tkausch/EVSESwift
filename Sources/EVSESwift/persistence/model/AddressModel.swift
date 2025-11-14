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

/// A SwiftData persistent model for physical address information.
///
/// `AddressModel` represents the street address and geographic details of a location,
/// typically used as part of a charging station's location information.
@Model
public final class AddressModel {
    
    /// The street name of the location.
    public var street: String
    
    /// The house number of the location.
    public var houseNum: String?
    
    /// The postal code of the location.
    public var postalCode: String?
    
    /// The city name where the location is.
    public var city: String
    
    /// The region or state where the location is.
    public var region: String?
    
    /// The country where the location is.
    public var country: String
    
    /// The time zone of the location (e.g., "Europe/Zurich").
    public var timeZone: String?
    
    /// The floor number if the location is within a building.
    public var floor: String?
    
    /// The specific parking spot identifier.
    public var parkingSpot: String?
    
    /// Indicates if there is a parking facility.
    public var parkingFacility: Bool?
    
    /// The charging station this address belongs to.
    public var station: ChargingStationModel?
    
    // MARK: - Initialization
    
    /// Creates a new address model with the required core information.
    ///
    /// - Parameters:
    ///   - street: The street name.
    ///   - city: The city name.
    ///   - country: The country name.
    init(
        street: String,
        city: String,
        country: String
    ) {
        self.street = street
        self.city = city
        self.country = country
    }
    
    /// Creates a SwiftData model from an API transfer object.
    ///
    /// - Parameter address: The API address object to convert.
    convenience init(from address: Address) {
        self.init(
            street: address.street,
            city: address.city,
            country: address.country
        )
        
        // Optional fields
        self.houseNum = address.houseNum
        self.postalCode = address.postalCode
        self.region = address.region
        self.timeZone = address.timeZone
        self.floor = address.floor
        self.parkingSpot = address.parkingSpot
        self.parkingFacility = address.parkingFacility
    }
}
