


import Foundation

/// Charging Point Operator with real-time data support
///
/// Represents a charging point operator that provides real-time data
/// through the ich-tanke-strom.ch infrastructure.
public struct ChargingPointOperator: Codable, Hashable, Sendable {
    /// The operator ID used in the ich-tanke-strom.ch infrastructure
    public let operatorID: String
    
    /// The display name of the charging point operator
    public let name: String
    
    /// The date when real-time data became available
    public let startDate: Date?
    
    /// Networks included under this operator
    public let includedNetworks: [String]
    
    /// Indicates whether this operator provides real-time data
    public let withRealTimeData: Bool
    
    public init(operatorID: String, name: String, startDate: Date?, includedNetworks: [String] = [], withRealTimeData: Bool = true) {
        self.operatorID = operatorID
        self.name = name
        self.startDate = startDate
        self.includedNetworks = includedNetworks
        self.withRealTimeData = withRealTimeData
    }
}

extension ChargingPointOperator {
    /// Helper to parse date from DD.MM.YYYY format
    private static func parseDate(_ dateString: String) -> Date {
        guard !dateString.isEmpty else { return Date() }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: dateString) ?? Date()   
    }
    
    /// All charging point operators (with and without real-time data)
    public static let all: [ChargingPointOperator] = [
        // Operators with real-time data
        ChargingPointOperator(operatorID: "CH*AIL", name: "AIL", startDate: parseDate("30.11.2022")),
        ChargingPointOperator(operatorID: "CH*CCC", name: "Move", startDate: parseDate("25.09.2019")),
        ChargingPointOperator(operatorID: "CH*CPI", name: "Chargepoint", startDate: parseDate("19.06.2023")),
        ChargingPointOperator(operatorID: "CH*ECU", name: "eCarUp", startDate: parseDate("20.07.2020")),
        ChargingPointOperator(operatorID: "CH*ENMOBILECHARGE", name: "en mobilecharge", startDate: parseDate("14.06.2021")),
        ChargingPointOperator(operatorID: "CH*EVAEMOBILITAET", name: "EVA E-Mobilität", startDate: parseDate("14.06.2021")),
        ChargingPointOperator(operatorID: "CH*EWACHARGE", name: "EWAcharge", startDate: parseDate("14.06.2021")),
        ChargingPointOperator(operatorID: "CH*FASTNED", name: "Fastned", startDate: parseDate("20.01.2021")),
        ChargingPointOperator(operatorID: "CHEVP", name: "GreenMotion", startDate: parseDate("25.09.2019")),
        ChargingPointOperator(operatorID: "CH*IBC", name: "IBC", startDate: parseDate("14.06.2021")),
        ChargingPointOperator(operatorID: "CH*MOBILECHARGE", name: "mobilecharge", startDate: parseDate("14.06.2021")),
        ChargingPointOperator(operatorID: "CH*MOBIMOEMOBILITY", name: "Mobimo emobility", startDate: parseDate("14.06.2021")),
        ChargingPointOperator(operatorID: "CH*PACEMOBILITY", name: "PAC e-moblity", startDate: parseDate("14.06.2021")),
        ChargingPointOperator(operatorID: "CH*PARKCHARGE", name: "PARK & CHARGE", startDate: parseDate("14.06.2021")),
        ChargingPointOperator(operatorID: "CH*PNR", name: "PLUG'N ROLL", startDate: parseDate("12.09.2023")),
        ChargingPointOperator(operatorID: "CH*REP", name: "PLUG'N ROLL", startDate: parseDate("25.09.2019")),
        ChargingPointOperator(operatorID: "CH*SCH", name: "Saascharge", startDate: parseDate("22.05.2023")),
        ChargingPointOperator(operatorID: "CH*SHE", name: "Shell Recharge", startDate: parseDate("29.06.2023")),
        ChargingPointOperator(operatorID: "CH*SCHARGE", name: "S-Charge", startDate: parseDate("14.06.2021")),
        ChargingPointOperator(operatorID: "CH*SWISSCHARGE", name: "Swisscharge", startDate: parseDate("25.09.2019"), includedNetworks: ["GoFast"]),
        ChargingPointOperator(operatorID: "CH*TAE", name: "Matterhorn Terminal Täsch", startDate: parseDate("30.11.2022"), includedNetworks: ["ewz"]),
        
        // Operators without real-time data
        ChargingPointOperator(operatorID: "CH*AVIA", name: "AVIA", startDate: nil, withRealTimeData: false),
        ChargingPointOperator(operatorID: "CH*DIE", name: "Stadt Dietikon", startDate: parseDate("05.05.2020"), withRealTimeData: false),
        ChargingPointOperator(operatorID: "CH*EBS", name: "ebs Energie AG", startDate: parseDate("16.01.2020"), withRealTimeData: false),
        ChargingPointOperator(operatorID: "CH*EWD", name: "EWD Elektrizitaetswerk Davos AG", startDate: parseDate("09.09.2020"), withRealTimeData: false),
        ChargingPointOperator(operatorID: "CH*EWO", name: "Elektrizitätswerk Obwalden", startDate: parseDate("16.12.2019"), withRealTimeData: false),
        ChargingPointOperator(operatorID: "CH*HER", name: "Elektrizitätswerk Herrliberg", startDate: parseDate("01.05.2020"), withRealTimeData: false),
        ChargingPointOperator(operatorID: "CH*ION", name: "Ionity", startDate: parseDate("09.09.2020"), withRealTimeData: false),
        ChargingPointOperator(operatorID: "CH*LIDL", name: "Lidl Schweiz", startDate: parseDate("13.11.2019"), withRealTimeData: false),
        ChargingPointOperator(operatorID: "CH*MIG", name: "Migrol", startDate: parseDate("15.03.2021"), withRealTimeData: false),
        ChargingPointOperator(operatorID: "CH*TES", name: "Tesla Supercharger", startDate: parseDate("28.02.2020"), withRealTimeData: false)
    ]
    
    /// Find an operator by ID
    public static func findByID(_ id: String) -> ChargingPointOperator? {
        return all.first { $0.operatorID == id }
    }
    
    /// Find operators by name (case-insensitive partial match)
    public static func findByName(_ name: String) -> [ChargingPointOperator] {
        let lowercasedName = name.lowercased()
        return all.filter { $0.name.lowercased().contains(lowercasedName) }
    }
    
    /// Returns all operators with real-time data
    public static var withRealTimeData: [ChargingPointOperator] {
        return all.filter { $0.withRealTimeData }
    }
}