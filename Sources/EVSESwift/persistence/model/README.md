# SwiftData Persistence Models

This directory contains SwiftData `@Model` classes for local persistence of charging station data.

## Overview

The persistence layer is separate from the API transfer objects to maintain clean separation of concerns:

- **API Models** (`/restAPI/models/*.swift`): Structs optimized for JSON decoding from the ich-tanke-strom.ch API
- **Persistence Models** (`/persistence/model/*.swift`): Classes optimized for SwiftData storage

## Models

### ChargingStationModel

The main persistent model for electric vehicle charging stations. Contains all core information including:
- Unique identifiers (station ID, EVSE ID, clearinghouse ID)
- Location details (coordinates, location reference, location image)
- Accessibility and availability information
- Charging capabilities (plugs, authentication, payment options)
- Energy source and environmental data
- Relationships to address and charging facilities

### AddressModel

Represents the physical address of a charging station:
- Street and house number
- Postal code and city
- Region and country
- Time zone
- Parking information (floor, spot, facility)
- One-to-one relationship with ChargingStationModel

### ChargingFacilityModel

Represents individual charging outlets/connectors at a station with power specifications:
- Power output (kW)
- Amperage (A)
- Voltage (V)
- Power type (AC/DC)
- Many-to-one relationship with ChargingStationModel

## Usage Example

```swift
import SwiftData

// 1. Set up the model container
let container = try ModelContainer(
    for: ChargingStationModel.self,
    configurations: ModelConfiguration(isStoredInMemoryOnly: false)
)

// 2. Create a repository
let repository = ChargingStationRepository(modelContainer: container)

// 3. Convert API data to persistence models
let apiData: EVSEData = // ... fetch from API
let stations = apiData.evseData.map { apiStation in
    ChargingStationModel(from: apiStation) // Automatically creates AddressModel
}

// 4. Save to database
try await repository.create(stations)

// 5. Query the database
let zurichStations = try await repository.findByCity("Zürich")
let renewable = try await repository.findRenewableEnergyStations()
let type2Stations = try await repository.findByPlugType("Type2")
let swissStations = try await repository.findByCountry("Switzerland")

// 6. Update a station
if let station = zurichStations.first {
    station.stationName = "Updated Name"
    station.address?.street = "New Street"
    try await repository.update(station)
}
```

## Conversion from API Models

All models provide convenience initializers to convert from API transfer objects:

```swift
// Single station (automatically creates AddressModel and ChargingFacilityModels)
let apiStation: ChargingStation = // ... from API
let persistentStation = ChargingStationModel(from: apiStation)

// Address
let apiAddress: Address = // ... from API  
let persistentAddress = AddressModel(from: apiAddress)

// Facility
let apiFacility: ChargingFacility = // ... from API  
let persistentFacility = ChargingFacilityModel(from: apiFacility)
```

## Repository Pattern

The `ChargingStationRepository` provides:

### Inherited CRUD Operations (from ModelRepository)
- `create(_ item:)` - Create single item
- `create(_ items:)` - Batch create
- `read(predicate:sortDescriptors:)` - Query with filtering
- `read(sortBy:)` - Query with sorting only
- `update(_ item:)` - Update item
- `delete(_ item:)` - Delete item

### Custom Query Methods
- `findByCity(_:)` - Find stations by city name
- `findByCountry(_:)` - Find stations by country
- `findByPostalCode(_:)` - Find stations by postal code
- `findByPlugType(_:)` - Find stations with specific plug type
- `findById(_:)` - Find station by unique ID
- `find24HourStations()` - Find 24/7 accessible stations
- `findRenewableEnergyStations()` - Find renewable energy stations
- `countStations()` - Get total station count
- `deleteAll()` - Clear all stations from database

## Thread Safety

All repository operations are actor-isolated using the `@ModelActor` pattern, ensuring thread-safe access to the SwiftData context. Operations can be called from any async context:

```swift
Task {
    let stations = try await repository.findByCity("Bern")
    // Process stations safely
}
```

## Data Simplifications

The persistence models make some simplifications compared to API models:

1. **Arrays to Strings**: Multi-value fields (plugs, authentication modes, etc.) are stored as comma-separated strings
2. **Separate Address Model**: Address information is modeled as a separate related entity with cascade delete
3. **Coordinate Strings**: Geographic coordinates are stored as Google Maps format strings (latitude,longitude)
4. **Single Name**: Only the first station name is stored (multi-language support simplified)
5. **Simplified Opening Times**: Opening times are not yet persisted (future enhancement)

These simplifications can be extended as needed for your use case.

## Relationships

The models use SwiftData relationships:

- **ChargingStationModel → AddressModel**: One-to-one (cascade delete)
- **ChargingStationModel → ChargingFacilityModel**: One-to-many (cascade delete)
- When a station is deleted, its address and facilities are automatically deleted
