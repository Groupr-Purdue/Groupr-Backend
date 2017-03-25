import Vapor
import HTTP

public final class RealtimeController {
    public init() {}
    static var connections = [String: WebSocket]()

    public static func send(_ json: JSON, exclude: String? = nil) throws {
        for (key, socket) in connections {
            try socket.send(json.serialize())
        }
    }

    public static func handle(request req: Request, socket ws: WebSocket, username: String) throws {
        RealtimeController.connections[username] = ws
        ws.onClose = { ws, _, _, _ in
            RealtimeController.connections[username] = nil
        }

        // Handle incoming messages and translate to `POST /events`.
        ws.onText = { ws, text in
            let json = try JSON(bytes: Array(text.utf8))
            if let g = json.object?["group"]?.string, let m = json.object?["message"]?.string {

            }
        }
    }
}
