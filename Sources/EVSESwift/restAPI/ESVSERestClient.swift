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
import SwiftRestRequests

/// REST client for accessing the Swiss EVSE (ich-tanke-strom.ch) dataset hosted on data.geo.admin.ch
public final class ESVSERestClient: RestApiCaller, EVSEDataFetching, EVSEStatusFetching {
    public static let baseURLString = "https://data.geo.admin.ch/ch.bfe.ladestellen-elektromobilitaet/"
    public static let dataEndpoint = "data/oicp/ch.bfe.ladestellen-elektromobilitaet.json"
    public static let statusEndpoint = "status/oicp/ch.bfe.ladestellen-elektromobilitaet.json"

    public convenience init() {
        let base = URL(string: Self.baseURLString)!
        self.init(baseUrl: base, urlSession: URLSession(configuration: .default), authorizer: nil, errorDeserializer: nil, headerGenerator: nil, enableNetworkTrace: false, httpCookieStorage: nil)
    }

    /// Fetch the EVSE dataset asynchronously using SwiftRestRequests generic GET.
    /// - Returns: Decoded `EVSEData` root object.
    /// - Throws: `RestError.failedRestCall` if the status is not OK or decoding fails.
    public func getEVSEData() async throws -> EVSEData {
        let (decoded, status) = try await get(EVSEData.self, at: Self.dataEndpoint)
        guard status == .ok, let decoded else {
            throw RestError.unexpectedHttpStatusCode(Int(status.rawValue))
        }
        return decoded
    }

    /// Fetch the EVSE status dataset asynchronously using SwiftRestRequests generic GET.
    /// - Returns: Decoded `EVSEStatuses` root object containing real-time status information.
    /// - Throws: `RestError.failedRestCall` if the status is not OK or decoding fails.
    public func getEVSEStatuses() async throws -> EVSEStatuses {
        let (decoded, status) = try await get(EVSEStatuses.self, at: Self.statusEndpoint)
        guard status == .ok, let decoded else {
            throw RestError.unexpectedHttpStatusCode(Int(status.rawValue))
        }
        return decoded
    }
}
