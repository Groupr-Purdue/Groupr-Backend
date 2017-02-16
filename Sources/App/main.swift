import Vapor
import VaporPostgreSQL
import Fluent
import Library

// Initialize root Droplet.
let drop = Droplet()
drop.middleware.insert(CORSMiddleware(), at: 0)
try drop.addProvider(VaporPostgreSQL.Provider.self)

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
