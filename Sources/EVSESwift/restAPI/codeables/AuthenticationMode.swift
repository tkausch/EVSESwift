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

/// Authentication mode values used by `ChargingStation` data.
///
/// These correspond to the authentication method strings used by the ich-tanke-strom.ch data source.
public enum AuthenticationMode: String, Codable, Sendable {
    /// Remote authentication (e.g., via mobile app)
    case remote = "REMOTE"
    
    /// NFC RFID Classic card authentication
    case nfcRfidClassic = "NFC RFID Classic"
    
    /// NFC RFID DESFire card authentication
    case nfcRfidDESFire = "NFC RFID DESFire"
    
    /// Direct payment at the charging station
    case directPayment = "Direct Payment"
    
    /// Plug and Charge (automatic authentication when plugging in)
    case plugAndCharge = "PnC"

    /// Create an `AuthenticationMode` from a raw string, returning nil for unknown values.
    public init?(rawValueInsensitive: String) {
        let normalized = rawValueInsensitive.trimmingCharacters(in: .whitespacesAndNewlines)
        self.init(rawValue: normalized)
    }
}
