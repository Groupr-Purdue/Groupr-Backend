import Vapor
import VaporSQLite
import Fluent
import Library

// Initialize root Droplet.
let drop = Droplet()
try drop.addProvider(VaporSQLite.Provider.self)

// Prepare the SQLite DB if needed on boot.
// TODO: Move to Model classes.
let preparations = [
    Auth.self,
    User.self,
    Course.self,
    Pivot<User, Course>.self
] as [Preparation.Type]
drop.preparations += preparations

// Define the set of all controllers with named endpoints.
// TODO: Dynamically collect controllers.
drop.resource("/users", UsersController())
drop.resource("/courses", CoursesController())
drop.run()
