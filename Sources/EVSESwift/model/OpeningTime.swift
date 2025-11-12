// MIT License
//
// OpeningTime model representing business hours for a given day.
// Matches JSON like:
// {
//   "Period": [{"begin": "08:00", "end": "17:30"}],
//   "on": "Monday"
// }

import Foundation

/// Day of week for opening times.
public enum Day: Sendable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    case workdays
    case everyday
    case weekend
    case unknown(String)
}

extension Day: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "monday": self = .monday
        case "tuesday": self = .tuesday
        case "wednesday": self = .wednesday
        case "thursday": self = .thursday
        case "friday": self = .friday
        case "saturday": self = .saturday
        case "sunday": self = .sunday
        case "workdays", "weekdays": self = .workdays
        case "everyday", "daily", "all days", "alldays": self = .everyday
        case "weekend", "weekends": self = .weekend
        default: self = .unknown(raw)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .monday: try container.encode("Monday")
        case .tuesday: try container.encode("Tuesday")
        case .wednesday: try container.encode("Wednesday")
        case .thursday: try container.encode("Thursday")
        case .friday: try container.encode("Friday")
        case .saturday: try container.encode("Saturday")
        case .sunday: try container.encode("Sunday")
        case .workdays: try container.encode("Workdays")
        case .everyday: try container.encode("Everyday")
        case .weekend: try container.encode("Weekend")
        case .unknown(let raw): try container.encode(raw)
        }
    }
}

/// A time window with a begin and end time (HH:mm format as provided).
public struct Period: Codable, Sendable {
    public let begin: String
    public let end: String
}

/// Opening times for a specific day, containing one or more periods.
public struct OpeningTime: Codable, Sendable {
    public let period: [Period]
    public let on: Day

    enum CodingKeys: String, CodingKey {
        case period = "Period"
        case on = "on"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.on = try container.decode(Day.self, forKey: .on)
        // Period may be a single object or an array
        if let periods = try? container.decode([Period].self, forKey: .period) {
            self.period = periods
        } else {
            let single = try container.decode(Period.self, forKey: .period)
            self.period = [single]
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(on, forKey: .on)
        try container.encode(period, forKey: .period)
    }
}
