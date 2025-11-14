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


/// A complete electric vehicle charging station from the ich-tanke-strom.ch infrastructure.
///
/// `ChargingStation` represents a single charging location in Switzerland with comprehensive information
/// about its location, facilities, accessibility, and operational details. This is the primary data model
/// for working with charging station data from the National Data Infrastructure for Electromobility.
///
/// ## Overview
///
/// A charging station is a physical location that contains one or more charging facilities where
/// electric vehicles can recharge. Each station has a unique identifier and includes extensive metadata
/// about its location, available charging options, payment methods, and operational status.
public struct ChargingStation: Codable, Sendable {

    /// Additional information about accessibility at the location.
    ///
    /// This field provides accessibility details such as wheelchair accessibility or special parking arrangements.
    let accessibilityLocation: String?
    
    /// The physical address of the charging station.
    ///
    /// Contains complete address information including street, city, postal code, and country.
    let address: Address
    
    /// The authentication methods accepted at this charging station.
    ///
    /// Examples: REMOTE, NFC RFID Classic, NFC RFID DESFire, Direct Payment, PnC
    let authenticationModes: [AuthenticationMode]
    
    /// Information about calibration law data availability.
    ///
    /// Indicates whether the station complies with calibration law requirements.
    let calibrationLawDataAvailability: String
    
    /// The charging facilities available at this station.
    ///
    /// Each element represents a charging outlet with its power specification and connector type.
    let chargingFacilities: [ChargingFacility]
    
    /// Names of the charging station in different languages.
    ///
    /// Provides multilingual support for station names (e.g., German, French, Italian).
    let chargingStationNames: [ChargingStationName]
    
    /// Indicates whether dynamic information is available for this station.
    ///
    /// Dynamic information includes real-time availability, current power levels, and occupancy status.
    /// Values: yes (true), no (false), or auto (automatically determined)
    let dynamicInfoAvailable: DynamicInfoAvailable
    
    /// The phone number for station support or assistance.
    let hotlinePhoneNumber: String
    
    /// The Hub operator identifier for Hubject-compatible stations.
    let hubOperatorID: String?
    
    /// Indicates whether the charging station is open 24 hours.
    let isOpen24Hours: Bool
    
    /// The payment methods accepted at this charging station.
    ///
    /// Examples: Direct, Contract, No Payment
    let paymentOptions: [PaymentOption]?
    
    /// The plug or connector types available at this station.
    ///
    /// Examples: 
    /// "Type 2 Outlet" - 12,962 occurrences (most common)
    /// "CCS Combo 2 Plug (Cable Attached)" - 3,158 occurrences
    /// "CHAdeMO" - 683 occurrences
    /// "Tesla Connector" - 444 occurrences
    /// "Type 1 Connector (Cable Attached)" - 326 occurrences
    /// "Type 2 Connector (Cable Attached)" - 273 occurrences
    /// "Type J Swiss Standard" - 9 occurrences
    /// "Type F Schuko" - 5 occurrences
    /// "CCS Combo 1 Plug (Cable Attached)" - 1 occurrence
    let plugs: [String]
    
    /// Indicates whether the station uses renewable energy sources.
    let renewableEnergy: Bool
    
    /// Additional value-added services offered at the station.
    ///
    /// Examples: "WiFi", "RESTAURANT", "SHOP", "RESTROOM", "PARKING", etc.
    let valueAddedServices: [String]?
    
    /// The type of data change (for update tracking).
    ///
    /// Used in data synchronization contexts.
        let deltaType: String?
    
    /// Information of accessibility "Free publicly accessible" or "onStreet"
    let accessibility: String
    
    /// The unique identifier for this charging station.
    ///
    /// This is a stable, globally unique identifier for the charging station.
    let chargingStationId: String
    
    /// The geographic coordinates of the charging station.
    ///
    /// Contains location coordinates for mapping and geolocation services.
    let geoCoordinates: GeoCoordinates
    
    /// The EVSE (Electric Vehicle Supply Equipment) identifier.
    ///
    /// A unique identifier for the supply equipment compliant with European standards.
    let evseID: String
    
    /// The clearinghouse identifier for roaming networks.
    ///
    /// Used for inter-operator communication and billing.
    let clearinghouseID: String?
    
    /// The opening hours or availability information for the station.
    ///
    /// Describes when the station is accessible (e.g., "Mo-Su 06:00-22:00").
    let openingTimes: [OpeningTime]?
    
    /// The geographic coordinates of the charging point entrance.
    ///
    /// Useful for precise navigation to the charging location.
    let geoChargingPointEntrance: GeoCoordinates
    
    /// A reference link or identifier for the charging station location.
    let chargingStationLocationReference: String?
    
    /// The primary energy source for this charging station.
    ///
    /// Examples: "HYDRO_POWER", "WIND_POWER", "COAL", "NUCLEAR", "SOLAR", "NATURAL_GAS", "UNKNOWN", etc.
    let energySource: String?
    
