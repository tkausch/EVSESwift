import Foundation

/// A description
extension JSONDecoder.DateDecodingStrategy {
    /// A flexible ISO8601 strategy that supports dates with or without fractional seconds.
    static let iso8601Flexible = custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        // Try with fractional seconds first
        let isoFormatterWithFraction = ISO8601DateFormatter()
        isoFormatterWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatterWithFraction.date(from: dateString) {
            return date
        }

        // Fallback: try without fractional seconds
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        // Still failed? Throw
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid ISO8601 date: \(dateString)"
        )
    }
}