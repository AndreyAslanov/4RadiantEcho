import Foundation
import UIKit

struct NewProfileModel: Codable {
    var id: UUID
    var name: String
    var age: String
    var sex: [Int]
    var profileImagePath: String?

    var profileImage: UIImage? {
        guard let path = profileImagePath else { return nil }
        return UIImage(contentsOfFile: path)
    }
}
