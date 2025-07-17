//
//  OdemeView.swift
//  eTicaret-FrontEnd
//
//  Created by Yaren on 16.07.2025.
//
import SwiftUI

struct OdemeView: View {
    @Binding var sepet: Set<Int>
    @Binding var favoriler: Set<Int>
    @ObservedObject private var userOrdersViewModel = UserOrdersViewModel.shared
    @State private var cardName: String = ""
    @State private var cardNumber: String = ""
    @State private var expiry: String = ""
    @State private var cvv: String = ""
    @State private var isPaymentSuccess: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss

    // Sepet toplamı dışarıdan alınır
    var totalAmount: Double
    let products: [Product]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Ödeme Yap")
                    .font(.largeTitle.bold())
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Kart Üzerindeki İsim")
                        .font(.subheadline)
                    TextField("Ad Soyad", text: $cardName)
                        .textContentType(.name)
                        .autocapitalization(.words)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    Text("Kart Numarası")
                        .font(.subheadline)
                    TextField("1234 5678 9012 3456", text: $cardNumber)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Son Kullanma")
                                .font(.subheadline)
                            TextField("AA/YY", text: $expiry)
                                .keyboardType(.numbersAndPunctuation)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                        }
                        VStack(alignment: .leading) {
                            Text("CVV")
                                .font(.subheadline)
                            SecureField("123", text: $cvv)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                        }
                    }
                }

                HStack {
                    Text("Toplam Tutar:")
                        .font(.headline)
                    Spacer()
                    Text("₺\(totalAmount, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding(.vertical, 10)

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button(action: {
                    pay()
                }) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Ödemeyi Tamamla")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading)

                Spacer()
            }
            .padding()
            .navigationTitle("Ödeme")
            .alert("Ödeme Başarılı!", isPresented: $isPaymentSuccess) {
                Button("Tamam") {
                    // Sepetteki ürünleri al
                    let cartProducts = products.filter { sepet.contains($0.id) }
                    // Siparişi kaydet
                    userOrdersViewModel.addLocalOrder(items: cartProducts, totalAmount: totalAmount)
                    // Sepeti temizle
                    sepet.removeAll()
                    // Anasayfaya dön
                    dismiss()
                }
            } message: {
                Text("Siparişiniz alınmıştır. Teşekkürler!")
            }
        }
    }

    func pay() {
        // Basit validasyon
        errorMessage = nil
        guard !cardName.isEmpty, !cardNumber.isEmpty, !expiry.isEmpty, !cvv.isEmpty else {
            errorMessage = "Lütfen tüm alanları doldurun."
            return
        }
        isLoading = true
        // Burada backend'e ödeme isteği atabilirsin
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            isPaymentSuccess = true
        }
    }
}

// MARK: - Preview
#Preview {
    OdemeView(sepet: .constant([]), favoriler: .constant([]), totalAmount: 499.99, products: [])
}
