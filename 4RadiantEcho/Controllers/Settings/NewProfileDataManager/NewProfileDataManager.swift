import Foundation
import UIKit

final class NewProfileDataManager {
    static let shared = NewProfileDataManager()

    private let userDefaults = UserDefaults.standard
    private let profileKey = "newProfileKey"

    // MARK: - Profile Operations

    func saveProfile(_ profile: NewProfileModel) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(profile)
            userDefaults.set(encoded, forKey: profileKey)
        } catch {
            print("Failed to save profile: \(error.localizedDescription)")
        }
    }

    func loadProfiles() -> [NewProfileModel] {
        guard let data = userDefaults.data(forKey: profileKey) else { return [] }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([NewProfileModel].self, from: data)
        } catch {
            print("Failed to load profiles: \(error.localizedDescription)")
            return []
        }
    }

    func loadProfile() -> NewProfileModel? {
        guard let data = userDefaults.data(forKey: profileKey) else { return nil }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(NewProfileModel.self, from: data)
        } catch {
            print("Failed to load profile: \(error.localizedDescription)")
            return nil
        }
    }

    func loadProfile(withId id: UUID) -> NewProfileModel? {
        return loadProfiles().first { $0.id == id }
    }

    func updateProfile(_ updatedProfile: NewProfileModel) {
        saveProfile(updatedProfile)
    }

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