    /// Environmental impact information related to this charging station.
    let environmentalImpact: String?
    
    /// URL or reference to an image of the location.
    let locationImage: String?
    
    /// The name of the suboperator if different from the main operator.
    let suboperatorName: String?
    
    /// The maximum capacity or parking spaces at this charging station.
    let maxCapacity: Double?
    
    /// Additional descriptive information about the charging station.
    let additionalInfo: String?
    
    /// The identifier for the charging pool this station belongs to.
    ///
    /// Multiple stations can be grouped under a single charging pool.
    let chargingPoolID: String?
    
    /// The current dynamic power level available at the station in kilowatts.
    ///
    /// This may vary based on real-time grid conditions and occupancy.
    let dynamicPowerLevel: Bool?
    
    /// The manufacturer of the charging hardware.
    let hardwareManufacturer: String?
    
    /// The timestamp of the last update to this charging station's information.
    ///
    /// This date indicates when the station data was last modified in the source system.
    /// Supports multiple ISO8601 formats including with and without fractional seconds.
    let lastUpdate: Date?

    enum CodingKeys: String, CodingKey {
        case accessibilityLocation = "AccessibilityLocation"
        case address = "Address"
        case authenticationModes = "AuthenticationModes"
        case calibrationLawDataAvailability = "CalibrationLawDataAvailability"
        case chargingFacilities = "ChargingFacilities"
        case chargingStationNames = "ChargingStationNames"
        case dynamicInfoAvailable = "DynamicInfoAvailable"
        case hotlinePhoneNumber = "HotlinePhoneNumber"
        case hubOperatorID = "HubOperatorID"
        case isOpen24Hours = "IsOpen24Hours"
        case paymentOptions = "PaymentOptions"
        case plugs = "Plugs"
        case renewableEnergy = "RenewableEnergy"
        case valueAddedServices = "ValueAddedServices"
        case deltaType = "deltaType"
        case accessibility = "Accessibility"
        case chargingStationId = "ChargingStationId"
        case geoCoordinates = "GeoCoordinates"
        case evseID = "EvseID"
        case clearinghouseID = "ClearinghouseID"
        case openingTimes = "OpeningTimes"
        case geoChargingPointEntrance = "GeoChargingPointEntrance"
        case chargingStationLocationReference = "ChargingStationLocationReference"
        case energySource = "EnergySource"
        case environmentalImpact = "EnvironmentalImpact"
        case locationImage = "LocationImage"
        case suboperatorName = "SuboperatorName"
        case maxCapacity = "MaxCapacity"
        case additionalInfo = "AdditionalInfo"
        case chargingPoolID = "ChargingPoolID"
        case dynamicPowerLevel = "DynamicPowerLevel"
        case hardwareManufacturer = "HardwareManufacturer"
        case lastUpdate = "lastUpdate"
    }
    
    // Custom decoding to handle flexible field types
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.accessibilityLocation = try container.decodeIfPresent(String.self, forKey: .accessibilityLocation)
        self.address = try container.decode(Address.self, forKey: .address)
        self.authenticationModes = try container.decode([AuthenticationMode].self, forKey: .authenticationModes)
        self.calibrationLawDataAvailability = try container.decode(String.self, forKey: .calibrationLawDataAvailability)
        self.chargingFacilities = try container.decode([ChargingFacility].self, forKey: .chargingFacilities)
        
        // Handle ChargingStationNames as either array or single object (or null)
        do {
            // Try array first
            self.chargingStationNames = try container.decodeIfPresent([ChargingStationName].self, forKey: .chargingStationNames) ?? []
        } catch DecodingError.typeMismatch {
            // If array fails, try single object
            if let singleName = try container.decodeIfPresent(ChargingStationName.self, forKey: .chargingStationNames) {
                self.chargingStationNames = [singleName]
            } else {
                self.chargingStationNames = []
            }
        }
        
        self.dynamicInfoAvailable = try container.decode(DynamicInfoAvailable.self, forKey: .dynamicInfoAvailable)
        self.hotlinePhoneNumber = try container.decode(String.self, forKey: .hotlinePhoneNumber)
        self.hubOperatorID = try container.decodeIfPresent(String.self, forKey: .hubOperatorID)
        
