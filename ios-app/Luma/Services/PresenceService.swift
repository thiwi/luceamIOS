import Foundation

/// Connects to the presence WebSocket to show participant counts.
class PresenceService: ObservableObject {
    /// Current number of participants in the room.
    @Published var count: Int = 1

    /// Active web socket task.
    private var task: URLSessionWebSocketTask?

    /// Opens the WebSocket for the specified event.
    func connect(eventId: UUID) {
        disconnect()

        guard !APIClient.useMock else {
            // In mock mode just use a fixed presence count
            count = 1
            return
        }

        var urlComponents = URLComponents()
        urlComponents.scheme = "ws"
        urlComponents.host = "localhost"
        urlComponents.port = 8000
        urlComponents.path = "/ws/presence/\(eventId.uuidString)"
        guard let url = urlComponents.url else { return }
        task = URLSession(configuration: .default).webSocketTask(with: url)
        task?.resume()
        listen()
    }

    /// Terminates the WebSocket connection.
    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
    }

    /// Continuously receives presence messages and updates ``count``.
    private func listen() {
        task?.receive { [weak self] result in
            switch result {
            case .success(let message):
                if case let .string(text) = message,
                   let data = text.data(using: .utf8),
                   let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Int],
                   let c = obj["count"] {
                    DispatchQueue.main.async {
                        self?.count = c
                    }
                }
                self?.listen()
            case .failure:
                break
            }
        }
    }
}
