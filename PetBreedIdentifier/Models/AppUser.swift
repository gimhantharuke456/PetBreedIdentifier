import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let email: String
    let petName: String
    let petImageURL: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case petName
        case petImageURL
        case createdAt
        case updatedAt
    }
}
