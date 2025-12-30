// TopicRowView.swift
import SwiftUI

struct TopicRowView: View {
    var topic: Topic

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text(topic.title).font(.headline)
                HStack {
                    Text("Expected: \(TimeFormatter.string(from: topic.expectedTime))")
                        .font(.caption).foregroundColor(.secondary)
                    if topic.isCompleted {
                        Text("Actual: \(TimeFormatter.string(from: topic.actualTime))")
                            .font(.caption).foregroundColor(.green)
                    }
                }
            }
            Spacer()
            if topic.isCompleted {
                Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
            } else {
                Image(systemName: "clock")
            }
        }
        .padding(.vertical, 8)
    }
}
