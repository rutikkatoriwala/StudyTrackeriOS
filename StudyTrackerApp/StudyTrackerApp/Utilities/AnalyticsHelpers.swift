// AnalyticsHelpers.swift
import Foundation

struct AnalyticsHelpers {
    static func clamp(_ value: Double, min: Double = 0, max: Double = 100) -> Double {
        Swift.min(max, Swift.max(min, value))
    }
}
