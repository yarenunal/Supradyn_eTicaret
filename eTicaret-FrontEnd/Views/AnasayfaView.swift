import SwiftUI

struct AnasayfaView: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var isLoggedIn: Bool = true
    @State private var sepet: Set<Int> = []
    @State private var favoriler: Set<Int> = []
    @State private var searchText: String = ""
    @State private var showFilter = false
    @State private var minPrice: Double = 0
    @State private var maxPrice: Double = 1000

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var filteredProducts: [Product] {
        var filtered = viewModel.products

        // Arama filtresi
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        // Fiyat aralığı filtresi
        filtered = filtered.filter { product in
            if let price = Double(product.price) {
                return price >= minPrice && price <= maxPrice
            }
            return false
        }

        return filtered
    }

    var body: some View {
        TabView {
            // ANA SAYFA TAB
            NavigationStack {
                VStack(spacing: 0) {
                    // Arama çubuğu
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Ürün ara...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding([.horizontal, .top])

                    // Filtreleme butonu
                    HStack {
                        Button(action: {
                            showFilter = true
                        }) {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(.blue)
                                Text("Filtrele")
                                    .foregroundColor(.blue)
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }

                        Spacer()

                        // Aktif filtre etiketi
                        if minPrice > 0 || maxPrice < 1000 {
                            Text("₺\(minPrice, specifier: "%.0f") - ₺\(maxPrice, specifier: "%.0f")")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    if viewModel.products.isEmpty {
                        Spacer()
                        ProgressView("Yükleniyor...")
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredProducts) { urun in
                                    ZStack(alignment: .topTrailing) {
                                        VStack {
                                            if let imageUrl = urun.imageUrl, let url = URL(string: imageUrl) {
                                                AsyncImage(url: url) { image in
                                                    image.resizable()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(height: 120)
                                                .cornerRadius(10)
                                            } else {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(height: 120)
                                                    .cornerRadius(10)
                                                    .overlay(Text("Resim"))
                                            }

                                            Text(urun.name)
                                                .font(.headline)
                                                .lineLimit(1)
                                                .padding(.top, 4)

                                            if let price = Double(urun.price) {
                                                Text("₺\(price, specifier: "%.2f")")
                                                    .font(.subheadline)
                                                    .foregroundColor(.green)
                                            } else {
                                                Text("₺-")
                                                    .font(.subheadline)
                                                    .foregroundColor(.red)
                                            }

                                            Button(action: {
                                                sepet.insert(urun.id)
                                            }) {
                                                Text("Sepete Ekle")
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 6)
                                                    .padding(.horizontal, 16)
                                                    .background(Color.purple)
                                                    .cornerRadius(8)
                                            }
                                            .padding(.top, 4)
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(15)
                                        .shadow(radius: 3)

                                        // Favori butonu
                                        Button(action: {
                                            if favoriler.contains(urun.id) {
                                                favoriler.remove(urun.id)
                                            } else {
                                                favoriler.insert(urun.id)
                                            }
                                        }) {
                                            Image(systemName: favoriler.contains(urun.id) ? "heart.fill" : "heart")
                                                .foregroundColor(favoriler.contains(urun.id) ? .red : .gray)
                                                .font(.title2)
                                                .padding(8)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .shadow(radius: 2)
                                        }
                                        .padding(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                        }
                    }
                }
                .navigationTitle("Ürünler")
                .sheet(isPresented: $showFilter) {
                    FilterView(minPrice: $minPrice, maxPrice: $maxPrice)
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Anasayfa")
            }
            // SEPET TAB
            NavigationStack {
                SepetimView(sepet: $sepet, favoriler: $favoriler, products: viewModel.products)
            }
            .tabItem {
                Image(systemName: "cart.fill")
                Text("Sepetim")
            }
            // HESABIM TAB (YENİ)
                NavigationStack {
                    UserView(isLoggedIn: $isLoggedIn, sepet: $sepet, favoriler: $favoriler)
                }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Hesabım")
                }

            // FAVORİLER TAB
            NavigationStack {
                FavorilerView(favoriler: $favoriler, products: viewModel.products)
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Favoriler")
            }
        }
        .task {
            await viewModel.fetchProducts()
        }
    }
}

// --- FİLTRE VIEW ---
struct FilterView: View {
    @Binding var minPrice: Double
    @Binding var maxPrice: Double
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Fiyat Aralığı")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Minimum Fiyat: ₺\(minPrice, specifier: "%.0f")")
                        .font(.subheadline)

                    Slider(value: $minPrice, in: 0...maxPrice, step: 10)
                        .accentColor(.blue)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Maksimum Fiyat: ₺\(maxPrice, specifier: "%.0f")")
                        .font(.subheadline)

                    Slider(value: $maxPrice, in: minPrice...2000, step: 10)
                        .accentColor(.blue)
                }
                .padding(.horizontal)

                Spacer()

                Button(action: {
                    dismiss()
                }) {
                    Text("Uygula")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Filtrele")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// --- PREVIEW ---
struct AnasayfaView_Previews: PreviewProvider {
    static var previews: some View {
        AnasayfaView()
    }
}



