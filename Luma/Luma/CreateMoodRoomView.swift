import SwiftUI

struct CreateMoodRoomView: View {
    @Environment(\.dismiss) private var dismiss
    var onCreate: (String) -> Void = { _ in }

    @State private var name: String = ""
    @State private var backgroundIndex = 0
    @State private var recurring = false
    @State private var selectedWeekdays: Set<Int> = []
    @State private var time = Date()
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
                VStack(spacing: 16) {
                    Picker("Background", selection: $backgroundIndex) {
                        ForEach(0..<backgrounds.count, id: \.self) { idx in
                            Text(backgrounds[idx]).tag(idx)
                        }
                    }
                    .pickerStyle(.menu)

                    ZStack(alignment: .topLeading) {
                        if name.isEmpty {
                            Text("Enter Mood Room name")
                                .foregroundColor(.gray)
                                .padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
                        }
                        TextEditor(text: $name)
                            .background(Color.clear)
                            .foregroundColor(.primary)
                            .frame(height: 40)
                    }

                    Toggle("Recurring", isOn: $recurring)

                    if recurring {
                        VStack {
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
                            DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
                }
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
            }
            .sheet(isPresented: $showPreview) {
                MoodRoomView(name: name.isEmpty ? "Unnamed" : name,
                             background: backgrounds[backgroundIndex],
                             onCreate: {
                                 onCreate(name)
                                 dismiss()
                             },
                             onDiscard: { showPreview = false })
            }
        }
    }
}

#Preview {
    CreateMoodRoomView()
}
