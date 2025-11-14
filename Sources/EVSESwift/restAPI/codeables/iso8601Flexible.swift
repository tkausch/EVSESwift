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

/// A description
extension JSONDecoder.DateDecodingStrategy {
    /// A flexible ISO8601 strategy that supports dates with or without fractional seconds and timezone.
    ///
    /// Supports three formats:
    /// 1. ISO8601 with fractional seconds and timezone: "2025-09-30T02:15:16.965Z"
    /// 2. ISO8601 with timezone: "2025-09-30T02:15:16Z"
    /// 3. ISO8601 without timezone: "2022-10-26T10:02:07" (assumes UTC)
    static let iso8601Flexible = custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        // Try with fractional seconds first
        let isoFormatterWithFraction = ISO8601DateFormatter()
        isoFormatterWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatterWithFraction.date(from: dateString) {
            return date
        }

        // Fallback: try without fractional seconds but with timezone
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        // Fallback: try without timezone (assumes UTC)
        let isoFormatterNoTZ = ISO8601DateFormatter()
        isoFormatterNoTZ.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime, .withDashSeparatorInDate]
        isoFormatterNoTZ.timeZone = TimeZone(secondsFromGMT: 0) // Assume UTC

        if let date = isoFormatterNoTZ.date(from: dateString) {
            return date
        }

        // Still failed? Throw
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid ISO8601 date: \(dateString)"
        )
    }
}