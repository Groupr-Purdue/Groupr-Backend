import Vapor
import VaporSQLite
import Fluent

let drop = Droplet()
try drop.addProvider(VaporSQLite.Provider.self)

let preparations = [
    User.self,
    Course.self,
    Pivot<User, Course>.self
] as [Preparation.Type]
drop.preparations += preparations

drop.get { req in
    return try JSON(node: "Hello :)")
}

let usersController = UsersController()
drop.resource("/users", usersController)

drop.run()
