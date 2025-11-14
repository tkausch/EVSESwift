# EVSESwift

A Swift library for working with the National Data Infrastructure for Electromobility (ich-tanke-strom.ch) — Switzerland's open data platform for EV charging stations.

This package provides public, type-safe models and utilities for decoding and using charging station data. It’s used by and compatible with the data behind the recharge-my-car.ch map.

## Highlights

- Public Swift models for EVSE data: EVSEData → EVSEDataRecord → ChargingStation → Address, ChargingFacility, GeoCoordinates, ChargingStationName
- **Persistent caching with SwiftData**: Automatically caches charging stations locally for offline access and improved performance
- Robust JSON decoding that tolerates real‑world inconsistencies
  - Booleans encoded as strings (e.g. "IsOpen24Hours": "true")
  - Numbers encoded as strings (e.g. power: "22.0")
  - Missing/nullable fields handled via optionals
- Ready for iOS and macOS projects via Swift Package Manager

## Installation

### Swift Package Manager

Add EVSESwift to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tkausch/EVSESwift.git", branch: "main")
]
```

Then add `EVSESwift` as a dependency of your target.

Note: This package also depends on `SwiftRestRequests` (>= 1.7.0) for simple HTTP usage examples.

## Requirements

- Swift 5.7+
- macOS 12.0+
- iOS 13.0+

## Public Models (simplified)

```swift
public struct EVSEData: Codable {
    public let evseData: [EVSEDataRecord]
}

public struct EVSEDataRecord: Codable {
    public let evseDataRecord: [ChargingStation]
}

public struct ChargingStation: Codable {
    public let chargingStationId: String
    public let address: Address
    public let geoCoordinates: GeoCoordinates
    public let chargingFacilities: [ChargingFacility]
    public let authenticationModes: [String]
    public let paymentOptions: [String]?         // Optional
    public let isOpen24Hours: Bool               // Accepts Bool or "true"/"false"
    public let renewableEnergy: Bool
    public let plugs: [String]
    public let valueAddedServices: [String]?     // Optional
    // ... see source for all properties
}

public struct ChargingFacility: Codable {
    public let power: Double?        // May be missing or encoded as String
    public let powerType: String?
    public let amperage: Double?
    public let voltage: Double?
}

public struct Address: Codable {
    public let street: String?
    public let houseNum: String?
    public let postalCode: String?
    public let city: String
    public let region: String?
    public let country: String
    // ... additional optional fields
}

public struct GeoCoordinates: Codable {
    public let google: String?   // Optional string as provided by data source
}
```

Notes:
- `lastUpdate` has been removed from the models to simplify parsing.
- `IsHubjectCompatible` has been removed in favor of a leaner model.

## Usage Examples

### Basic Usage

The simplest way to fetch charging stations with persistent caching:

```swift
import EVSESwift

// Create manager (uses persistent SwiftData cache)
let manager = try ESVSEManager()

// First call fetches from API and caches
let stations = try await manager.getChargingStations()
print("Loaded \(stations.count) charging stations")

// Access station data
for station in stations.prefix(5) {
    print("Station: \(station.stationName ?? "Unnamed")")
    print("  Location: \(station.address?.city ?? "Unknown")")
    print("  Plugs: \(station.plugs)")
    if let facilities = station.facilities {
        print("  Power: \(facilities.first?.power ?? 0) kW")
    }
}

// Subsequent calls return cached models instantly (no network)
let cachedStations = try await manager.getChargingStations()

// Force refresh from API
let freshStations = try await manager.getChargingStations(forceRefresh: true)
```

### Querying Stations

ESVSEManager provides convenient query methods:

```swift
let manager = try ESVSEManager()

// Query by city
let zurichStations = try await manager.findByCity("Zürich")
print("Found \(zurichStations.count) stations in Zürich")

// Query by country
let swissStations = try await manager.findByCountry("CHE")

// Query by postal code
let localStations = try await manager.findByPostalCode("8001")

// Find stations with specific plug type
let type2Stations = try await manager.findByPlugType("Type2")
let ccsStations = try await manager.findByPlugType("CCS")

// Find 24-hour accessible stations
let alwaysOpen = try await manager.find24HourStations()

// Find renewable energy stations
let greenStations = try await manager.findRenewableEnergyStations()

// Find specific station by ID
if let station = try await manager.findById("CH*ABC*E123") {
    print("Found: \(station.stationName ?? "Unknown")")
}
```

### Cache Management

```swift
let manager = try ESVSEManager()

// Check cache status
let count = try await manager.getCachedStationCount()
print("Cached stations: \(count)")

// Clear cache (e.g., to force a full refresh)
try await manager.clearCache()

// Fetch fresh data after clearing
let fresh = try await manager.getChargingStations()
```

## Data access docs

For official API details, see:

- [How to query the ich-tanke-strom.ch Feature API](https://github.com/SFOE/ichtankestrom_Documentation/blob/main/How%20to%20query%20ich%20tanke%20strom.md)
- [Access/Download the data](https://github.com/SFOE/ichtankestrom_Documentation/blob/main/Access%20Download%20the%20data.md)

## License

MIT — see LICENSE.

© 2025 Thomas Kausch and EVSESwift Contributors

## Related resources

- [ich-tanke-strom.ch Documentation](https://github.com/SFOE/ichtankestrom_Documentation)
- [recharge-my-car.ch Map](https://www.recharge-my-car.ch/)
- [Open Data on opendata.swiss](https://opendata.swiss/en/dataset/ladestationen-fuer-elektroautos)
- [Swiss Office of Energy (SFOE)](https://www.bfe.admin.ch/)

## Contributing

Issues and PRs are welcome.