        // Handle isOpen24Hours - can be Bool or String ("true"/"false")
        do {
            self.isOpen24Hours = try container.decode(Bool.self, forKey: .isOpen24Hours)
        } catch DecodingError.typeMismatch {
            let stringValue = try container.decode(String.self, forKey: .isOpen24Hours)
            self.isOpen24Hours = stringValue.lowercased() == "true"
        }
        self.paymentOptions = try container.decodeIfPresent([PaymentOption].self, forKey: .paymentOptions)
        self.plugs = try container.decode([String].self, forKey: .plugs)
        self.renewableEnergy = try container.decode(Bool.self, forKey: .renewableEnergy)
        self.valueAddedServices = try container.decodeIfPresent([String].self, forKey: .valueAddedServices)
        self.deltaType = try container.decodeIfPresent(String.self, forKey: .deltaType)
        self.accessibility = try container.decode(String.self, forKey: .accessibility)
        self.chargingStationId = try container.decode(String.self, forKey: .chargingStationId)
        self.geoCoordinates = try container.decode(GeoCoordinates.self, forKey: .geoCoordinates)
        self.evseID = try container.decode(String.self, forKey: .evseID)
        self.clearinghouseID = try container.decodeIfPresent(String.self, forKey: .clearinghouseID)
        self.geoChargingPointEntrance = try container.decode(GeoCoordinates.self, forKey: .geoChargingPointEntrance)
        self.openingTimes = try container.decodeIfPresent([OpeningTime].self, forKey: .openingTimes)
        self.chargingStationLocationReference = try container.decodeIfPresent(String.self, forKey: .chargingStationLocationReference)
        self.energySource = try container.decodeIfPresent(String.self, forKey: .energySource)
        self.environmentalImpact = try container.decodeIfPresent(String.self, forKey: .environmentalImpact)
        self.locationImage = try container.decodeIfPresent(String.self, forKey: .locationImage)
        self.suboperatorName = try container.decodeIfPresent(String.self, forKey: .suboperatorName)
        self.maxCapacity = try container.decodeIfPresent(Double.self, forKey: .maxCapacity)
        self.additionalInfo = try container.decodeIfPresent(String.self, forKey: .additionalInfo)
        self.chargingPoolID = try container.decodeIfPresent(String.self, forKey: .chargingPoolID)
        self.dynamicPowerLevel = try container.decodeIfPresent(Bool.self, forKey: .dynamicPowerLevel)
        self.hardwareManufacturer = try container.decodeIfPresent(String.self, forKey: .hardwareManufacturer)
        
        // Handle lastUpdate - can be Date string (ISO8601) or Unix timestamp (Double)
        // Try Date string first (most common), then fallback to Unix timestamp
        if let dateValue = try? container.decodeIfPresent(Date.self, forKey: .lastUpdate) {
            self.lastUpdate = dateValue
        } else if let timestamp = try? container.decode(Double.self, forKey: .lastUpdate) {
            self.lastUpdate = Date(timeIntervalSince1970: timestamp / 1000) // Convert milliseconds to seconds
        } else {
            self.lastUpdate = nil
        }
    }
    
    // Custom encoding
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(accessibilityLocation, forKey: .accessibilityLocation)
        try container.encode(address, forKey: .address)
        try container.encode(authenticationModes, forKey: .authenticationModes)
        try container.encode(calibrationLawDataAvailability, forKey: .calibrationLawDataAvailability)
        try container.encode(chargingFacilities, forKey: .chargingFacilities)
        try container.encode(chargingStationNames, forKey: .chargingStationNames)
        try container.encode(dynamicInfoAvailable, forKey: .dynamicInfoAvailable)
        try container.encode(hotlinePhoneNumber, forKey: .hotlinePhoneNumber)
        try container.encodeIfPresent(hubOperatorID, forKey: .hubOperatorID)
        try container.encode(isOpen24Hours, forKey: .isOpen24Hours)
        try container.encodeIfPresent(paymentOptions, forKey: .paymentOptions)
        try container.encode(plugs, forKey: .plugs)
        try container.encode(renewableEnergy, forKey: .renewableEnergy)
        try container.encode(valueAddedServices, forKey: .valueAddedServices)
        try container.encodeIfPresent(deltaType, forKey: .deltaType)
        try container.encode(accessibility, forKey: .accessibility)
        try container.encode(chargingStationId, forKey: .chargingStationId)
        try container.encode(geoCoordinates, forKey: .geoCoordinates)
        try container.encode(evseID, forKey: .evseID)
        try container.encodeIfPresent(clearinghouseID, forKey: .clearinghouseID)
        try container.encode(geoChargingPointEntrance, forKey: .geoChargingPointEntrance)
        try container.encodeIfPresent(openingTimes, forKey: .openingTimes)
        try container.encodeIfPresent(chargingStationLocationReference, forKey: .chargingStationLocationReference)
        try container.encodeIfPresent(energySource, forKey: .energySource)
        try container.encodeIfPresent(environmentalImpact, forKey: .environmentalImpact)
        try container.encodeIfPresent(locationImage, forKey: .locationImage)
        try container.encodeIfPresent(suboperatorName, forKey: .suboperatorName)
        try container.encodeIfPresent(maxCapacity, forKey: .maxCapacity)
        try container.encodeIfPresent(additionalInfo, forKey: .additionalInfo)
        try container.encodeIfPresent(chargingPoolID, forKey: .chargingPoolID)
        try container.encodeIfPresent(dynamicPowerLevel, forKey: .dynamicPowerLevel)
        try container.encodeIfPresent(hardwareManufacturer, forKey: .hardwareManufacturer)
        try container.encodeIfPresent(lastUpdate, forKey: .lastUpdate)
    }
}

