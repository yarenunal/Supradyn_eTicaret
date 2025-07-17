import SwiftUI

struct SepetimView: View {
    @Binding var sepet: Set<Int>
    @Binding var favoriler: Set<Int>
    let products: [Product]
    @State private var odemeyeGec = false

    // Sepetteki ürünler
    var sepetUrunleri: [Product] {
        products.filter { sepet.contains($0.id) }
    }

    // Toplam tutar (fiyat String ise)
    var toplamTutar: Double {
        sepetUrunleri.reduce(0) { toplam, urun in
            toplam + (Double(urun.price) ?? 0)
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if sepetUrunleri.isEmpty {
                    Spacer()
                    Text("Sepetiniz boş.")
                        .foregroundColor(.gray)
                        .font(.title2)
                    Spacer()
                } else {
                    List {
                        ForEach(sepetUrunleri) { product in
                            HStack(spacing: 16) {
                                if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .overlay(Text("Resim").font(.caption))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(product.name)
                                        .font(.headline)
                                    if let price = Double(product.price) {
                                        Text("₺\(price, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                    } else {
                                        Text("₺-")
                                            .font(.subheadline)
                                            .foregroundColor(.red)
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    if favoriler.contains(product.id) {
                                        favoriler.remove(product.id)
                                    } else {
                                        favoriler.insert(product.id)
                                    }
                                }) {
                                    Image(systemName: favoriler.contains(product.id) ? "heart.fill" : "heart")
                                        .foregroundColor(.red)
                                }
                                Button(action: {
                                    sepet.remove(product.id)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let product = sepetUrunleri[index]
                                sepet.remove(product.id)
                            }
                        }
                    }
                    .listStyle(.plain)

                    HStack {
                        Text("Toplam:")
                            .font(.headline)
                        Spacer()
                        Text("₺\(toplamTutar, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding()

                    NavigationLink(
                        destination: OdemeView(sepet: $sepet, favoriler: $favoriler, totalAmount: toplamTutar, products: products),
                        isActive: $odemeyeGec
                    ) {
                        Button(action: {
                            odemeyeGec = true
                        }) {
                            Text("Ödemeye Geç")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(sepetUrunleri.isEmpty ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(sepetUrunleri.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
            }
            .navigationTitle("Sepetim")
        }
    }
}
// --- PREVIEW ---
struct SepetimView_Previews: PreviewProvider {
    @State static var sepet: Set<Int> = [1]
    @State static var favoriler: Set<Int> = [2]
    static var previews: some View {
        SepetimView(sepet: $sepet, favoriler: $favoriler, products: [])
    }
}
