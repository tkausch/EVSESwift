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

/// A SwiftData persistent model for multilingual charging station names.
///
/// `ChargingStationNameModel` stores the name of a charging station in a specific language,
/// supporting multilingual station naming (e.g., German, French, Italian).
@Model
public final class ChargingStationNameModel {
    
    /// The language code of the name (e.g., "de", "fr", "it", "en").
    public var lang: String
    
    /// The charging station name in the specified language.
    public var value: String
    
    /// The charging station this name belongs to.
    public var station: ChargingStationModel?
    
    // MARK: - Initialization
    
    /// Creates a new charging station name model.
    ///
    /// - Parameters:
    ///   - lang: The language code.
    ///   - value: The station name in the specified language.
    init(lang: String, value: String) {
        self.lang = lang
        self.value = value
    }
    
    /// Creates a SwiftData model from an API transfer object.
    ///
    /// - Parameter name: The API charging station name object to convert.
    convenience init(from name: ChargingStationName) {
        self.init(lang: name.lang, value: name.value)
    }
}
