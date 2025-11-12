# EVSESwift

A Swift library for accessing the **National Data Infrastructure for Electromobility (ich-tanke-strom.ch)** - Switzerland's open data platform for electric vehicle charging stations.

This library provides type-safe Swift models and utilities for consuming the ich-tanke-strom.ch API, which powers the [recharge-my-car.ch](https://www.recharge-my-car.ch/) map.

## Overview

EVSESwift makes it easy to work with Swiss electric vehicle charging station data in your Swift applications. It includes:

- **Type-safe data models** for charging stations, facilities, and locations
- **Automatic JSON decoding** with proper handling of Swiss-specific naming conventions
- **Easy integration** with your iOS, macOS, or other Swift projects

## About ich-tanke-strom.ch

[ich-tanke-strom.ch](https://www.recharge-my-car.ch/) is the National Data Infrastructure for Electromobility maintained by the Swiss Office of Energy (SFOE). It provides:

- Real-time data on electric vehicle charging points across Switzerland
- Open data access for developers and public services
- Integration of data from multiple charging point operators (CPOs)
- Multi-language support (German, French, Italian, English)

The underlying data is available as [Open Data on opendata.swiss](https://opendata.swiss/en/dataset/ladestationen-fuer-elektroautos).

## Installation

### Swift Package Manager

Add EVSESwift to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/thomaskausch/EVSESwift.git", from: "1.0.0")
]
```

Or in Xcode: File → Add Packages → Enter the repository URL.

## Requirements

- Swift 5.7+
- macOS 12.0+
- iOS 13.0+ (supported platforms can be extended)

## Usage

### Basic Data Models

EVSESwift provides several core models:

#### ChargingStation

The main model representing an electric vehicle charging station:

```swift
struct ChargingStation: Codable {
    let chargingStationId: String
    let address: Address
    let geoCoordinates: GeoCoordinates
    let chargingFacilities: [ChargingFacility]
    let authenticationModes: [String]
    let paymentOptions: [String]?
    let isOpen24Hours: Bool?
    let renewableEnergy: Bool?
    let lastUpdate: Date
    // ... and more properties
}
```

#### Address

Location information for a charging station:

```swift
struct Address: Codable {
    let street: String?
    let houseNum: String?
    let postalCode: String?
    let city: String?
    let region: String?
    let country: String?
    let timeZone: String?
    let floor: String?
    let parkingSpot: String?
    let parkingFacility: String?
}
```

#### ChargingFacility

Details about a specific charging facility at a station:

```swift
struct ChargingFacility: Codable {
    let power: Double?           // Power output in kW
    let powerType: String?       // Type of charging connection
}
```

### Example

```swift
import EVSESwift

// Decode charging station data
let jsonData = """
{
    "ChargingStationId": "123",
    "Address": {
        "City": "Zurich",
        "Country": "Switzerland"
    },
    "GeoCoordinates": {
        "Latitude": 47.3769,
        "Longitude": 8.5469
    },
    "ChargingFacilities": [
        {"power": 22.0, "powertype": "AC"}
    ],
    "AuthenticationModes": ["NFC"],
    "Plugs": ["Type2"]
}
""".data(using: .utf8)!

let decoder = JSONDecoder()
let station = try decoder.decode(ChargingStation.self, from: jsonData)

print("Station \(station.chargingStationId) is located in \(station.address.city ?? "Unknown")")
```

## Data Structures

### Key Properties

**ChargingStation:**
- `chargingStationId`: Unique identifier for the station
- `address`: Complete address information
- `geoCoordinates`: GPS coordinates for mapping
- `chargingFacilities`: Array of available charging facilities
- `authenticationModes`: Methods to authenticate (e.g., NFC, app)
- `paymentOptions`: Accepted payment methods
- `isOpen24Hours`: Availability information
- `renewableEnergy`: Whether renewable energy is used
- `lastUpdate`: Timestamp of last data update

**Address:**
All address fields are optional to handle various data completeness scenarios.

**ChargingFacility:**
- `power`: Charging power in kilowatts (kW)
- `powerType`: Connection type (AC, DC, etc.)

## Data Access

For information on how to query the ich-tanke-strom.ch API directly, see:

- [How to query the ich-tanke-strom.ch Feature API](https://github.com/SFOE/ichtankestrom_Documentation/blob/main/How%20to%20query%20ich%20tanke%20strom.md)
- [Access/Download the data](https://github.com/SFOE/ichtankestrom_Documentation/blob/main/Access%20Download%20the%20data.md)

## License

This library is licensed under the MIT License. See the LICENSE file for details.

Copyright © 2025 Thomas Kausch and EVSESwift Contributors

## Related Resources

- [ich-tanke-strom.ch Documentation](https://github.com/SFOE/ichtankestrom_Documentation)
- [recharge-my-car.ch Map](https://www.recharge-my-car.ch/)
- [Open Data on opendata.swiss](https://opendata.swiss/en/dataset/ladestationen-fuer-elektroautos)
- [Swiss Office of Energy (SFOE)](https://www.bfe.admin.ch/)

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Support

For questions about the ich-tanke-strom.ch infrastructure and data, visit the official documentation. For library-specific issues, please open an issue on this repository.
