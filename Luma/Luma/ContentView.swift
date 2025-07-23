import SwiftUI

struct ContentView: View {
    @StateObject private var session = SessionStore()
    @StateObject private var events = EventStore()
    @State private var newEventText = ""
    @State private var creatingMoment = false
    @State private var creatingMoodRoom = false
    @State private var selectedEvent: Event?
    @State private var showMoodRoom = false
    @State private var createdRoomName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Image("DetailViewBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(events.events) { event in
                            Button(action: { selectedEvent = event }) {
                                EventCardView(event: event)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical)
                }
                .overlay(alignment: .bottom) {
                    VStack {
                        Spacer()
                        Text("More moments")
                            .font(.footnote)
                            .foregroundColor(Color(.darkGray))
                            .padding(.bottom, 8)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                Menu {
                    Button("New Mood Room") { creatingMoodRoom = true }
                    Button("New Moment") { creatingMoment = true }
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding()
            }
            .sheet(isPresented: $creatingMoment) {
                NavigationView {
                    VStack {
                        TextField("Write something", text: $newEventText)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                            Button("Create") {
                                Task {
                                    if let token = session.token {
                                        if let created = await events.createEvent(token: token, content: newEventText) {
                                            creatingMoment = false
                                            newEventText = ""
                                            selectedEvent = created
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .navigationTitle("New Moment")
                    }
                }
            .sheet(isPresented: $creatingMoodRoom) {
                CreateMoodRoomView { name in
                    createdRoomName = name
                    showMoodRoom = true
                }
            }
            .sheet(isPresented: $showMoodRoom) {
                MoodRoomView(name: createdRoomName)
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event)
            }
            .task {
                await session.ensureSession()
                await events.loadEvents()
            }
        }
    }
}

struct EnergyRoomView: View {
    let event: Event
    @StateObject private var presence = PresenceService()
    @State private var content: String = ""

    var body: some View {
        VStack {
            Text(content)
                .padding()
            Text("\(presence.count) people are with you in this moment.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
        }
        .onAppear {
            Task {
                presence.connect(eventId: event.id)
                do {
                    let fetched = try await APIClient.shared.fetchEvent(id: event.id)
                    content = fetched.content
                } catch {}
            }
        }
        .onDisappear {
            presence.disconnect()
        }
    }
}

#Preview {
    ContentView()
}
