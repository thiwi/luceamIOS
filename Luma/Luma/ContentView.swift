import SwiftUI

struct ContentView: View {
    @StateObject private var session = SessionStore()
    @StateObject private var events = EventStore()
    @State private var newEventText = ""
    @State private var creating = false
    @State private var selectedEvent: Event?

    var body: some View {
        ZStack {
            Image("day_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            NavigationView {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(events.events) { event in
                            Button(action: { selectedEvent = event }) {
                                EventCardView(event: event, background: "card_background1")
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Moments")
                .toolbar {
                    Button("Add") { creating = true }
                }
                .sheet(isPresented: $creating) {
                    NavigationView {
                        VStack {
                            TextField("Write something", text: $newEventText)
                                .textFieldStyle(.roundedBorder)
                                .padding()
                            Button("Create") {
                                Task {
                                    if let token = session.token {
                                        await events.createEvent(token: token, content: newEventText)
                                        creating = false
                                        newEventText = ""
                                    }
                                }
                            }
                            .padding()
                        }
                        .navigationTitle("New Moment")
                    }
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
