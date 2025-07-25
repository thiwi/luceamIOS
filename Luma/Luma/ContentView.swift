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

    /// Main screen with a list of moments and toolbar actions.
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
                        if let token = session.token {
                            if let created = await events.createEvent(token: token, content: text) {
                                creatingMoment = false
                                newEventText = ""
                                selectedEvent = created
                                stats.recordMomentCreated()
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
                    stats.recordMoodRoomCreated()
                }
            }
            .fullScreenCover(isPresented: $exploringMoodRooms) {
                MoodRoomListView()
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
}
