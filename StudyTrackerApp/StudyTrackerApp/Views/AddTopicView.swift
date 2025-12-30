// AddTopicView.swift
import SwiftUI

struct AddTopicView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var hours = 0
    @State private var minutes = 30
    @State private var error: String?

    var body: some View {
        NavigationView {
            Form {

                // MARK: Topic Title
                Section(header: Text("Topic")) {
                    TextField("Title", text: $title)
                }

                // MARK: Expected Time Picker
                Section(header: Text("Expected Time")) {
                    HStack(spacing: 20) {

                        // Hours Picker
                        Picker("Hours", selection: $hours) {
                            ForEach(0..<24) { hour in
                                Text("\(hour) h").tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 110, height: 120)
                        .clipped()

                        // Minutes Picker
                        Picker("Minutes", selection: $minutes) {
                            ForEach(0..<60) { min in
                                Text("\(min) m").tag(min)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 110, height: 120)
                        .clipped()
                    }
                    .frame(maxWidth: .infinity)
                }

                if let err = error {
                    Text(err)
                        .foregroundColor(.red)
                }
            }

            .navigationBarTitle("Add Topic", displayMode: .inline)

            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    save()
                }
            )
        }
    }

    // MARK: Save Topic
    private func save() {
        let totalSeconds = (hours * 3600) + (minutes * 60)

        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
              totalSeconds > 0 else {
            self.error = "Please enter a valid title and expected time."
            return
        }

        let t = Topic(context: viewContext)
        t.id = UUID()
        t.title = title
        t.expectedTime = Double(totalSeconds)
        t.actualTime = 0
        t.isCompleted = false
        t.createdAt = Date()

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            self.error = "Failed to save topic: \(error.localizedDescription)"
        }
    }
}
