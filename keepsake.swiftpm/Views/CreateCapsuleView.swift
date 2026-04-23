import SwiftUI
import SwiftData

enum ReminderOffset: String, CaseIterable, Identifiable {
    case onDay = "On time"
    case oneDayBefore = "1 day before"
    case oneWeekBefore = "1 week before"
    
    var id: String { self.rawValue }
    var seconds: TimeInterval {
        switch self {
        case .onDay: return 0
        case .oneDayBefore: return -86400
        case .oneWeekBefore: return -604800
        }
    }
}

struct CreateCapsuleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var capsuleName = ""
    @State private var selectedMilestone: MilestoneType = .graduation
    @State private var selectedColorHex = "#A78BFA"
    @State private var showConfirmation = false

    @State private var enableReminder = false
    @State private var reminderDate = Date().addingTimeInterval(3600)
    @State private var reminderOffsetOption: ReminderOffset = .onDay

    @State private var isReunion = false
    @State private var reunionDate = Date()

    private let accentColors: [(name: String, hex: String)] = [
        ("Violet",   "#A78BFA"),
        ("Gold",     "#D4A843"),
        ("Rose",     "#FF6B8A"),
        ("Sky",      "#7EC8E3"),
        ("Emerald",  "#50C878"),
        ("Amber",    "#D4915E"),
        ("Silver",   "#C0C0C0"),
        ("Coral",    "#FF7F7F"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection

                    nameSection

                    milestoneSection

                    colorSection

                    reminderSection

                    reunionSection

                    createButton
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .background(Color(hex: "#0B0C1E"))
            .navigationTitle("New Capsule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private var headerSection: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            selectedMilestone.primaryColor.opacity(0.3),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 140, height: 140)

            Image(systemName: selectedMilestone.systemImage)
                .font(.system(size: 48))
                .foregroundStyle(selectedMilestone.primaryColor)
                .contentTransition(.symbolEffect(.replace))
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.72), value: selectedMilestone)
    }

    @ViewBuilder
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Capsule Name")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            TextField("e.g. Graduation 2025", text: $capsuleName)
                .textFieldStyle(.plain)
                .font(.title3)
                .padding(14)
                .background {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "#1A1B2E"))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                }
        }
    }

    @ViewBuilder
    private var milestoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestone Type")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                ForEach(MilestoneType.allCases) { type in
                    milestoneButton(type)
                }
            }
        }
    }

    @ViewBuilder
    private func milestoneButton(_ type: MilestoneType) -> some View {
        let isSelected = selectedMilestone == type

        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                selectedMilestone = type
            }
            HapticManager.selection()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: type.systemImage)
                    .font(.title3)
                Text(type.displayName)
                    .font(.caption.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? type.primaryColor.opacity(0.2) : Color(hex: "#1A1B2E"))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isSelected ? type.primaryColor : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
            }
            .foregroundStyle(isSelected ? type.primaryColor : .secondary)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accent Color")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(accentColors, id: \.hex) { item in
                        let isSelected = selectedColorHex == item.hex
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedColorHex = item.hex
                            }
                            HapticManager.selection()
                        } label: {
                            Circle()
                                .fill(Color(hex: item.hex))
                                .frame(width: 36, height: 36)
                                .overlay {
                                    Circle()
                                        .strokeBorder(.white, lineWidth: isSelected ? 2.5 : 0)
                                }
                                .scaleEffect(isSelected ? 1.15 : 1.0)
                                .shadow(
                                    color: isSelected ? Color(hex: item.hex).opacity(0.5) : .clear,
                                    radius: 6
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    @ViewBuilder
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reminder")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 0) {
                Toggle("Add a reminder", isOn: $enableReminder)
                    .foregroundStyle(.white)
                    .font(.body.weight(.medium))
                    .padding(16)
                    .tint(selectedMilestone.primaryColor)
                
                if enableReminder {
                    Divider().background(Color.white.opacity(0.1))
                    
                    VStack(spacing: 16) {
                        DatePicker(
                            "Date & Time",
                            selection: $reminderDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .foregroundStyle(.white)
                        .colorScheme(.dark)
                        
                        HStack {
                            Text("When")
                                .foregroundStyle(.white)
                            Spacer()
                            Picker("Timing", selection: $reminderOffsetOption) {
                                ForEach(ReminderOffset.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            .tint(selectedMilestone.primaryColor)
                        }
                    }
                    .padding(16)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#1A1B2E"))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            }
        }
    }

    @ViewBuilder
    private var reunionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reunion")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                Toggle("This is a shared memory", isOn: $isReunion)
                    .foregroundStyle(.white)
                    .font(.body.weight(.medium))
                    .padding(16)
                    .tint(Color(hex: "#14B8A6"))

                if isReunion {
                    Divider().background(Color.white.opacity(0.1))

                    DatePicker(
                        "Reunion Date",
                        selection: $reunionDate,
                        displayedComponents: .date
                    )
                    .foregroundStyle(.white)
                    .colorScheme(.dark)
                    .padding(16)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#1A1B2E"))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            }
        }
    }

    @ViewBuilder
    private var createButton: some View {
        Button {
            createCapsule()
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Create Capsule")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: selectedColorHex), Color(hex: selectedColorHex).opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .shadow(color: Color(hex: selectedColorHex).opacity(0.3), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(capsuleName.trimmingCharacters(in: .whitespaces).isEmpty)
        .opacity(capsuleName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
        .scaleEffect(showConfirmation ? 0.95 : 1.0)
        .padding(.top, 8)
    }

    private func createCapsule() {
        let trimmedName = capsuleName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let capsule = TimeCapsule(
            name: trimmedName,
            milestoneType: selectedMilestone,
            accentColorHex: selectedColorHex
        )
        
        if enableReminder {
            let fireDate = reminderDate.addingTimeInterval(reminderOffsetOption.seconds)
            let newReminder = CapsuleReminder(
                title: "\(capsule.name) is coming up!",
                reminderDate: fireDate,
                message: "Reminder set for \(capsule.name)"
            )
            capsule.reminders.append(newReminder)
            modelContext.insert(newReminder)
        }

        modelContext.insert(capsule)

        if isReunion {
            capsule.isReunion = true
            capsule.reunionDate = reunionDate
        }
        
        if enableReminder {
            Task {
                await NotificationManager.shared.requestPermission()
                if let createdReminder = capsule.reminders.first {
                    NotificationManager.shared.scheduleReminder(reminder: createdReminder, capsule: capsule)
                }
            }
        }

        if isReunion {
            Task {
                await NotificationManager.shared.requestPermission()
                NotificationManager.shared.scheduleReunionReminder(for: capsule)
            }
        }

        HapticManager.success()

        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
            showConfirmation = true
        }

        Task {
            try? await Task.sleep(for: .seconds(0.4))
            dismiss()
        }
    }
}
