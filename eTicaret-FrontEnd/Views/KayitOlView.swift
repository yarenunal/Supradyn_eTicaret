//
//  KayitOlView.swift
//  eTicaret-FrontEnd
//
//  Created by Yaren on 16.07.2025.
//
import SwiftUI

struct KayitOlView: View {
    @Environment(\.dismiss) var dismiss
    @State private var kayitYontemi: GirisView.GirisYontemi = .eposta
    @State private var eposta: String = ""
    @State private var telefon: String = ""
    @State private var sifre: String = ""
    @State private var kayitBasarili: Bool = false
    @State private var hataMesaji: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Kayıt Ol")
                    .font(.largeTitle.bold())
                    .padding(.top, 40)

                Picker("Kayıt Yöntemi", selection: $kayitYontemi) {
                    ForEach(GirisView.GirisYontemi.allCases, id: \.self) { yontem in
                        Text(yontem.rawValue).tag(yontem)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                if kayitYontemi == .eposta {
                    TextField("E-posta", text: $eposta)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                } else {
                    TextField("Telefon Numarası", text: $telefon)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }

                SecureField("Şifre", text: $sifre)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                if let hata = hataMesaji {
                    Text(hata)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button(action: {
                    Task { await kayitOl() }
                }) {
                    Text("Kayıt Ol")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .alert("Kayıt Başarılı!", isPresented: $kayitBasarili) {
                Button("Tamam") { dismiss() }
            } message: {
                Text("Artık giriş yapabilirsiniz.")
            }
        }
    }

    // MARK: - Kayıt Fonksiyonu
    func kayitOl() async {
        hataMesaji = nil
        guard !sifre.isEmpty else {
            hataMesaji = "Şifre boş olamaz."
            return
        }
        var url = URL(string: "http://localhost:3000/api/auth/register")!
        var body: [String: String] = ["password": sifre]
        if kayitYontemi == .eposta {
            guard !eposta.isEmpty else {
                hataMesaji = "E-posta boş olamaz."
                return
            }
            body["email"] = eposta
        } else {
            guard !telefon.isEmpty else {
                hataMesaji = "Telefon boş olamaz."
                return
            }
            url = URL(string: "http://localhost:3000/api/auth/register-phone")!
            body["phone"] = telefon
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                await MainActor.run { kayitBasarili = true }
            } else {
                let mesaj = String(data: data, encoding: .utf8) ?? "Bilinmeyen hata"
                await MainActor.run { hataMesaji = "Kayıt başarısız: \(mesaj)" }
            }
        } catch {
            await MainActor.run { hataMesaji = "Sunucuya bağlanılamadı: \(error.localizedDescription)" }
        }
    }
}
#Preview {
    KayitOlView()
}
