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

/// A SwiftData persistent model for opening time periods.
///
/// `PeriodModel` represents a time window during which a charging station is accessible,
/// with begin and end times in HH:mm format.
@Model
final class PeriodModel {
    
    /// The begin time in HH:mm format (e.g., "08:00").
    var begin: String
    
    /// The end time in HH:mm format (e.g., "17:30").
    var end: String
    
    /// The opening time this period belongs to.
    var openingTime: OpeningTimeModel?
    
    // MARK: - Initialization
    
    /// Creates a new period model.
    ///
    /// - Parameters:
    ///   - begin: The begin time in HH:mm format.
    ///   - end: The end time in HH:mm format.
    init(begin: String, end: String) {
        self.begin = begin
        self.end = end
    }
    
    /// Creates a SwiftData model from an API transfer object.
    ///
    /// - Parameter period: The API period object to convert.
    convenience init(from period: Period) {
        self.init(begin: period.begin, end: period.end)
    }
}

/// A SwiftData persistent model for opening times.
///
/// `OpeningTimeModel` represents the operating hours for a charging station on a specific day,
/// containing one or more time periods when the station is accessible.
@Model
final class OpeningTimeModel {
    
    /// The day of the week (stored as string for compatibility with Day enum).
    ///
    /// Common values: "Monday", "Tuesday", "Wednesday", "Thursday", "Friday",
    /// "Saturday", "Sunday", "Workdays", "Everyday", "Weekend"
    var dayOfWeek: String
    
    /// The time periods when the station is accessible on this day.
    @Relationship(deleteRule: .cascade) var periods: [PeriodModel]?
    
    /// The charging station these opening times belong to.
    var station: ChargingStationModel?
    
    // MARK: - Initialization
    
    /// Creates a new opening time model.
    ///
    /// - Parameters:
    ///   - dayOfWeek: The day of the week as a string.
    ///   - periods: The time periods for this day.
    init(dayOfWeek: String, periods: [PeriodModel] = []) {
        self.dayOfWeek = dayOfWeek
        self.periods = periods
    }
    
    /// Creates a SwiftData model from an API transfer object.
    ///
    /// - Parameter openingTime: The API opening time object to convert.
    convenience init(from openingTime: OpeningTime) {
        let dayString: String
        switch openingTime.on {
        case .monday: dayString = "Monday"
        case .tuesday: dayString = "Tuesday"
        case .wednesday: dayString = "Wednesday"
        case .thursday: dayString = "Thursday"
        case .friday: dayString = "Friday"
        case .saturday: dayString = "Saturday"
        case .sunday: dayString = "Sunday"
        case .workdays: dayString = "Workdays"
        case .everyday: dayString = "Everyday"
        case .weekend: dayString = "Weekend"
        case .unknown(let raw): dayString = raw
        }
        
        let periodModels = openingTime.period.map { PeriodModel(from: $0) }
        self.init(dayOfWeek: dayString, periods: periodModels)
    }
}
