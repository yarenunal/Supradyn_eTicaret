struct Product: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let price: String // <-- String olmalı!
    let stock: Int?
    let imageUrl: String?
    let category: String?
    let createdAt: String?
    let updatedAt: String?
}
