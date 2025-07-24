import SwiftUI

struct ContentView: View {
    @StateObject private var session = SessionStore()
    @StateObject private var events = EventStore()
    @State private var newEventText = ""
    @State private var creatingMoment = false
    @State private var creatingMoodRoom = false
    @State private var selectedEvent: Event?
    @State private var createdRoomName = ""
    @State private var createdRoomBackground = "MoodRoomHappy"
    @State private var exploringMoodRooms = false

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
                                EventCardView(event: event, isOwnEvent: events.ownEventIds.contains(event.id))
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical)
                }
            }
            .navigationTitle("Moments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Explore Mood Rooms") { exploringMoodRooms = true }
                        Button("New Mood Room") { creatingMoodRoom = true }
                        Button("New Moment") { creatingMoment = true }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $creatingMoment) { CreateMomentView(text: $newEventText) { text in
                    Task {
                        if let token = session.token {
                            if let created = await events.createEvent(token: token, content: text) {
                                creatingMoment = false
                                newEventText = ""
                                selectedEvent = created
                            }
                        }
                    }
                } onDiscard: {
                    creatingMoment = false
                    newEventText = ""
                }
            }
            .sheet(isPresented: $creatingMoodRoom) {
                CreateMoodRoomView { name, background in
                    createdRoomName = name
                    createdRoomBackground = background
                    exploringMoodRooms = true
                }
            }
            .sheet(isPresented: $exploringMoodRooms) {
                MoodRoomListView()
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event, isOwnEvent: events.ownEventIds.contains(event.id))
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
