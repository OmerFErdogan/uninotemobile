# Aktif Bağlam

## Mevcut Çalışma Odağı
UniNote projesi şu anda başlangıç aşamasındadır. Temel dosya yapısı ve mimari oluşturulmuş, ancak çoğu bileşen henüz uygulanmamıştır. Mevcut odak, temel yapının tamamlanması ve ilk çalışan prototip sürümünün geliştirilmesidir.

## Son Değişiklikler
- Proje iskeleti oluşturuldu
- Temel dizin yapısı kuruldu (models, screens, services, utils, widgets)
- pubspec.yaml dosyasına gerekli bağımlılıklar eklendi
- main.dart dosyası oluşturuldu ve temel yapı kuruldu
- Boş model, ekran, servis ve widget dosyaları oluşturuldu

## Sonraki Adımlar

### Kısa Vadeli (1-2 Hafta)
1. **Veri Modellerinin Uygulanması**
   - User, Note ve PDF modellerinin tamamlanması
   - JSON serileştirme/deserileştirme işlevlerinin eklenmesi

2. **Servis Katmanının Geliştirilmesi**
   - AuthService'in uygulanması (giriş, kayıt, çıkış işlevleri)
   - ApiService'in uygulanması (backend ile iletişim)
   - StorageService'in uygulanması (yerel depolama)

3. **Temel UI Bileşenlerinin Oluşturulması**
   - CustomAppBar'ın tasarlanması ve uygulanması
   - NoteCard bileşeninin tasarlanması ve uygulanması
   - LoadingIndicator'ın uygulanması

4. **Giriş Ekranının Geliştirilmesi**
   - LoginScreen UI'ının tasarlanması
   - Form doğrulama mantığının uygulanması
   - AuthService ile entegrasyon

### Orta Vadeli (3-4 Hafta)
1. **Ana Ekranın Geliştirilmesi**
   - HomeScreen UI'ının tasarlanması
   - Not listesinin uygulanması
   - Kategori filtreleme özelliğinin eklenmesi

2. **Not Detay Ekranının Geliştirilmesi**
   - NoteDetailScreen UI'ının tasarlanması
   - Not düzenleme işlevselliğinin uygulanması
   - Not silme işlevselliğinin uygulanması

3. **PDF Desteğinin Eklenmesi**
   - PDF yükleme ve görüntüleme özelliğinin uygulanması
   - PDF'lere not ekleme özelliğinin uygulanması

4. **Arama ve Filtreleme Özelliklerinin Eklenmesi**
   - Notlar arasında arama yapma özelliğinin uygulanması
   - Filtreleme seçeneklerinin eklenmesi

### Uzun Vadeli (5+ Hafta)
1. **Senkronizasyon Mekanizmasının Geliştirilmesi**
   - Bulut senkronizasyonunun uygulanması
   - Çevrimdışı çalışma desteğinin eklenmesi

2. **Kullanıcı Profili Yönetiminin Eklenmesi**
   - Profil ekranının tasarlanması ve uygulanması
   - Kullanıcı ayarlarının uygulanması

3. **Test Kapsamının Genişletilmesi**
   - Birim testlerinin yazılması
   - Widget testlerinin yazılması
   - Entegrasyon testlerinin yazılması

4. **Performans Optimizasyonları**
   - Bellek kullanımının optimize edilmesi
   - UI performansının iyileştirilmesi

## Aktif Kararlar ve Değerlendirmeler

### Mimari Kararlar
1. **State Management Yaklaşımı**
   - Provider paketi, durum yönetimi için seçildi
   - Alternatif olarak Bloc veya Riverpod değerlendirildi, ancak Provider'ın daha basit ve proje için yeterli olduğuna karar verildi

2. **Veri Depolama Stratejisi**
   - Hassas veriler için flutter_secure_storage kullanılacak
   - Genel ayarlar için shared_preferences kullanılacak
   - Büyük veri yapıları için SQLite veya Hive değerlendirilecek

3. **API İletişim Stratejisi**
   - Dio paketi, HTTP istekleri için kullanılacak
   - Repository deseni, veri kaynağı detaylarını soyutlamak için uygulanacak
   - JWT tabanlı kimlik doğrulama kullanılacak

### UI/UX Kararları
1. **Tasarım Dili**
   - Material Design prensipleri takip edilecek
   - Özelleştirilmiş tema ve bileşenler kullanılacak

2. **Navigasyon Yapısı**
   - Tab tabanlı ana navigasyon
   - Drawer menüsü için ek seçenekler

3. **Duyarlı Tasarım**
   - Farklı ekran boyutları için duyarlı tasarım
   - Yatay ve dikey yönlendirme desteği

### Teknik Borç Değerlendirmeleri
1. **Kod Üretimi**
   - JSON serileştirme için kod üretimi kullanılacak
   - Tekrarlayan kod yapılarını azaltmak için kod üretimi değerlendirilecek

2. **Test Stratejisi**
   - Kritik iş mantığı için birim testleri öncelikli olacak
   - UI bileşenleri için widget testleri eklenecek
   - Kullanıcı akışları için entegrasyon testleri eklenecek

3. **Dokümantasyon**
   - Kod içi dokümantasyon standartları belirlenecek
   - API dokümantasyonu oluşturulacak
   - Geliştirici kılavuzu hazırlanacak

## Mevcut Zorluklar ve Riskler
1. **PDF İşleme Performansı**
   - Büyük PDF dosyalarının işlenmesi performans sorunlarına yol açabilir
   - Çözüm: Önbelleğe alma ve kademeli yükleme stratejileri değerlendirilecek

2. **Çevrimdışı Senkronizasyon**
   - Çevrimdışı değişikliklerin çakışma çözümlemesi karmaşık olabilir
   - Çözüm: Sağlam bir çakışma çözümleme stratejisi geliştirilecek

3. **Çoklu Platform Uyumluluğu**
   - Farklı platformlarda (Android, iOS, web) tutarlı deneyim sağlamak zor olabilir
   - Çözüm: Platform özel kodları minimize etmek ve kapsamlı test yapmak

4. **Ölçeklenebilirlik**
   - Kullanıcı tabanı büyüdükçe performans sorunları ortaya çıkabilir
   - Çözüm: Verimli veri yapıları ve algoritmaları kullanmak, erken optimizasyon yapmak
