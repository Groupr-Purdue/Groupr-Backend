import Vapor
import HTTP
import VaporJWT
import Foundation
import Auth

public final class AuthSystem {
    private init() {} // singleton

    private static let secret = "ohgodthisisterribleplskillme"

    // POST: {username, password}
    public static func issue_token(_ request: Request) throws -> String {
        guard   let username = request.json?["username"]?.string,
                let password = request.json?["password"]?.string
        else { throw Abort.badRequest }

        guard let exists = try User.query().filter("username", .equals, username).first() else {
            throw Abort.badRequest
        }
        guard exists.password_hash == password else {
            throw Abort.badRequest
        }

        let jwt = try JWT(
            payload: Node(ExpirationTimeClaim(Date() + 60*60*24)),
            signer: HS256(key: AuthSystem.secret)
        )

        let token = try jwt.createToken()
        return token
    }

    // GET
    public static func check_token(_ request: Request) throws -> String {
        guard let credentials = request.auth.header?.bearer?.string else {
            throw Abort.badRequest
        }
        let token = try JWT(token: credentials)
        let isValid = try token.verifySignatureWith(HS256(key: AuthSystem.secret))
        return "\(isValid)"
    }

    // PATCH
    public static func refresh_token(_ request: Request) throws -> String {
        guard let credentials = request.auth.header?.bearer?.string else {
            throw Abort.badRequest
        }
        let token = try JWT(token: credentials)
        let isValid = try token.verifySignatureWith(HS256(key: AuthSystem.secret))
        guard isValid else {
            throw Abort.badRequest
        }

        let jwt = try JWT(
            payload: Node(ExpirationTimeClaim(Date() + 60*60*24)),
            signer: HS256(key: AuthSystem.secret)
        )

        let token2 = try jwt.createToken()
        return token2
    }
}
