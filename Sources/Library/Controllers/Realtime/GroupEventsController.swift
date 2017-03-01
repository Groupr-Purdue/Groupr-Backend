import Vapor
import HTTP

public final class GroupEventsController {
    public init() {}

    var connections = [String: WebSocket]()

    public func bot(_ message: String) throws {
        try send(name: "Bot", message: message)
    }

    public func send(name: String, message: String) throws {
        let json = try JSON(node: [
            "username": name,
            "message": message
        ])

        for (username, socket) in connections {
            guard username != name else { continue }
            try socket.send(json.serialize())
        }
    }

    public static func handle(request req: Request, socket ws: WebSocket) throws {
        let room = GroupEventsController()
        var username: String? = nil

        ws.onText = { ws, text in
            let json = try JSON(bytes: Array(text.utf8))
            if let u = json.object?["username"]?.string {
                username = u
                room.connections[u] = ws
                try room.bot("\(u) has joined.")
            }
            if let u = username, let m = json.object?["message"]?.string {
                try room.send(name: u, message: m)
            }
        }

        ws.onClose = { ws, _, _, _ in
            guard let u = username else { return }
            try room.bot("\(u) has left")
            room.connections[u] = nil
        }
    }
}
