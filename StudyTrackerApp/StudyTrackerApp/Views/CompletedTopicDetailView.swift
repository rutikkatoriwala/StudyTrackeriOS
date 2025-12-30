// CompletedTopicDetailView.swift
import SwiftUI

struct CompletedTopicDetailView: View {
    @ObservedObject var topic: Topic
    @EnvironmentObject var analyticsVM: AnalyticsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text(topic.title).font(.title2).bold()
                    HStack {
                        Text("Expected: \(TimeFormatter.string(from: topic.expectedTime))")
                        Spacer()
                        Text("Actual: \(TimeFormatter.string(from: topic.actualTime))")
                    }
                    if let done = (topic.logEvents?.allObjects as? [LogEvent])?
                        .filter({ $0.type == "stop" }).sorted(by: { $0.timestamp < $1.timestamp }).last?.timestamp {
                        Text("Completed on \(done.formatted())").font(.caption)
                    }
                }
                .padding()

                CardView {
                    VStack(alignment: .leading) {
                        Text("Focus Score").font(.headline)
                        let score = analyticsVM.computeFocusScore(for: topic)
                        Text(String(format: "%.0f", score)).font(.system(size: 36, weight: .bold))
                    }
                }

                CardView {
                    VStack(alignment: .leading) {
                        Text("Pause Logs").font(.headline)
                        List {
                            ForEach(((topic.logEvents?.allObjects as? [LogEvent]) ?? []).filter { $0.type == "pause" }.sorted(by: { $0.timestamp < $1.timestamp })) { p in
                                HStack {
                                    Text(p.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    Spacer()
                                    Text("Duration: \(Int(p.pauseDuration))s")
                                }
                            }
                        }.frame(height: 220)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Completed Topic")
    }
}
