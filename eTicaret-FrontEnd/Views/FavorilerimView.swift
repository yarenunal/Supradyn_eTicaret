import SwiftUI

struct FavorilerView: View {
    @Binding var favoriler: Set<Int>
    let products: [Product]

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var favoriUrunleri: [Product] {
        products.filter { favoriler.contains($0.id) }
    }

    var body: some View {
        VStack {
            if favoriUrunleri.isEmpty {
                Spacer()
                Text("Henüz favori ürününüz yok.")
                    .foregroundColor(.gray)
                    .font(.title2)
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(favoriUrunleri) { urun in
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
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 3)

                                // Favoriden çıkar butonu
                                Button(action: {
                                    favoriler.remove(urun.id)
                                }) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
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
        .navigationTitle("Favoriler")
    }
}

// --- PREVIEW ---
struct FavorilerView_Previews: PreviewProvider {
    static var previews: some View {
        FavorilerView(favoriler: .constant([1, 2]), products: [])
    }
}
