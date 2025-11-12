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


/// The physical location information of a charging station.
///
/// `Address` represents the street address and geographic details of an electric vehicle charging station.
/// All properties are optional to accommodate varying levels of data completeness from different charging point operators.
public struct Address: Codable {
    /// The street name of the charging station location.
    let street: String
    
    /// The house number of the charging station location.
    let houseNum: String?
    
    /// The postal code of the charging station location.
    let postalCode: String?
    
    /// The city name where the charging station is located.
    let city: String
    
    /// The region or state where the charging station is located.
    let region: String?
    
    /// The country where the charging station is located.
    let country: String
    
    /// The time zone of the charging station location (e.g., "Europe/Zurich").
    let timeZone: String?
    
    /// The floor number if the charging station is located within a building.
    let floor: String?
    
    /// The specific parking spot identifier where the charging station is located.
    let parkingSpot: String?
    
    /// The parking facility or parking area name where the charging station is located.
    let parkingFacility: Bool?

    enum CodingKeys: String, CodingKey {
        case houseNum = "HouseNum"
        case timeZone = "TimeZone"
        case city = "City"
        case country = "Country"
        case postalCode = "PostalCode"
        case street = "Street"
        case floor = "Floor"
        case region = "Region"
        case parkingSpot = "ParkingSpot"
        case parkingFacility = "ParkingFacility"
    }
}