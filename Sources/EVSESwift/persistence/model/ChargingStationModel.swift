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

/// A SwiftData persistent model for electric vehicle charging station data.
///
/// `ChargingStationModel` is the persistence layer representation of a charging station,
/// storing all relevant information in the local database. This model is separate from
/// the API transfer object ``ChargingStation`` and is optimized for SwiftData storage.
///
/// ## Usage
/// ```swift
/// let station = ChargingStationModel(
///     chargingStationId: "CH-ABC-123",
///     evseID: "CH*ABC*E123",
///     accessibility: "Free publicly accessible"
/// )
/// modelContext.insert(station)
/// try modelContext.save()
/// ```
@Model
final class ChargingStationModel {
    
    // MARK: - Core Identifiers
    
    /// The unique identifier for this charging station.
    @Attribute(.unique) var chargingStationId: String
    
    /// The EVSE (Electric Vehicle Supply Equipment) identifier.
    var evseID: String
    
    /// The clearinghouse identifier for roaming networks.
    var clearinghouseID: String?
    
    /// The Hub operator identifier for Hubject-compatible stations.
    var hubOperatorID: String?
    
    /// The identifier for the charging pool this station belongs to.
    var chargingPoolID: String?
    
    // MARK: - Location Information
    
    /// The physical address of the charging station.
    @Relationship(deleteRule: .cascade) var address: AddressModel?
    
    /// Geographic coordinates in Google Maps format (latitude,longitude).
    var coordinates: String?
    
    /// Geographic coordinates of the charging point entrance.
    var entranceCoordinates: String?
    
    /// Additional location reference information.
    var locationReference: String?
    
    /// URL or reference to an image of the location.
    var locationImage: String?
    
    // MARK: - Accessibility & Availability
    
    /// Information about accessibility (e.g., "Free publicly accessible", "onStreet").
    var accessibility: String
    
    /// Additional information about accessibility at the location.
    var accessibilityLocation: String?
    
    /// Indicates whether the charging station is open 24 hours.
    var isOpen24Hours: Bool
    
    /// Indicates whether dynamic information is available for this station.
    var dynamicInfoAvailable: String
    
    /// The maximum capacity or parking spaces at this charging station.
    var maxCapacity: Double?
    
    // MARK: - Charging Capabilities
    
    /// Comma-separated list of plug types available (e.g., "Type2,CCS,CHAdeMO").
    var plugs: String
    
    /// Comma-separated list of authentication modes (e.g., "NFC,RFID,APP").
    var authenticationModes: String
    
    /// Comma-separated list of payment options (e.g., "CREDIT_CARD,DEBIT_CARD").
    var paymentOptions: String?
    
    /// Indicates whether the station provides calibration law data.
    var calibrationLawDataAvailability: String
    
    /// Indicates whether the station uses renewable energy sources.
    var renewableEnergy: Bool
    
    /// The primary energy source for this charging station.
    var energySource: String?
    
    /// Environmental impact information.
    var environmentalImpact: String?
    
    /// The current dynamic power level availability.
    var dynamicPowerLevel: Bool?
    
    // MARK: - Station Information
    
    /// The primary name of the charging station.
    var stationName: String?
    
    /// The phone number for station support or assistance.
    var hotlinePhoneNumber: String
    
    /// Comma-separated list of value-added services (e.g., "WiFi,RESTAURANT").
    var valueAddedServices: String?
    
    /// Additional descriptive information about the charging station.
    var additionalInfo: String?
    
    /// The name of the suboperator if different from the main operator.
    var suboperatorName: String?
    
    /// The manufacturer of the charging hardware.
    var hardwareManufacturer: String?
    
    // MARK: - Metadata
    
    /// The type of data change (for update tracking).
    var deltaType: String?
    
    /// The date this record was last updated.
    var lastUpdated: Date
    
    // MARK: - Relationships
    
    /// The charging facilities available at this station.
    @Relationship(deleteRule: .cascade) var facilities: [ChargingFacilityModel]?
    
    /// The names of the charging station in different languages.
    @Relationship(deleteRule: .cascade) var stationNames: [ChargingStationNameModel]?
    
    /// The opening hours or availability information for the station.
    @Relationship(deleteRule: .cascade) var openingTimes: [OpeningTimeModel]?
    
