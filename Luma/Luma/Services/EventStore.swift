import Foundation

/// Observable store for listing and creating moments.
@MainActor
class EventStore: ObservableObject {
    /// All events loaded from the backend or mock store.
    @Published var events: [Event] = []

    /// Identifiers of events created by the current session.
    @Published var ownEventIds: Set<Int> = []

    /// Fetches events from the backend into ``events``.
    func loadEvents() async {
        do {
            events = try await APIClient.shared.listEvents()
        } catch {
            print("Failed to load events", error)
            // Fallback to local mock data when the backend is unavailable
            events = MockData.events
        }
    }

    /// Creates a new event and refreshes the list on success.
    func createEvent(token: String, content: String) async -> Event? {
        do {
            let created = try await APIClient.shared.createEvent(token: token, event: EventCreate(content: content, mood: "rain", symbol: "✨"))
            await loadEvents()
            ownEventIds.insert(created.id)
            return created
        } catch {
            print("Failed to create event", error)
            return nil
        }
    }
}
