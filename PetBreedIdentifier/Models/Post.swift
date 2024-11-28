import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    let caption: String
    let imageURL: String
    let likeCount: Int
    let postedUserName: String
    let postedUserId: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case caption
        case imageURL
        case likeCount
        case postedUserName
        case postedUserId
        case createdAt
        case updatedAt
    }
}
