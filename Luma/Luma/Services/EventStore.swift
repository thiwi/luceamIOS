import Foundation

@MainActor
class EventStore: ObservableObject {
    @Published var events: [Event] = []

    func loadEvents() async {
        do {
            events = try await APIClient.shared.listEvents()
        } catch {
            print("Failed to load events", error)
        }
    }

    func createEvent(token: String, content: String) async -> Event? {
        do {
            let created = try await APIClient.shared.createEvent(token: token, event: EventCreate(content: content, mood: "rain", symbol: "✨"))
            await loadEvents()
            return created
        } catch {
            print("Failed to create event", error)
            return nil
        }
    }
}
