import Foundation

/// Observable store for listing and creating moments.
@MainActor
class EventStore: ObservableObject {
    private let momentService = MomentService()
    /// All events loaded from the backend or mock store.
    @Published var events: [Event] = []

    /// Identifiers of events created by the current session.
    @Published var ownEventIds: Set<String> = []

    /// Fetches events from the backend into ``events``.
    func loadEvents() async {
        do {
            events = try await momentService.fetchMoments().map { moment in
                Event(id: moment.id, content: moment.content, mood: nil, symbol: nil)
            }
        } catch {
            print("Failed to load events", error)
            events = []
        }
    }

    /// Creates a new event and refreshes the list on success.
    func createEvent(token: String, content: String) async -> Event? {
        do {
            let created = try await momentService.postMoment(token: token, text: content)
            await loadEvents()
            ownEventIds.insert(created.id)
            return Event(id: created.id, content: created.content, mood: nil, symbol: nil)
        } catch {
            print("Failed to create event", error)
            return nil
        }
    }
}
