# UniNote - Üniversite Not Paylaşım Uygulaması

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.7+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.7+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License: MIT"/>
  <img src="https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge" alt="Version: 1.0.0"/>
</p>

UniNote, üniversite öğrencileri arasında not paylaşımını kolaylaştırmak için geliştirilmiş bir mobil uygulamadır. Öğrenciler derslerle ilgili notlarını paylaşabilir, diğer öğrencilerin notlarını görüntüleyebilir ve beğenebilirler.

## 📱 Özellikler

- **Kullanıcı Kimlik Doğrulama**
  - Kayıt, giriş ve profil yönetimi
  - Güvenli token bazlı kimlik doğrulama

- **Not Yönetimi**
  - Not oluşturma, düzenleme ve silme
  - Özel veya herkese açık not paylaşımı
  - Etiketlerle notları kategorilere ayırma

- **Keşif ve Sosyal Etkileşim**
  - Herkese açık notları keşfetme
  - Notları beğenme ve yorum yapma
  - Popüler notları görüntüleme

- **Arama ve Filtreleme**
  - Not içeriklerinde arama yapma
  - Etiketlere göre filtreleme

## 🛠️ Teknik Özellikler

- **Mimari**: Servis tabanlı mimari
- **Durum Yönetimi**: Provider ve GetIt
- **Ağ İşlemleri**: Dio
- **Yerel Depolama**: Flutter Secure Storage, Shared Preferences
- **Veri Modelleri**: JSON Serializable & Equatable
- **UI Framework**: Flutter Material Design

## 📂 Proje Yapısı

```
lib/
├── config/           # Uygulama yapılandırma dosyaları
├── models/           # Veri modelleri
├── screens/          # Uygulama ekranları
├── services/         # API ve diğer servisler
├── utils/            # Yardımcı sınıf ve fonksiyonlar
├── widgets/          # Yeniden kullanılabilir UI bileşenleri
└── main.dart         # Uygulama giriş noktası
```

## 🚀 Başlangıç

### Ön Koşullar

- Flutter SDK (sürüm 3.7.0 veya üstü)
- Dart SDK (sürüm 3.7.0 veya üstü)
- Android Studio / VS Code
- Bir Android/iOS emülatörü veya fiziksel cihaz

### Kurulum ve Çalıştırma

1. Projeyi klonlayın
```bash
git clone https://github.com/kullaniciadi/uninote.git
cd uninote
```

2. Bağımlılıkları yükleyin
```bash
flutter pub get
```

3. Devmode'da çalıştırın
```bash
flutter run
```

### Yapı Oluşturma

#### Android için APK
```bash
flutter build apk --release
```

#### iOS için
```bash
flutter build ios --release
```

## 📦 Kullanılan Paketler

Başlıca paketler:
- [dio](https://pub.dev/packages/dio) - HTTP istekleri için
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) - Güvenli token depolama
- [get_it](https://pub.dev/packages/get_it) - Bağımlılık enjeksiyonu
- [provider](https://pub.dev/packages/provider) - Durum yönetimi
- [equatable](https://pub.dev/packages/equatable) - Veri modellerini daha kolay karşılaştırma
- [json_annotation](https://pub.dev/packages/json_annotation) - JSON serileştirme

Diğer paketler için [pubspec.yaml](pubspec.yaml) dosyasına bakabilirsiniz.

## 🔒 Güvenlik Özellikleri

- JWT Token tabanlı API kimlik doğrulama
- Hassas verilerin Flutter Secure Storage ile şifrelenmiş saklanması
- HTTPS bağlantı desteği

## 🧪 Test

```bash
flutter test
```

## 🔧 Sorun Giderme

Yaygın sorunlar ve çözümleri:

1. **Bağlantı Sorunları**: API'ye erişim sağlanamıyorsa, internet bağlantınızı kontrol edin ve sunucunun çalışır durumda olduğundan emin olun.

2. **Kimlik Doğrulama Hataları**: Oturum süreniz dolmuş olabilir. Yeniden giriş yapmayı deneyin.

3. **Render Overflow**: Bazı ekranlarda metin uzunluğuna bağlı olarak taşma olabilir. Bu normal bir durumdur ve kaydırma ile tüm içeriğe erişilebilir.

## 📝 Geliştirme Planı

Gelecek sürümlerde eklenmesi planlanan özellikler:

- Offline modda çalışma
- PDF dosyalarını destekleme
- Grup notları ve işbirliği
- Bildirim sistemi
- Tema değiştirme özelliği

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.

## 👥 Katkıda Bulunanlar

- Ömer - [GitHub](https://github.com/omerusername)

## 📞 İletişim

Sorularınız veya geri bildirimleriniz için:
- Email: omerferdogandeveloper@email.com
- GitHub: [Sorun Bildir](https://github.com/OmerFErdogan/uninote/issues)
