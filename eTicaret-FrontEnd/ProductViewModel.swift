import Foundation

@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []

    func fetchProducts() async {
        // iOS simülatörü için host.docker.internal veya 127.0.0.1 kullan!
        guard let url = URL(string: "http://127.0.0.1:3000/api/products") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([Product].self, from: data)
            self.products = decoded
        } catch {
            print("Ürünler alınamadı: \(error)")
        }
    }
}
