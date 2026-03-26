import Foundation

struct Investor: Codable, Equatable {
    let id: UUID
    let email: String
    var firstName: String
    var lastName: String
    var phoneNumber: String?

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
