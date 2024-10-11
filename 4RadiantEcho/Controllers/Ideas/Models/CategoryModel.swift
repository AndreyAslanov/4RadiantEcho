import Foundation
import UIKit

struct CategoryModel: Codable {
    var id: UUID
    var name: String
    var ideas: [IdeasModel]?
}

struct IdeasModel: Codable {
    var id: UUID
    var title: String
    var description: String
}
