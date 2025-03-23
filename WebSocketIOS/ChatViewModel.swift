import Foundation

final class ChatViewModel: NSObject {
    private var webSocket: URLSessionWebSocketTask?

    func setUp() {
        guard let url = URL(string: "wss://echo.websocket.org") else { return }
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
    }


    func close() {
        webSocket?.cancel(with: .goingAway, reason: nil)
    }
}

extension ChatViewModel: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        ping()
        receive()
        send()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection")
    }
}

private extension ChatViewModel {
    func ping() {
        webSocket?.sendPing { error in
            if let error {
                print("Ping error: \(error)")
                return
            }
        }
    }

    func send() {
        webSocket?.send(.string("New message: \(Int.random(in: 0...1000))")) { [weak self] error in
            if let error {
                print("Send error: \(error)")
                return
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
                self?.send()
            }
        }
    }

    func receive() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receive()
            case .failure(let error):
                print("Receive error: \(error)")
            }
        }
    }

    func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let data):
            print("Got data: \(data)")
        case .string(let string):
            print("Got string: \(string)")
        @unknown default:
            break
        }
    }
}
