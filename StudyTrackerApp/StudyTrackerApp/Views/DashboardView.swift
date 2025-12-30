// DashboardView.swift
import SwiftUI
import Charts

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Topic.entity(), sortDescriptors: [NSSortDescriptor(key: "isCompleted", ascending: true), NSSortDescriptor(key: "createdAt", ascending: false)]) private var topics: FetchedResults<Topic>
    @EnvironmentObject var analyticsVM: AnalyticsViewModel

    var activeTopics: [Topic] { topics.filter { !$0.isCompleted } }
    var completedTopics: [Topic] { topics.filter { $0.isCompleted } }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    CardView {
                        VStack(alignment: .leading) {
                            HStack { Text("Focus Score").font(.headline); Spacer() }
                            if analyticsVM.focusHistory.isEmpty {
                                Text("Complete topics to see focus analytics.")
                                    .font(.footnote).foregroundColor(.secondary).padding(.top, 8)
                            } else {
                                Chart {
                                    ForEach(analyticsVM.focusHistory, id: \.date) { item in
                                        LineMark(x: .value("Date", item.date), y: .value("Focus", item.score))
                                            .interpolationMethod(.catmullRom)
                                        AreaMark(x: .value("Date", item.date), y: .value("Focus", item.score))
                                            .opacity(0.12)
                                    }
                                }
                                .chartYScale(domain: 0...100)
                                .frame(height: 140)
                            }
                        }
                    }

                    CardView {
                        VStack(alignment: .leading) {
                            HStack { Text("Consistency").font(.headline); Spacer() }
                            Chart {
                                ForEach(analyticsVM.consistencyHistory, id: \.0) { item in
                                    LineMark(x: .value("Date", item.0), y: .value("Score", item.1))
                                        .interpolationMethod(.catmullRom)
                                }
                            }
                            .chartYScale(domain: 0...100)
                            .frame(height: 120)
                        }
                    }

                    CardView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Active Topics").font(.headline)
                            if activeTopics.isEmpty {
                                Text("No active topics. Add a new one.").foregroundColor(.secondary)
                            } else {
                                ForEach(activeTopics) { topic in
                                    NavigationLink(destination: TopicDetailView(topic: topic)) {
                                        TopicRowView(topic: topic)
                                    }
                                }
                            }
                        }
                    }

                    CardView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Completed Topics").font(.headline)
                            if completedTopics.isEmpty {
                                Text("No completed topics yet.").foregroundColor(.secondary)
                            } else {
                                ForEach(completedTopics) { topic in
                                    NavigationLink(destination: CompletedTopicDetailView(topic: topic)) {
                                        TopicRowView(topic: topic)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("StudyTrackr")
            .onAppear { analyticsVM.computeAll(); analyticsVM.registerAppOpen() }
        }
    }
}

struct CardView<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }
    var body: some View {
        VStack { content() }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 6)
    }
}
