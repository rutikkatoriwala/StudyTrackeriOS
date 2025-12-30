import Foundation
import Combine
import CoreData
import UIKit

class TimerViewModel: ObservableObject {
    @Published var elapsed: TimeInterval = 0
    @Published var isRunning = false
    @Published var hasStartedBefore = false   // For Start → Pause → Resume UI

    private var startTime: Date?
    private var accumulatedTime: TimeInterval = 0
    private var pauseStartTime: Date?         // To calculate pause duration

    private var timer: Timer?
    private(set) var topic: Topic
    private var context: NSManagedObjectContext

    init(topic: Topic, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.topic = topic
        self.context = context

        self.elapsed = topic.actualTime
        self.accumulatedTime = topic.actualTime
    }

    // MARK: - Start
    func start() {
        guard !isRunning else { return }

        isRunning = true
        hasStartedBefore = true
        startTime = Date()

        createLog(type: "start")
        startUITimer()
    }

    // MARK: - Pause
    func pause() {
        guard isRunning else { return }

        isRunning = false
        timer?.invalidate()

        // Add elapsed until now
        if let start = startTime {
            accumulatedTime += Date().timeIntervalSince(start)
        }

        elapsed = accumulatedTime
        topic.actualTime = elapsed
        try? context.save()

        pauseStartTime = Date()   // Save pause timestamp

        createLog(type: "pause")

        startTime = nil
    }

    // MARK: - Resume (fixed)
    func resume() {
        guard !isRunning else { return }

        // 1. Calculate pause duration
        if let pauseStart = pauseStartTime {
            let duration = Date().timeIntervalSince(pauseStart)
            updateLastPauseLog(with: duration)
        }

        pauseStartTime = nil

        // 2. Resume from current time
        isRunning = true
        hasStartedBefore = true
        startTime = Date()     // resume from now (accumulated stays same)

        createLog(type: "resume")

        // 3. Restart UI timer only
        startUITimer()
    }

    // MARK: - Stop (fixed)
    func stopAndComplete() {
        timer?.invalidate()
        isRunning = false

        // If user stops while running
        if let start = startTime {
            accumulatedTime += Date().timeIntervalSince(start)
        }

        elapsed = accumulatedTime

        topic.actualTime = elapsed
        topic.isCompleted = true   // Mark topic completed

        createLog(type: "stop")
        try? context.save()

        startTime = nil
    }

    // MARK: - Timer loop (UI only)
    private func startUITimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateElapsed()
        }
    }

    func updateElapsed() {
        guard isRunning, let start = startTime else { return }
        elapsed = accumulatedTime + Date().timeIntervalSince(start)
    }

    // MARK: - Background handling
    @objc func appBecameActive() {
        if isRunning {
            updateElapsed()
        }
    }

    // MARK: - Logging
    private func createLog(type: String) {
        let log = LogEvent(context: context)
        log.id = UUID()
        log.type = type
        log.timestamp = Date()
        log.elapsedAtEvent = elapsed
        log.pauseDuration = 0
        log.topic = topic
        try? context.save()
    }

    // MARK: - Update last pause event with real duration
    private func updateLastPauseLog(with duration: TimeInterval) {
        let logs = (topic.logEvents?.allObjects as? [LogEvent])?
            .sorted(by: { $0.timestamp < $1.timestamp }) ?? []

        if let lastPause = logs.last(where: { $0.type == "pause" }) {
            lastPause.pauseDuration = duration
            try? context.save()
        }
    }
}
