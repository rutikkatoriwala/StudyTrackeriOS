// TimeFormatter.swift
import Foundation

struct TimeFormatter {
    static func string(from seconds: TimeInterval) -> String {
        let s = Int(seconds)
        let hrs = s / 3600
        let mins = (s % 3600) / 60
        let secs = s % 60
        if hrs > 0 {
            return String(format: "%d:%02d:%02d", hrs, mins, secs)
        } else {
            return String(format: "%02d:%02d", mins, secs)
        }
    }

    static func seconds(from hoursAndMinutes: String) -> TimeInterval {
        // accepts "HH:MM" or "H:MM"
        let parts = hoursAndMinutes.split(separator: ":").map { String($0) }
        guard parts.count >= 2,
              let h = Int(parts[0]), let m = Int(parts[1]) else { return 0 }
        return TimeInterval(h * 3600 + m * 60)
    }
}
