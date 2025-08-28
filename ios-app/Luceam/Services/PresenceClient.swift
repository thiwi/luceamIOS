import Foundation

/// Client for presence counts via REST and WebSockets.
struct PresenceClient {
    /// Fetch current participant count for a moment.
    func fetchPresence(momentId: String) async -> Int? {
        var base = URL(string: BASE_API_URL)!
        base.appendPathComponent("moments")
        base.appendPathComponent(momentId)
        base.appendPathComponent("presence")
        do {
            let (data, _) = try await URLSession.shared.data(from: base)
            if let obj = try JSONSerialization.jsonObject(with: data) as? [String: Int] {
                return obj["count"]
            }
        } catch {}
        return nil
    }

    /// Subscribe to live count updates via WebSocket.
    func subscribePresence(momentId: String) -> AsyncStream<Int> {
        AsyncStream { continuation in
            guard var components = URLComponents(string: BASE_API_URL) else {
                continuation.finish()
                return
            }
            components.scheme = components.scheme == "https" ? "wss" : "ws"
            components.path = "/ws/presence/\(momentId)"
            guard let url = components.url else {
                continuation.finish()
                return
            }
            let task = URLSession(configuration: .default).webSocketTask(with: url)
            task.resume()

            func listen() {
                task.receive { result in
                    switch result {
                    case .success(let message):
                        if case let .string(text) = message,
                           let data = text.data(using: .utf8),
                           let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Int],
                           let c = obj["count"] {
                            continuation.yield(c)
                        }
                        listen()
                    case .failure:
                        continuation.finish()
                    }
                }
            }
            listen()
            continuation.onTermination = { _ in
                task.cancel(with: .goingAway, reason: nil)
            }
        }
    }
}
