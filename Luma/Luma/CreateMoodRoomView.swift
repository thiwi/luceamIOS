import SwiftUI

/// Form allowing the user to create or edit a ``MoodRoom``.
struct CreateMoodRoomView: View {
    /// Dismiss callback supplied by the environment.
    @Environment(\.dismiss) private var dismiss

    /// Room being edited, if any.
    var editingRoom: MoodRoom?

    /// Invoked after a new room is created.
    var onCreate: (String, String) -> Void = { _, _ in }

    /// Invoked when an existing room is updated.
    var onUpdate: (MoodRoom) -> Void = { _ in }

    /// Invoked when a room is deleted.
    var onDelete: (MoodRoom) -> Void = { _ in }

    /// Entered room name.
    @State private var name: String = ""
    /// Selected background image index.
    @State private var backgroundIndex = 0
    /// Flag whether the schedule is recurring.
    @State private var recurring = false
    /// Weekdays selected for recurrence.
    @State private var selectedWeekdays: Set<Int> = []
    /// Start time of the room.
    @State private var time = Date()
    /// Duration in minutes.
    @State private var durationMinutes = 15
    /// Controls presentation of the preview.
    @State private var showPreview = false
    /// Shows a confirmation alert when deleting.
    @State private var confirmDelete = false
    /// Color used for overlay text.
    @State private var textColor: Color = .black
    /// Maximum allowed characters in the name.
    private let maxNameLength = 100

    /// Available background asset names.
    private static let backgrounds = ["MoodRoomHappy", "MoodRoomNight", "MoodRoomNature", "MoodRoomSad"]
    /// Short weekday strings for the recurrence picker.
    private static let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    private let backgrounds = Self.backgrounds
    private let weekdays = Self.weekdays

    /// Creates the view optionally pre-populated with an existing room.
    init(editingRoom: MoodRoom? = nil,
         onCreate: @escaping (String, String) -> Void = { _, _ in },
         onUpdate: @escaping (MoodRoom) -> Void = { _ in },
         onDelete: @escaping (MoodRoom) -> Void = { _ in }) {
        self.editingRoom = editingRoom
        self.onCreate = onCreate
        self.onUpdate = onUpdate
        self.onDelete = onDelete

        if let room = editingRoom {
            _name = State(initialValue: room.name)
            _backgroundIndex = State(initialValue: Self.backgrounds.firstIndex(of: room.background) ?? 0)
            _textColor = State(initialValue: room.textColor)
            _time = State(initialValue: room.startTime)
            _durationMinutes = State(initialValue: room.durationMinutes)

            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            if room.schedule.hasPrefix("Every ") {
                _recurring = State(initialValue: true)
                if let range = room.schedule.range(of: " at ") {
                    let daysPart = room.schedule[room.schedule.index(room.schedule.startIndex, offsetBy: 6)..<range.lowerBound]
                    let days = daysPart.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    let indices = days.compactMap { Self.weekdays.firstIndex(of: String($0)) }
                    _selectedWeekdays = State(initialValue: Set(indices))
                    let timeString = room.schedule[range.upperBound...]
                    if let parsed = formatter.date(from: String(timeString)) {
                        _time = State(initialValue: parsed)
                    }
                }
            } else {
                _recurring = State(initialValue: false)
            }
        } else {
            _textColor = State(initialValue: .black)
        }
    }

