import Foundation
import UIKit

final class MeetingDataManager {
    static let shared = MeetingDataManager()
    
    private let userDefaults = UserDefaults.standard
    private let meetingKey = "meetingKey"
    
    // MARK: - Meeting Operations
    
    func saveMeeting(_ meeting: MeetingModel) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(meeting)
            userDefaults.set(encoded, forKey: meetingKey)
        } catch {
            print("Failed to save meeting: \(error.localizedDescription)")
        }
    }
    
    func saveMeetings(_ meeting: [MeetingModel]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(meeting) {
            userDefaults.set(encoded, forKey: meetingKey)
        }
    }
    
    func loadMeeting() -> MeetingModel? {
        guard let data = userDefaults.data(forKey: meetingKey) else { return nil }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(MeetingModel.self, from: data)
        } catch {
            print("Failed to load meeting: \(error.localizedDescription)")
            return nil
        }
    }
    
    func loadMeetings() -> [MeetingModel] {
        guard let data = userDefaults.data(forKey: meetingKey) else { return [] }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([MeetingModel].self, from: data)
        } catch {
            print("Failed to load meetings: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteMeeting() {
        userDefaults.removeObject(forKey: meetingKey)
    }
    
    func deleteMeeting(withId id: UUID) {
        var meetings = loadMeetings()
        meetings.removeAll { $0.id == id }
        saveMeetings(meetings)
    }
    
    // MARK: - Participant Operations
    
    func addParticipant(toMeeting meeting: inout MeetingModel, participant: ParticipantModel) {
        if meeting.participants == nil {
            meeting.participants = []
        }
        meeting.participants?.append(participant)
        saveMeeting(meeting)
    }
    
    func removeParticipant(fromMeeting meeting: inout MeetingModel, participantId: UUID) {
        if let index = meeting.participants?.firstIndex(where: { $0.id == participantId }) {
            meeting.participants?.remove(at: index)
            saveMeeting(meeting)
        } else {
            print("Participant with id \(participantId) not found")
        }
    }
    
    func updateParticipant(inMeeting meeting: inout MeetingModel, participantId: UUID, name: String? = nil, image: UIImage? = nil) {
        if let index = meeting.participants?.firstIndex(where: { $0.id == participantId }) {
            var participant = meeting.participants![index]
            
            if let name = name {
                participant.name = name
            }
            
            if let image = image, let imagePath = saveImage(image, withId: participant.id) {
                participant.participantImagePath = imagePath
            }
            
            meeting.participants![index] = participant
            saveMeeting(meeting)
        } else {
            print("Participant with id \(participantId) not found")
        }
    }
    
    // MARK: - Image Operations
    
    func saveImage(_ image: UIImage, withId id: UUID) -> String? {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return nil }
        
        let fileName = id.uuidString
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func loadImage(withId id: UUID) -> UIImage? {
        let fileName = id.uuidString
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            print("File does not exist at path: \(fileURL.path)")
            return nil
        }
    }
}
