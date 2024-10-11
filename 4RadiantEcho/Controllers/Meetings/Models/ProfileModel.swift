import Foundation
import UIKit

struct MeetingModel: Codable {
    var id: UUID
    var title: String
    var description: String
    var date: String
    var beginning: String
    var ending: String
    var location: String
    var participants: [ParticipantModel]?
}

struct ParticipantModel: Codable {
    var id: UUID
    var name: String
    var participantImagePath: String?
    
    var participantImage: UIImage? {
        guard let path = participantImagePath else { return nil }
        return UIImage(contentsOfFile: path)
    }
}
