import Foundation

struct AppLinks {
    static let appShareURL: URL = {
        guard let url = URL(string: "https://apps.apple.com/us/app/2radiantecho/id6736525527") else {
            fatalError("Invalid URL for appShareURL")
        }
        return url
    }()

    static let appStoreReviewURL: URL = {
        guard let url = URL(string: "https://apps.apple.com/us/app/2radiantecho/id6736525527") else {
            fatalError("Invalid URL for appStoreReviewURL")
        }
        return url
    }()

    static let usagePolicyURL: URL = {
        guard let url = URL(string: "https://www.termsfeed.com/live/46873831-cd88-47ac-aa5a-f55ea2feee8f") else {
            fatalError("Invalid URL for usagePolicyURL")
        }
        return url
    }()
}
