import SwiftUI
import UserNotifications

// MARK: - Backend'e Uygun Modeller


struct OrderItem: Codable, Identifiable {
    let id: Int?
    let orderId: Int?
    let productId: Int?
    let quantity: Int?
    let price: String?
    let createdAt: String?
    let updatedAt: String?
    let product: Product?

    enum CodingKeys: String, CodingKey {
        case id, orderId, productId, quantity, price, createdAt, updatedAt
        case product = "Product"
    }
}

struct Payment: Codable, Identifiable {
    let id: Int?
    let orderId: Int?
    let amount: String?
    let status: String?
    let paymentMethod: String?
    let createdAt: String?
    let updatedAt: String?
}

struct Order: Codable, Identifiable {
    let id: Int?
    let userId: Int?
    let total: String?
    let status: String?
    let createdAt: String?
    let updatedAt: String?
    let orderItems: [OrderItem]?
    let payments: [Payment]?

    enum CodingKeys: String, CodingKey {
        case id, userId, total, status, createdAt, updatedAt
        case orderItems = "OrderItems"
        case payments = "Payments"
    }
}

// MARK: - Local Order Model (Geçmiş siparişler için)
struct LocalOrder: Identifiable, Codable {
    let id = UUID()
    let orderNumber: String
    let date: Date
    let totalAmount: Double
    let items: [LocalOrderItem]
    let status: String

    init(items: [Product], totalAmount: Double) {
        self.orderNumber = "ORD-\(Int.random(in: 10000...99999))"
        self.date = Date()
        self.totalAmount = totalAmount
        self.items = items.map { LocalOrderItem(product: $0, quantity: 1) }
        self.status = "Tamamlandı"
    }
}

struct LocalOrderItem: Identifiable, Codable {
    let id = UUID()
    let product: Product
    let quantity: Int
    let price: Double

    init(product: Product, quantity: Int) {
        self.product = product
        self.quantity = quantity
        self.price = Double(product.price ?? "0") ?? 0.0
    }
}

