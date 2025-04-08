# Teknik Bağlam

## Kullanılan Teknolojiler

### Temel Framework
- **Flutter**: Çoklu platform (Android, iOS, web) desteği sunan UI framework'ü
- **Dart**: Flutter uygulamalarının geliştirildiği programlama dili

### Paketler ve Kütüphaneler

#### Durum Yönetimi
- **provider (^6.1.2)**: Widget ağacı boyunca veri paylaşımı ve durum yönetimi için kullanılan kütüphane

#### Ağ İşlemleri
- **dio (^5.8.0+1)**: HTTP istekleri için kullanılan güçlü ve esnek HTTP istemcisi

#### Veri Depolama
- **flutter_secure_storage (^9.2.4)**: Hassas verilerin güvenli bir şekilde depolanması için kullanılan kütüphane
- **shared_preferences (^2.5.2)**: Basit anahtar-değer çiftlerinin yerel olarak depolanması için kullanılan kütüphane

#### Bağımlılık Enjeksiyonu
- **get_it (^8.0.3)**: Servis locator (hizmet bulucu) olarak kullanılan bağımlılık enjeksiyon kütüphanesi

#### UI Bileşenleri ve Yardımcılar
- **flutter_form_builder (^10.0.1)**: Form yönetimi ve doğrulama için kullanılan kütüphane
- **cached_network_image (^3.4.1)**: Ağ üzerinden gelen resimlerin önbelleğe alınması için kullanılan kütüphane
- **intl (^0.20.2)**: Uluslararasılaştırma ve tarih biçimlendirme için kullanılan kütüphane

#### Veri Modelleme ve İşleme
- **equatable (^2.0.5)**: Nesnelerin değer eşitliğini kolayca sağlamak için kullanılan kütüphane
- **dartz (^0.10.1)**: Fonksiyonel programlama yapıları (Either tipi vb.) için kullanılan kütüphane
- **json_annotation (^4.8.1)**: JSON serileştirme için model sınıflarını işaretlemek için kullanılan kütüphane

#### Geliştirme Araçları
- **build_runner (^2.4.8)**: Kod üretimi için kullanılan kütüphane
- **json_serializable (^6.7.1)**: JSON serileştirme kodunu otomatik olarak üretmek için kullanılan kütüphane
- **flutter_lints (^5.0.0)**: Kod kalitesini artırmak için lint kuralları sağlayan kütüphane

## Geliştirme Ortamı

### Gereksinimler
- **Flutter SDK**: En son kararlı sürüm
- **Dart SDK**: Flutter SDK ile birlikte gelen sürüm
- **IDE**: Visual Studio Code veya Android Studio
- **Git**: Sürüm kontrolü için

### Kurulum Adımları
1. Flutter SDK'yı [flutter.dev](https://flutter.dev/docs/get-started/install) adresinden indirin ve kurun
2. IDE'yi kurun (VS Code veya Android Studio)
3. Flutter ve Dart eklentilerini IDE'ye ekleyin
4. Projeyi klonlayın: `git clone <repo-url>`
5. Bağımlılıkları yükleyin: `flutter pub get`
6. Kod üretimini çalıştırın: `flutter pub run build_runner build`

### Geliştirme Komutları
- **Uygulamayı çalıştırma**: `flutter run`
- **Bağımlılıkları güncelleme**: `flutter pub upgrade`
- **Kod üretimi**: `flutter pub run build_runner build`
- **Temiz kod üretimi**: `flutter pub run build_runner build --delete-conflicting-outputs`
- **Sürekli kod üretimi**: `flutter pub run build_runner watch`
- **Test çalıştırma**: `flutter test`
- **APK oluşturma**: `flutter build apk`
- **iOS IPA oluşturma**: `flutter build ios`
- **Web sürümü oluşturma**: `flutter build web`

## Teknik Kısıtlamalar

### Platform Kısıtlamaları
- **Minimum Android Sürümü**: Android 5.0 (API level 21)
- **Minimum iOS Sürümü**: iOS 11.0
- **Web Tarayıcı Desteği**: Modern tarayıcılar (Chrome, Firefox, Safari, Edge)

### Performans Kısıtlamaları
- Büyük PDF dosyaları için bellek kullanımı optimize edilmelidir
- Ağ bağlantısı olmadığında çalışabilmek için çevrimdışı mod desteklenmelidir
- Mobil cihazlarda pil tüketimi göz önünde bulundurulmalıdır

### Güvenlik Kısıtlamaları
- Kullanıcı kimlik bilgileri güvenli bir şekilde saklanmalıdır
- API istekleri güvenli bir şekilde yapılmalıdır (HTTPS)
- Hassas veriler şifrelenmelidir

## Mimari Kısıtlamalar
- Katmanlı mimari prensiplerine uyulmalıdır
- İş mantığı UI'dan ayrılmalıdır
- Servisler ve modeller arasında bağımlılık enjeksiyonu kullanılmalıdır

## Dış Sistemler ve Entegrasyonlar

### Backend API
- RESTful API entegrasyonu
- JWT tabanlı kimlik doğrulama
- Dio kütüphanesi kullanılarak HTTP istekleri

### Depolama Servisleri
- Notlar ve PDF'ler için bulut depolama entegrasyonu
- Yerel önbellek mekanizması

### Kimlik Doğrulama Servisleri
- E-posta/şifre tabanlı kimlik doğrulama
- Potansiyel olarak sosyal medya ile giriş entegrasyonu

## Teknik Borç ve Gelecek Planları

### Mevcut Teknik Borç
- Model sınıfları henüz tam olarak uygulanmamıştır
- Servis katmanı henüz tam olarak uygulanmamıştır
- UI bileşenleri henüz tam olarak uygulanmamıştır
- Test kapsamı henüz oluşturulmamıştır

### Gelecek Teknik İyileştirmeler
- Kapsamlı test kapsama alanı eklenmesi (birim testleri, widget testleri, entegrasyon testleri)
- CI/CD pipeline kurulumu
- Performans optimizasyonları
- Erişilebilirlik iyileştirmeleri
- Çoklu dil desteği eklenmesi

### Planlanan Teknoloji Güncellemeleri
- Flutter ve Dart'ın en son sürümlerine düzenli güncellemeler
- Bağımlılıkların düzenli olarak güncellenmesi
- Yeni Flutter özellikleri ve en iyi uygulamaların benimsenmesi
