// AnalyticsViewModel.swift
import Foundation
import CoreData

class AnalyticsViewModel: ObservableObject {
    private var context: NSManagedObjectContext

    @Published var focusHistory: [(date: Date, score: Double)] = []
    @Published var consistencyHistory: [(date: Date, score: Double)] = []

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        computeAll()
    }

    func computeAll() {
        computeFocusHistory()
        computeConsistencyHistory()
    }

    // MARK: Focus Score
    // Computes a focus score for a completed topic using its logs.
    func computeFocusScore(for topic: Topic) -> Double {
        let logs = (topic.logEvents?.allObjects as? [LogEvent]) ?? []
        let pauseLogs = logs.filter { $0.type == "pause" }
        let totalPauseSeconds = pauseLogs.reduce(0.0) { $0 + $1.pauseDuration }
        let totalSeconds = max(1.0, topic.actualTime)
        let pausePenalty = min(40.0, 5.0 * Double(pauseLogs.count))
        let pauseLengthPenalty = min(30.0, 20.0 * (totalPauseSeconds / totalSeconds))
        let focusSeconds = totalSeconds - totalPauseSeconds
        let distractedRatioPenalty = 30.0 * (1.0 - (focusSeconds / totalSeconds))
        let raw = 100.0 - (pausePenalty + pauseLengthPenalty + distractedRatioPenalty)
        return max(0, min(100, raw))
    }

    func computeFocusHistory() {
        let fr: NSFetchRequest<Topic> = Topic.fetchRequest()
        fr.predicate = NSPredicate(format: "isCompleted == YES")
        fr.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        if let completed = try? context.fetch(fr) {
            focusHistory = completed.compactMap { topic in
                // completion date derived from last 'stop' log if present, else createdAt
                let stopDate = (topic.logEvents?.allObjects as? [LogEvent])?
                    .filter { $0.type == "stop" }
                    .sorted(by: { $0.timestamp < $1.timestamp })
                    .last?.timestamp
                let date = stopDate ?? topic.createdAt
                return (date: date, score: computeFocusScore(for: topic))
            }.sorted(by: { $0.date < $1.date })
        } else {
            focusHistory = []
        }
    }

    // MARK: Consistency Score
    func computeStreak() -> Int {
        let fr: NSFetchRequest<UsageDay> = UsageDay.fetchRequest()
        fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        guard let days = try? context.fetch(fr) else { return 0 }
        let dates = days.map { Calendar.current.startOfDay(for: $0.date) }.sorted()
        var maxStreak = 0
        var currentStreak = 0
        var previous: Date? = nil
        for date in dates {
            if let prev = previous, Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: prev)!) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            maxStreak = max(maxStreak, currentStreak)
            previous = date
        }
        return maxStreak
    }

    func computeConsistencyHistory() {
        let daysToShow = 14
        var arr: [(Date, Double)] = []
        for i in (0..<daysToShow).reversed() {
            let day = Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let windowStart = Calendar.current.date(byAdding: .day, value: -6, to: day) ?? day
            let fr: NSFetchRequest<Topic> = Topic.fetchRequest()
            fr.predicate = NSPredicate(format: "isCompleted == YES AND createdAt >= %@ AND createdAt <= %@", windowStart as NSDate, day as NSDate)
            if let completed = try? context.fetch(fr) {
                let uniqueDays = Set(completed.compactMap { Calendar.current.startOfDay(for: $0.createdAt) })
                let completedDays = uniqueDays.count
                let streak = computeStreak()
                let score = min(100.0, 50.0 * (Double(streak) / 7.0) + 50.0 * (Double(completedDays) / 7.0))
                arr.append((day, score))
            } else {
                arr.append((day, 0))
            }
        }
        consistencyHistory = arr
    }

    func registerAppOpen() {
        let today = Calendar.current.startOfDay(for: Date())
        let fr: NSFetchRequest<UsageDay> = UsageDay.fetchRequest()
        fr.predicate = NSPredicate(format: "date == %@", today as NSDate)
        if let found = try? context.fetch(fr), found.isEmpty {
            let ud = UsageDay(context: context)
            ud.id = UUID()
            ud.date = today
            try? context.save()
            computeAll()
        }
    }
}
