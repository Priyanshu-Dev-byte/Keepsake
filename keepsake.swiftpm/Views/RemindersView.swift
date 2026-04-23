import SwiftUI
import SwiftData

struct RemindersView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let capsule: TimeCapsule
    @State private var showAddReminder = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0B0C1E").ignoresSafeArea()
                
                if capsule.reminders.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(capsule.reminders.sorted(by: { $0.reminderDate < $1.reminderDate })) { reminder in
                            ReminderRowView(reminder: reminder)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        NotificationManager.shared.cancelReminder(reminder: reminder)
                                        modelContext.delete(reminder)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        .onDelete(perform: deleteReminders)
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddReminder = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showAddReminder) {
                AddReminderView(capsule: capsule)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.3))
            
            Text("No reminders yet.\nAdd one to stay connected to this memory.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                showAddReminder = true
            } label: {
                Text("Add Reminder")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.3))
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
    }
    
    private func deleteReminders(at offsets: IndexSet) {
        let sorted = capsule.reminders.sorted(by: { $0.reminderDate < $1.reminderDate })
        for index in offsets {
            let reminder = sorted[index]
            NotificationManager.shared.cancelReminder(reminder: reminder)
            modelContext.delete(reminder)
        }
    }
}

struct ReminderRowView: View {
    let reminder: CapsuleReminder
    
    var isPast: Bool {
        reminder.reminderDate < .now
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(reminder.title)
                    .font(.headline)
                    .foregroundStyle(isPast ? .white.opacity(0.5) : .white)
                
                Spacer()
                
                if isPast {
                    Text("Delivered")
                        .font(.caption2.bold())
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                } else {
                    Text(timeRemaining(to: reminder.reminderDate))
                        .font(.caption2.bold())
                        .foregroundStyle(Color.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            
            Text(reminder.reminderDate.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(isPast ? .white.opacity(0.4) : .white.opacity(0.7))
            
            if !reminder.message.isEmpty {
                Text(reminder.message)
                    .font(.subheadline)
                    .foregroundStyle(isPast ? .white.opacity(0.4) : .white.opacity(0.8))
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func timeRemaining(to date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