    /// Form UI with preview, date pickers and actions.
    var body: some View {
        let interfaceColor: Color = backgrounds[backgroundIndex] == "MoodRoomNight" ? .white : .black
        return VStack {
            Text(editingRoom == nil ? "Create a new mood room" : "Edit mood room")
                .font(.headline)
                .padding()
            ZStack {
                Image(backgrounds[backgroundIndex])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                VStack(spacing: 16) {
                    Picker("Background", selection: $backgroundIndex) {
                        ForEach(0..<backgrounds.count, id: \.self) { idx in
                            Text(backgrounds[idx]).tag(idx)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    ColorPicker("Text Color", selection: $textColor)
                        .padding(.horizontal)

                    ZStack(alignment: .topLeading) {
                        if name.isEmpty {
                            Text("Mood Room name")
                                .foregroundColor(.gray)
                                .padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
                        }
                        TextEditor(text: $name)
                            .onChange(of: name) { _, newValue in
                                if newValue.count > maxNameLength {
                                    name = String(newValue.prefix(maxNameLength))
                                }
                            }
                            .background(Color.clear)
                            .foregroundColor(textColor)
                            .frame(height: 40)
                    }

                    HStack {
                        Spacer()
                        Text("\(maxNameLength - name.count) characters left")
                            .font(.caption2)
                            .foregroundColor(Color(.darkGray))
                    }
                    .padding(.trailing)

                    Toggle("Recurring", isOn: $recurring)
                        .padding(.leading)

                    if recurring {
                        HStack {
                            ForEach(0..<weekdays.count, id: \.self) { idx in
                                let day = idx
                                Button(action: {
                                    if selectedWeekdays.contains(day) {
                                        selectedWeekdays.remove(day)
                                    } else {
                                        selectedWeekdays.insert(day)
                                    }
                                }) {
                                    Text(weekdays[idx])
                                        .font(.caption)
                                        .padding(6)
                                        .background(selectedWeekdays.contains(day) ? Color.blue.opacity(0.2) : Color.clear)
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Start")
                        DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                            .colorScheme(backgrounds[backgroundIndex] == "MoodRoomNight" ? .dark : .light)
                    }
                    .padding(.bottom, -8)

                    HStack {
                        Text("Duration")
                        Picker("", selection: $durationMinutes) {
                            ForEach(Array(stride(from: 15, through: 180, by: 15)), id: \.self) { minutes in
                                let hours = minutes / 60
                                let mins = minutes % 60
                                if hours > 0 {
                                    if mins == 0 {
                                        Text("\(hours)h").tag(minutes)
                                    } else {
                                        Text("\(hours)h \(mins)min").tag(minutes)
                                    }
                                } else {
                                    Text("\(mins)min").tag(minutes)
                                }
                            }
                        }
                        .pickerStyle(.wheel)
                        .colorScheme(backgrounds[backgroundIndex] == "MoodRoomNight" ? .dark : .light)
                    }
                    .padding(.leading)
                }
                .foregroundColor(interfaceColor)
                .tint(interfaceColor)
                .padding()
            }
            .frame(width: UIScreen.main.bounds.width * 0.95,
                   height: UIScreen.main.bounds.height * 0.7)
            .cornerRadius(16)
            .clipped()
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
            .padding()

            HStack {
                if editingRoom != nil {
                    Button("Delete") { confirmDelete = true }
                        .foregroundColor(.red)
                        .padding()
                }
                Button("Cancel") { dismiss() }
                    .padding()
                Spacer()
                Button("Preview") { showPreview = true }
                    .padding()
                Button(editingRoom == nil ? "Create" : "Update") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    let timeString = formatter.string(from: time)
                    let schedule: String
                    if recurring {
                        let days = selectedWeekdays.sorted().map { weekdays[$0] }.joined(separator: ", ")
                        schedule = "Every \(days) at \(timeString)"
                    } else {
                        schedule = "Once at \(timeString)"
                    }
                    if let editing = editingRoom {
                        MockData.updateMoodRoom(id: editing.id,
                                               name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                               schedule: schedule,
                                               background: backgrounds[backgroundIndex],
                                               textColor: textColor,
                                               startTime: time,
                                               durationMinutes: durationMinutes)
                        onUpdate(editing)
                    } else {
                        MockData.addMoodRoom(name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                             schedule: schedule,
                                             background: backgrounds[backgroundIndex],
                                             textColor: textColor,
                                             startTime: time,
                                             durationMinutes: durationMinutes)
                        onCreate(name.trimmingCharacters(in: .whitespacesAndNewlines), backgrounds[backgroundIndex])
                    }
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding()
            }
            .sheet(isPresented: $showPreview) {
                MoodRoomView(room: MoodRoom(name: name.isEmpty ? "Unnamed" : name,
                                            schedule: "Once",
                                            background: backgrounds[backgroundIndex],
                                            textColor: textColor,
                                            startTime: time,
                                            createdAt: Date(),
                                            durationMinutes: durationMinutes),
                            isPreview: true)
            }
            .alert("Delete mood room?", isPresented: $confirmDelete) {
                Button("Delete", role: .destructive) {
                    if let editing = editingRoom {
                        MockData.deleteMoodRoom(id: editing.id)
                        onDelete(editing)
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .foregroundColor(interfaceColor)
        .tint(interfaceColor)
    }
}

#Preview {
    // Static preview for development.
    CreateMoodRoomView()
}
