import SwiftUI
import CoreData

struct TopicDetailView: View {
    @ObservedObject var topic: Topic
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var timerVM: TimerViewModel

    init(topic: Topic) {
        _topic = ObservedObject(initialValue: topic)
        _timerVM = StateObject(wrappedValue: TimerViewModel(topic: topic, context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text(topic.title).font(.title2).bold()
                HStack {
                    Text("Expected: \(TimeFormatter.string(from: topic.expectedTime))")
                    Spacer()
                    if topic.isCompleted {
                        Text("Completed").foregroundColor(.green).bold()
                    }
                }
            }
            .padding()

            // FIX: Added missing bindings
            TimerView(
                elapsed: $timerVM.elapsed,
                isRunning: $timerVM.isRunning,
                hasStartedBefore: $timerVM.hasStartedBefore,
                onStart: timerVM.start,
                onPause: timerVM.pause,
                onResume: timerVM.resume,
                onStop: timerVM.stopAndComplete,
                onResumeForeground: timerVM.appBecameActive
            )

            .padding()

            VStack(alignment: .leading, spacing: 8) {
                Text("Logs").font(.headline)
                List {
                    ForEach(((topic.logEvents?.allObjects as? [LogEvent]) ?? [])
                        .sorted(by: { $0.timestamp < $1.timestamp })) { log in

                        HStack {
                            Text(log.type.capitalized)
                            Spacer()
                            Text(TimeFormatter.string(from: log.elapsedAtEvent))

                            if log.type == "pause" {
                                Text("(paused: \(Int(log.pauseDuration))s)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .frame(height: 240)
            }
            .padding([.leading, .trailing])

            Spacer()
        }
        .navigationTitle("Topic Details")
        .onDisappear { try? viewContext.save() }
    }
}
