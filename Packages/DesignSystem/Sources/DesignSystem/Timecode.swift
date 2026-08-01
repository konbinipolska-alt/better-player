import Foundation

/// Formats a playback position (in seconds) into a compact timecode string.
/// `1:04` for tracks under an hour, `1:02:03` beyond. Negative clamps to zero.
public enum Timecode {
    public static func string(_ seconds: Double) -> String {
        let total = max(0, Int(seconds.rounded()))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    /// Signed offset like `+0:12` / `-1:30` — used for scrub deltas.
    public static func signedString(_ seconds: Double) -> String {
        let sign = seconds < 0 ? "-" : "+"
        return sign + string(abs(seconds))
    }
}