// MARK: - ViewModel
class UserOrdersViewModel: ObservableObject {
    static let shared = UserOrdersViewModel()
    @Published var orders: [Order] = []
    @Published var localOrders: [LocalOrder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private init() {}

    @MainActor
    func fetchOrders(token: String? = nil) async {
        print("🔄 fetchOrders fonksiyonu çağrıldı")

        guard let url = URL(string: "http://localhost:3000/orders") else {
            print("❌ Geçersiz URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        isLoading = true
        errorMessage = nil

        // ✅ Bunları en başta, do-catch yapısının DIŞINDA tanımla
        var responseData: Data? = nil
        var urlResponse: URLResponse? = nil

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            responseData = data
            urlResponse = response

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Status code:", httpResponse.statusCode)
                print("📦 Content-Type:", httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "bilinmiyor")
            }

            if let str = String(data: data, encoding: .utf8) {
                print("📨 Gelen veri:\n\(str)")
            }

            let decoder = JSONDecoder()
            let decodedOrders = try decoder.decode([Order].self, from: data)
            self.orders = decodedOrders
            print("✅ Siparişler başarıyla çözüldü. Toplam: \(decodedOrders.count) adet.")

        } catch {
            self.errorMessage = "🚫 Siparişler alınamadı: \(error.localizedDescription)"
            print("🛑 Genel hata:", error.localizedDescription)

            // ✅ Artık bu satır çalışır çünkü responseData tanımlı
            if let data = responseData, let str = String(data: data, encoding: .utf8) {
                print("📛 HATALI VERİ:\n\(str)")
            }
        }

        isLoading = false
    }



    func addLocalOrder(items: [Product], totalAmount: Double) {
        let newOrder = LocalOrder(items: items, totalAmount: totalAmount)
        localOrders.insert(newOrder, at: 0)
    }
}

// MARK: - UserView
struct UserView: View {
    @State private var showLoginView = false
    @Binding var isLoggedIn: Bool
    @Binding var sepet: Set<Int>
    @Binding var favoriler: Set<Int>
    @ObservedObject private var viewModel = UserOrdersViewModel.shared
    @State private var notificationEnabled: Bool = false
    @State private var showLogoutAlert = false
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("Profil").tag(0)
                    Text("Siparişlerim").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedTab == 0 {
                    profileView
                } else {
                    ordersView
                }
            }
            .navigationBarTitle("Hesabım", displayMode: .inline)
        }
        .task {
            await viewModel.fetchOrders()
        }
    }

    @ViewBuilder
    private var profileView: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    Text("Kullanıcı Adı")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("kullanici@email.com")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)

                HStack(spacing: 20) {
                    StatCard(title: "Toplam Sipariş", value: "\(viewModel.orders.count + viewModel.localOrders.count)")
                    StatCard(title: "Favoriler", value: "\(favoriler.count)")
                    StatCard(title: "Sepet", value: "\(sepet.count)")
                }

                VStack(spacing: 12) {
                    Toggle(isOn: $notificationEnabled) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Bildirimleri Aç")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .onChange(of: notificationEnabled) { yeniDurum in
                        if yeniDurum {
                            requestNotificationPermission()
                            scheduleLocalNotification()
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)

                VStack(spacing: 12) {
                    SettingsRow(icon: "person", title: "Profil Bilgileri")
                    SettingsRow(icon: "location", title: "Adres Bilgileri")
                    SettingsRow(icon: "creditcard", title: "Ödeme Yöntemleri")
                    SettingsRow(icon: "questionmark.circle", title: "Yardım")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)

                Button(action: {
                    showLogoutAlert = true
                }) {
                    Text("Çıkış Yap")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showLogoutAlert) {
                    Alert(
                        title: Text("Çıkış Yap"),
                        message: Text("Oturumunuzu kapatmak istediğinize emin misiniz?"),
                        primaryButton: .destructive(Text("Çıkış Yap")) {
                            logout()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var ordersView: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Siparişler yükleniyor...")
                    .padding()
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else if (viewModel.orders.isEmpty && viewModel.localOrders.isEmpty) {
                VStack(spacing: 16) {
                    Image(systemName: "bag")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Henüz siparişiniz yok.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
            } else {
                LazyVStack(spacing: 16) {
                    // Backend'den gelen siparişler
                    ForEach(viewModel.orders) { order in
                        BackendOrderCard(order: order)
                    }
                    // Local siparişler (ödeme sonrası)
                    ForEach(viewModel.localOrders) { order in
                        LocalOrderCard(order: order)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}

struct BackendOrderCard: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 15) {
                if let firstItem = order.orderItems?.first,
                   let product = firstItem.product {
                    if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Color.gray.opacity(0.2)
                            case .success(let image):
                                image.resizable()
                            case .failure(_):
                                Color.gray.opacity(0.2)
                            @unknown default:
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(width: 70, height: 70)
                        .cornerRadius(10)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 70, height: 70)
                            .cornerRadius(10)
                            .overlay(Text("Resim"))
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(product.name ?? "Ürün")
                            .font(.headline)
                        Text("Adet: \(firstItem.quantity ?? 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("₺\(firstItem.price ?? "-")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Text(order.status ?? "-")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(8)
            }
            Text("Toplam: ₺\(order.total ?? "-")")
                .font(.subheadline)
                .fontWeight(.bold)
            if let createdAt = order.createdAt,
               let date = ISO8601DateFormatter().date(from: createdAt) {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct LocalOrderCard: View {
    let order: LocalOrder

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Sipariş #\(order.orderNumber)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(order.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(order.status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(8)
            }
            Divider()
            ForEach(order.items) { item in
                HStack {
                    if let imageUrl = item.product.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Color.gray.opacity(0.3)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure(_):
                                Color.gray.opacity(0.3)
                            @unknown default:
                                Color.gray.opacity(0.3)
                            }
                        }
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                    }
                    VStack(alignment: .leading) {
                        Text(item.product.name ?? "Ürün")
                            .font(.subheadline)
                            .lineLimit(2)
                        Text("Adet: \(item.quantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("₺\(item.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            Divider()
            HStack {
                Text("Toplam:")
                    .font(.headline)
                Spacer()
                Text("₺\(order.totalAmount, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

// MARK: - UserView Extensions
extension UserView {
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Bildirim izni verildi.")
            } else if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
    }

    func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Bildirim Açıldı"
        content.body = "Sipariş bildirimleri artık açık!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func logout() {
        print("Çıkış yapıldı")
        showLoginView = true
    }

}

// MARK: - Preview
struct UserView_Previews: PreviewProvider {
    @State static var isLoggedIn = true
    @State static var sepet: Set<Int> = []
    @State static var favoriler: Set<Int> = []

    static var previews: some View {
        UserView(isLoggedIn: $isLoggedIn, sepet: $sepet, favoriler: $favoriler)
    }
} 
