import SwiftUI

/// Main view displaying the list of available moments and
/// entry points to mood rooms and statistics.
///
/// This view owns several pieces of UI state for modal
/// presentation and loads events via ``EventStore``. It also
/// ensures that a ``SessionStore`` exists so the backend APIs
/// can be called.
struct ContentView: View {
    /// Manages the anonymous session token used for API calls.
    @StateObject private var session = SessionStore()

    /// Fetches and creates moment events.
    @StateObject private var events = EventStore()

    /// Stores mood rooms loaded from the backend.
    @StateObject private var moodRooms = MoodRoomStore()

    /// Persists favourite mood rooms.
    @StateObject private var favourites = FavoritesStore()

    /// Usage statistics shared across the app.
    @EnvironmentObject var stats: StatsStore

    /// Text typed into the new moment composer.
    @State private var newEventText = ""

    /// Whether the "create moment" sheet is shown.
    @State private var creatingMoment = false

    /// Whether the "create mood room" sheet is shown.
    @State private var creatingMoodRoom = false

    /// The event currently displayed in a detail sheet.
    @State private var selectedEvent: Event?

    /// Temporary state for newly created mood room info.
    @State private var createdRoomName = ""
    @State private var createdRoomBackground = "MoodRoomHappy"

    /// Controls presentation of the mood room list.
    @State private var exploringMoodRooms = false

    /// Controls presentation of the statistics screen.
    @State private var showStats = false
    /// Controls presentation of the scheduled rooms list.
    @State private var showScheduled = false

    /// Main screen with a list of moments and toolbar actions.
    var body: some View {
        NavigationStack {
            ZStack {
                Image("DetailViewBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView {
                    let favRooms = moodRooms.rooms.filter { favourites.isFavorite($0) }
                    if !favRooms.isEmpty {
                        LazyVStack(spacing: 16) {
                            Text("Scheduled MoodRooms")
                                .font(.headline)
                                .foregroundColor(.black)
                            ForEach(favRooms) { room in
                                if room.isJoinable {
                                    NavigationLink(destination: MoodRoomView(room: room)) {
                                        MoodRoomCardView(room: room)
                                            .id(room)
                                    }
                                } else {
                                    MoodRoomCardView(room: room)
                                        .id(room)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical)
                    }
                    if events.events.isEmpty {
                        Text("No entries")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
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
            }
            .navigationTitle("Moments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Explore Mood Rooms") { exploringMoodRooms = true }
                        Button("Scheduled MoodRooms") { showScheduled = true }
                        Button("New Mood Room") { creatingMoodRoom = true }
                        Button("New Moment") { creatingMoment = true }
                        Button("Statistics") { showStats = true }
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
                        guard let token = session.token, !token.isEmpty else {
                            print("❌ Kein Session-Token verfügbar – Event wird nicht erstellt.")
                            return
                        }
                        print("📤 Sending event with session token: \(token)")
                        if let created = await events.createEvent(dto: CreateEventDto(content: text, session_token: token)) {
                            creatingMoment = false
                            newEventText = ""
                            selectedEvent = created
                            stats.recordMomentCreated()
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
                    stats.recordMoodRoomCreated()
                }
                .environmentObject(moodRooms)
                .environmentObject(session)
            }
            .fullScreenCover(isPresented: $exploringMoodRooms) {
                MoodRoomListView()
                    .environmentObject(moodRooms)
                    .environmentObject(session)
                    .environmentObject(favourites)
            }
            .fullScreenCover(isPresented: $showScheduled) {
                ScheduledMoodRoomListView()
                    .environmentObject(favourites)
                    .environmentObject(session)
            }
            .fullScreenCover(isPresented: $showStats) {
                StatsView()
                    .environmentObject(stats)
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event, isOwnEvent: events.ownEventIds.contains(event.id))
            }
            // Establish a session token and load moments as soon
            // as the view appears.
            .task {
                await session.ensureSession()
                await events.loadEvents()
                await moodRooms.load(token: session.token, userId: HARDCODED_USER_ID)
                await favourites.loadFavorites()
            }
        }
    }
}

/// Simple view used to preview the presence WebSocket service.
struct EnergyRoomView: View {
    let event: Event
    @StateObject private var presence = PresenceService()
    @State private var content: String = ""

    var body: some View {
        VStack {
            Text(content)
                .padding()
            Text(presence.count == 1 ?
                 "There is 1 person with you in this moment." :
                 "There are \(presence.count) persons with you in this moment.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
        }
        // Connect to the presence WebSocket when the preview appears
        // and fetch the full event text for display.
        .onAppear {
            Task {
                presence.connect(eventId: event.id)
                do {
                    let fetched = try await APIClient.shared.fetchEvent(id: event.id)
                    content = fetched.content
                } catch {}
            }
        }
        // Stop listening when the view is dismissed.
        .onDisappear {
            presence.disconnect()
        }
    }
}

#Preview {
    // Basic preview for Xcode canvas.
    ContentView()
        .environmentObject(StatsStore())
        .environmentObject(SessionStore())
        .environmentObject(FavoritesStore())
}
