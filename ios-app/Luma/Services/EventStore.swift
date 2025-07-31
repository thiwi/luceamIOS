import Foundation

/// DTO for creating a new event, automatically fetching the session token from UserDefaults.
struct CreateEventDto {
    let content: String
    let session_token: String
}

/// Observable store for listing and creating moments.
@MainActor
class EventStore: ObservableObject {
    private let momentService = MomentService()
    /// All events loaded from the backend.
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
    func createEvent(dto: CreateEventDto) async -> Event? {
        let eventContent = dto.content
        let sessionTokenVal = dto.session_token
        do {
            guard !sessionTokenVal.isEmpty else {
                print("❌ No session token available")
                return nil
            }
            print("📤 Sending event with token: \(sessionTokenVal), content: \(eventContent)")
            let created = try await momentService.postMoment(token: sessionTokenVal, text: eventContent)
            print("✅ Created event with id: \(created.id), content: \(created.content)")
            await loadEvents()
            ownEventIds.insert(created.id)
            return Event(id: created.id, content: created.content, mood: nil, symbol: nil)
        } catch {
            print("❌ Error during event creation:", error)
            print("Failed to create event", error)
            return nil
        }
    }
}
