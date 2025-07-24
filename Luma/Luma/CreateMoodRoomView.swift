import SwiftUI

struct CreateMoodRoomView: View {
    @Environment(\.dismiss) private var dismiss
    var onCreate: (String, String) -> Void = { _, _ in }

    @State private var name: String = ""
    @State private var backgroundIndex = 0
    @State private var recurring = false
    @State private var selectedWeekdays: Set<Int> = []
    @State private var time = Date()
    @State private var durationMinutes = 15
    @State private var showPreview = false

    private let backgrounds = ["MoodRoomHappy", "MoodRoomNight", "MoodRoomNature", "MoodRoomSad"]
    private let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        VStack {
            Text("Create a new mood room")
                .font(.headline)
                .padding()
            ZStack {
                Image(backgrounds[backgroundIndex])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                let textColor = backgrounds[backgroundIndex] == "MoodRoomNight" ? Color.white : Color.black
                VStack(spacing: 16) {
                    Picker("Background", selection: $backgroundIndex) {
                        ForEach(0..<backgrounds.count, id: \.self) { idx in
                            Text(backgrounds[idx]).tag(idx)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    ZStack(alignment: .topLeading) {
                        if name.isEmpty {
                            Text("Mood Room name")
                                .foregroundColor(.gray)
                                .padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
                        }
                        TextEditor(text: $name)
                            .background(Color.clear)
                            .foregroundColor(textColor)
                            .frame(height: 40)
                    }

                    Toggle("Recurring", isOn: $recurring)

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
                }
                .foregroundColor(textColor)
                .tint(textColor)
                .padding()
            }
            .frame(width: UIScreen.main.bounds.width * 0.95,
                   height: UIScreen.main.bounds.height * 0.6)
            .cornerRadius(16)
            .clipped()
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
            .padding()

            HStack {
                Button("Cancel") { dismiss() }
                    .padding()
                Spacer()
                Button("Preview") { showPreview = true }
                    .padding()
                Button("Create") {
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
                    MockData.addMoodRoom(name: name.isEmpty ? "Unnamed" : name,
                                         schedule: schedule,
                                         background: backgrounds[backgroundIndex],
                                         startTime: time,
                                         durationMinutes: durationMinutes)
                    onCreate(name, backgrounds[backgroundIndex])
                    dismiss()
                }
                .padding()
            }
            .sheet(isPresented: $showPreview) {
                MoodRoomView(name: name.isEmpty ? "Unnamed" : name,
                             background: backgrounds[backgroundIndex],
                             isPreview: true)
            }
        }
    }
}

#Preview {
    CreateMoodRoomView()
}
