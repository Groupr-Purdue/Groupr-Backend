import Vapor

let drop = Droplet()

drop.get { req in
    return try JSON(node: "Hello :)")
}

drop.get("users", String.self) { req, val in
    return try JSON(node: [
        "header": "You were at \(req.method) \(req.uri.path)...",
        "result": "Oh hi there \(val)!"
    ])
}

drop.run()
