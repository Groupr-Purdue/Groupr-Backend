import Vapor
import VaporSQLite

let drop = Droplet()
try drop.addProvider(VaporSQLite.Provider.self)

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
