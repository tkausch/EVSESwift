# EVSESwift

A Swift library for working with the National Data Infrastructure for Electromobility (ich-tanke-strom.ch) — Switzerland's open data platform for EV charging stations.

This package provides public, type-safe models and utilities for decoding and using charging station data. It’s used by and compatible with the data behind the recharge-my-car.ch map.

## Highlights

- Public Swift models for EVSE data: EVSEData → EVSEDataRecord → ChargingStation → Address, ChargingFacility, GeoCoordinates, ChargingStationName
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

## Decoding examples

### Decode a full EVSE dataset

```swift
import EVSESwift

let decoder = JSONDecoder()
// If your dataset contains ISO8601 strings you want to decode elsewhere:
// decoder.dateDecodingStrategy = .iso8601Flexible

let data = try Data(contentsOf: urlToEVSEDataJson)
let root = try decoder.decode(EVSEData.self, from: data)

print("Loaded \(root.evseData.count) EVSE data records")
if let station = root.evseData.first?.evseDataRecord.first {
    print("First station id: \(station.chargingStationId)")
    print("Plugs: \(station.plugs.joined(separator: ", "))")
}
```

### Fetch JSON and decode using SwiftRestRequests

```swift
import EVSESwift
import SwiftRestRequests

let request = RestRequest(url: "https://example.com/EVSEData.json")
request.get { result in
    switch result {
    case .success(let response):
        do {
            let decoder = JSONDecoder()
            let root = try decoder.decode(EVSEData.self, from: response.data)
            print("Stations: \(root.evseData.first?.evseDataRecord.count ?? 0)")
        } catch {
            print("Decoding failed: \(error)")
        }
    case .failure(let error):
        print("Request failed: \(error)")
    }
}
```

## Data access docs

For official API details, see:

- How to query the ich-tanke-strom.ch Feature API
  https://github.com/SFOE/ichtankestrom_Documentation/blob/main/How%20to%20query%20ich%20tanke%20strom.md
- Access/Download the data
  https://github.com/SFOE/ichtankestrom_Documentation/blob/main/Access%20Download%20the%20data.md

## License

MIT — see LICENSE.

© 2025 Thomas Kausch and EVSESwift Contributors

## Related resources

- ich-tanke-strom.ch Documentation: https://github.com/SFOE/ichtankestrom_Documentation
- recharge-my-car.ch Map: https://www.recharge-my-car.ch/
- Open Data on opendata.swiss: https://opendata.swiss/en/dataset/ladestationen-fuer-elektroautos
- Swiss Office of Energy (SFOE): https://www.bfe.admin.ch/

## Contributing

Issues and PRs are welcome.
