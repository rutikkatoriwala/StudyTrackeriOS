// StudyTrackrApp.swift
import SwiftUI

@main
struct StudyTrackrApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var analyticsVM = AnalyticsViewModel(context: PersistenceController.shared.container.viewContext)

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(analyticsVM)
        }
    }
}

struct MainTabView: View {
    @State private var selected = 0
    @State private var showingAdd = false

    var body: some View {
        ZStack {
            TabView(selection: $selected) {
                DashboardView()
                    .tabItem { Label("Home", systemImage: "chart.xyaxis.line") }
                    .tag(0)

                TopicsListView()
                    .tabItem { Label("Topics", systemImage: "book") }
                    .tag(1)

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gear") }
                    .tag(2)
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: { showingAdd.toggle() }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .topTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(radius: 6)
                    }
                    .padding(.trailing, 22)
                    .padding(.top, 12)     
                    .sheet(isPresented: $showingAdd) {
                        AddTopicView()
                    }
                }
                Spacer()
            }

        }
    }
}