    // MARK: - Initialization
    
    /// Creates a new charging station model with the required core information.
    ///
    /// - Parameters:
    ///   - chargingStationId: The unique identifier for the charging station.
    ///   - evseID: The EVSE identifier.
    ///   - accessibility: The accessibility information.
    ///   - isOpen24Hours: Whether the station is open 24 hours.
    ///   - plugs: Available plug types as comma-separated string.
    ///   - authenticationModes: Authentication modes as comma-separated string.
    ///   - hotlinePhoneNumber: The support phone number.
    ///   - calibrationLawDataAvailability: Calibration law data availability.
    ///   - dynamicInfoAvailable: Whether dynamic info is available.
    ///   - renewableEnergy: Whether renewable energy is used.
    init(
        chargingStationId: String,
        evseID: String,
        accessibility: String,
        isOpen24Hours: Bool = false,
        plugs: String = "",
        authenticationModes: String = "",
        hotlinePhoneNumber: String = "",
        calibrationLawDataAvailability: String = "",
        dynamicInfoAvailable: String = "",
        renewableEnergy: Bool = false
    ) {
        self.chargingStationId = chargingStationId
        self.evseID = evseID
        self.accessibility = accessibility
        self.isOpen24Hours = isOpen24Hours
        self.plugs = plugs
        self.authenticationModes = authenticationModes
        self.hotlinePhoneNumber = hotlinePhoneNumber
        self.calibrationLawDataAvailability = calibrationLawDataAvailability
        self.dynamicInfoAvailable = dynamicInfoAvailable
        self.renewableEnergy = renewableEnergy
        self.lastUpdated = Date()
    }
}

// MARK: - Conversion Extensions

extension ChargingStationModel {
    /// Creates a SwiftData model from an API transfer object.
    ///
    /// This convenience initializer maps all fields from the API's `ChargingStation`
    /// struct to the persistent model format.
    ///
    /// - Parameter station: The API charging station object to convert.
    convenience init(from station: ChargingStation) {
        self.init(
            chargingStationId: station.chargingStationId,
            evseID: station.evseID,
            accessibility: station.accessibility,
            isOpen24Hours: station.isOpen24Hours,
            plugs: station.plugs.joined(separator: ","),
            authenticationModes: station.authenticationModes.joined(separator: ","),
            hotlinePhoneNumber: station.hotlinePhoneNumber,
            calibrationLawDataAvailability: station.calibrationLawDataAvailability,
            dynamicInfoAvailable: station.dynamicInfoAvailable,
            renewableEnergy: station.renewableEnergy
        )
        
        // Create address model
        self.address = AddressModel(from: station.address)
        
        // Optional fields
        self.clearinghouseID = station.clearinghouseID
        self.hubOperatorID = station.hubOperatorID
        self.chargingPoolID = station.chargingPoolID
        self.coordinates = station.geoCoordinates.google
        self.entranceCoordinates = station.geoChargingPointEntrance.google
        self.locationReference = station.chargingStationLocationReference
        self.locationImage = station.locationImage
        self.accessibilityLocation = station.accessibilityLocation
        self.maxCapacity = station.maxCapacity
        self.paymentOptions = station.paymentOptions?.joined(separator: ",")
        self.energySource = station.energySource
        self.environmentalImpact = station.environmentalImpact
        self.dynamicPowerLevel = station.dynamicPowerLevel
        self.stationName = station.chargingStationNames.first?.value
        self.valueAddedServices = station.valueAddedServices?.joined(separator: ",")
        self.additionalInfo = station.additionalInfo
        self.suboperatorName = station.suboperatorName
        self.hardwareManufacturer = station.hardwareManufacturer
        self.deltaType = station.deltaType
        
        // Convert charging facilities
        self.facilities = station.chargingFacilities.map { ChargingFacilityModel(from: $0) }
        
        // Convert station names (multilingual support)
        self.stationNames = station.chargingStationNames.map { ChargingStationNameModel(from: $0) }
        
        // Convert opening times
        if let openingTimes = station.openingTimes {
            self.openingTimes = openingTimes.map { OpeningTimeModel(from: $0) }
        }
    }
}
