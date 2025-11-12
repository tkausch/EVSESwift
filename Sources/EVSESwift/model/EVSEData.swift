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

/// The root container for EVSE (Electric Vehicle Supply Equipment) data from the ich-tanke-strom.ch API.
///
/// `EVSEData` is the top-level wrapper structure that contains a collection of EVSE data records.
/// This structure is used when parsing API responses that contain multiple charging station records.
///
/// ## Overview
///
/// EVSE stands for "Electric Vehicle Supply Equipment" and refers to the infrastructure that supplies
/// electrical power to electric vehicles. This structure wraps the array of EVSE data records returned
/// from the ich-tanke-strom.ch Feature API.
public struct EVSEData : Codable {
    /// An array of EVSE data records.
    ///
    /// Each record contains detailed information about a charging station and its facilities,
    /// as returned from the ich-tanke-strom.ch API.
    let evseData: [EVSEDataRecord]

    enum CodingKeys: String, CodingKey {
        case evseData = "EVSEData"
    }
}   