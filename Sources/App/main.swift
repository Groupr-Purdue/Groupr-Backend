import Vapor
import VaporSQLite
import Fluent

let drop = Droplet()
try drop.addProvider(VaporSQLite.Provider.self)

let preparations = [
    User.self,
    Course.self
] as [Preparation.Type]
drop.preparations += preparations

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
