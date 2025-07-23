import Foundation

class PresenceService: ObservableObject {
    @Published var count: Int = 1
    private var task: URLSessionWebSocketTask?

    func connect(eventId: Int) {
        disconnect()
        var urlComponents = URLComponents()
        urlComponents.scheme = "ws"
        urlComponents.host = "localhost"
        urlComponents.port = 8000
        urlComponents.path = "/ws/presence/\(eventId)"
        guard let url = urlComponents.url else { return }
        task = URLSession(configuration: .default).webSocketTask(with: url)
        task?.resume()
        listen()
    }

    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
    }

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
