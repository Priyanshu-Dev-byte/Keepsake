import SwiftUI
import SwiftData

struct AddReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let capsule: TimeCapsule
    
    @State private var title = ""
    @State private var reminderDate = Date().addingTimeInterval(3600)
    @State private var message = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Reminder title", text: $title)
                        .foregroundStyle(.white)
                    
                    DatePicker(
                        "Date & Time",
                        selection: $reminderDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .foregroundStyle(.white)
                    
                    TextField("Message (optional)", text: $message)
                        .foregroundStyle(.white)
                }
                .listRowBackground(Color.white.opacity(0.05))
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "0B0C1E").ignoresSafeArea())
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Reminder") {
                        saveReminder()
                    }
                    .foregroundStyle(.blue)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveReminder() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        
        let newReminder = CapsuleReminder(
            title: trimmedTitle,
            reminderDate: reminderDate,
            message: message.trimmingCharacters(in: .whitespaces)
        )
        capsule.reminders.append(newReminder)
        
        NotificationManager.shared.scheduleReminder(reminder: newReminder, capsule: capsule)
        
        dismiss()
    }
}
