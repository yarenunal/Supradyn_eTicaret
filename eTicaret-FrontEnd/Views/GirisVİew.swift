import SwiftUI

struct GirisView: View {
    @State private var girisYontemi: GirisYontemi = .eposta
    @State private var eposta: String = ""
    @State private var telefon: String = ""
    @State private var sifre: String = ""
    @State private var girisBasarili: Bool = false
    @State private var hataMesaji: String?
    @State private var kayitOlEkrani: Bool = false

    enum GirisYontemi: String, CaseIterable {
        case eposta = "E-posta"
        case telefon = "Telefon"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Giriş Yap")
                    .font(.largeTitle.bold())
                    .padding(.top, 40)

                Picker("Giriş Yöntemi", selection: $girisYontemi) {
                    ForEach(GirisYontemi.allCases, id: \.self) { yontem in
                        Text(yontem.rawValue).tag(yontem)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                if girisYontemi == .eposta {
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

                // NavigationDestination ile AnasayfaView'a yönlendirme
                NavigationLink(destination: AnasayfaViewWrapper(), isActive: $girisBasarili) {
                    EmptyView()
                }

                Button(action: {
                    Task { await girisYap() }
                }) {
                    Text("Giriş Yap")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()

                HStack {
                    Text("Hesabınız yok mu?")
                        .font(.footnote)
                    Button("Kayıt Ol") {
                        kayitOlEkrani = true
                    }
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
                .padding(.bottom, 20)
            }
            .padding()
            .sheet(isPresented: $kayitOlEkrani) {
                KayitOlView()
            }
        }
    }

    // MARK: - Giriş Fonksiyonu
    func girisYap() async {
        hataMesaji = nil
        guard !sifre.isEmpty else {
            hataMesaji = "Şifre boş olamaz."
            return
        }
        var url = URL(string: "http://localhost:3000/api/auth/login")!
        var body: [String: String] = ["password": sifre]
        if girisYontemi == .eposta {
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
            url = URL(string: "http://localhost:3000/api/auth/login-phone")!
            body["phone"] = telefon
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                await MainActor.run { girisBasarili = true }
            } else {
                let mesaj = String(data: data, encoding: .utf8) ?? "Bilinmeyen hata"
                await MainActor.run { hataMesaji = "Giriş başarısız: \(mesaj)" }
            }
        } catch {
            await MainActor.run { hataMesaji = "Sunucuya bağlanılamadı: \(error.localizedDescription)" }
        }
    }
}
// MARK: - Preview
#Preview {
    GirisView()
}
