# UniNote API Entegrasyonu

Bu belge, UniNote uygulamasında gerçekleştirilen API entegrasyonlarını ve ilgili özellikleri açıklar.

## Uygulanan API Endpoint'leri

### Kimlik Doğrulama (Auth) API
- ✅ `POST /api/v1/register` - Kayıt olma işlemi
- ✅ `POST /api/v1/login` - Giriş yapma işlemi
- ✅ `GET /api/v1/profile` - Profil bilgilerini getirme
- ✅ `PUT /api/v1/profile` - Profil bilgilerini güncelleme
- ✅ `POST /api/v1/change-password` - Şifre değiştirme

### Not (Note) API
- ✅ `POST /api/v1/notes` - Not oluşturma
- ✅ `PUT /api/v1/notes/{id}` - Not güncelleme
- ✅ `DELETE /api/v1/notes/{id}` - Not silme
- ✅ `GET /api/v1/notes/{id}` - Not getirme
- ✅ `GET /api/v1/notes/my` - Kullanıcının notlarını getirme
- ✅ `GET /api/v1/notes` - Herkese açık notları getirme
- ✅ `GET /api/v1/notes/liked` - Beğenilen notları getirme
- ✅ `POST /api/v1/notes/{id}/comments` - Nota yorum ekleme
- ✅ `GET /api/v1/notes/{id}/comments` - Not yorumlarını getirme
- ✅ `POST /api/v1/notes/{id}/like` - Not beğenme
- ✅ `DELETE /api/v1/notes/{id}/like` - Not beğenisini kaldırma

### PDF API
- ✅ `POST /api/v1/pdfs` - PDF yükleme
- ✅ `PUT /api/v1/pdfs/{id}` - PDF güncelleme
- ✅ `DELETE /api/v1/pdfs/{id}` - PDF silme
- ✅ `GET /api/v1/pdfs/{id}` - PDF getirme
- ✅ `GET /api/v1/pdfs/{id}/content` - PDF içeriğini getirme
- ✅ `GET /api/v1/pdfs/my` - Kullanıcının PDF'lerini getirme
- ✅ `GET /api/v1/pdfs` - Herkese açık PDF'leri getirme
- ✅ `POST /api/v1/pdfs/{id}/comments` - PDF'e yorum ekleme
- ✅ `GET /api/v1/pdfs/{id}/comments` - PDF yorumlarını getirme
- ✅ `POST /api/v1/pdfs/{id}/like` - PDF beğenme
- ✅ `DELETE /api/v1/pdfs/{id}/like` - PDF beğenisini kaldırma
- ✅ `GET /api/v1/pdfs/liked` - Beğenilen PDF'leri getirme

### Davet Bağlantısı (Invite) API - Yeni Eklenen
- ✅ `POST /api/v1/notes/{id}/invites` - Not için davet bağlantısı oluşturma
- ✅ `POST /api/v1/pdfs/{id}/invites` - PDF için davet bağlantısı oluşturma
- ✅ `GET /api/v1/notes/{id}/invites` - Not için davet bağlantılarını getirme
- ✅ `GET /api/v1/pdfs/{id}/invites` - PDF için davet bağlantılarını getirme
- ✅ `DELETE /api/v1/invites/{id}` - Davet bağlantısını devre dışı bırakma
- ✅ `GET /api/v1/invites/{token}` - Davet bağlantısını doğrulama
- ✅ `GET /api/v1/notes/invite/{token}` - Davet bağlantısı ile not getirme
- ✅ `GET /api/v1/pdfs/invite/{token}` - Davet bağlantısı ile PDF getirme

### Görüntüleme Takip (View) API - Yeni Eklenen
- ✅ `GET /api/v1/notes/{id}/view` - Not görüntüleme
- ✅ `GET /api/v1/pdfs/{id}/view` - PDF görüntüleme
- ✅ `GET /api/v1/views/content/{type}/{id}` - İçerik görüntüleme kayıtlarını getirme
- ✅ `GET /api/v1/views/user` - Kullanıcı görüntüleme kayıtlarını getirme
- ✅ `GET /api/v1/views/check` - Görüntüleme durumu kontrolü

## API Entegrasyonları için Eklenen Yeni Bileşenler

### Model Sınıfları
- `Invite` - Davet bağlantısı modeli
- `CreateInviteRequest` - Davet bağlantısı oluşturma isteği modeli
- `InviteValidationResponse` - Davet bağlantısı doğrulama yanıtı
- `ContentView` - İçerik görüntüleme kaydı modeli
- `ViewCheckResponse` - Görüntüleme durumu kontrolü yanıtı
- `ViewListResponse` - Görüntüleme listesi yanıtı

### Servis Sınıfları
- `InviteService` - Davet bağlantısı işlemleri için servis
- `ViewService` - Görüntüleme takip işlemleri için servis

### Ekran Sınıfları
- `InviteScreen` - Davet bağlantılarını yönetmek için ekran
- `ViewedContentScreen` - Görüntülenen içerikleri listelemek için ekran

## Yapılan Değişiklikler ve İyileştirmeler

### API Yapılandırması
- `ApiConfig` sınıfına yeni endpoint temel URL'leri eklendi
- Endpoint sabitleri daha modüler bir yapıya dönüştürüldü

### Bağımlılık Enjeksiyonu
- Yeni servisler GetIt aracılığıyla bağımlılık enjeksiyon sistemine kaydedildi
- Provider listesine yeni servisler eklendi

### Kullanıcı Arayüzü
- Not ve PDF detay ekranlarına davet bağlantısı oluşturma ve yönetme özellikleri eklendi
- Ana ekrana görüntülenen içerikleri listeleme ekranına erişim eklendi
- Profil menüsüne yeni özellikler için seçenekler eklendi

## Kullanım Örneği

### Davet Bağlantısı Oluşturma
1. Not veya PDF detay ekranında "Paylaş" butonuna tıklayın
2. Açılan ekranda "Yeni Bağlantı Oluştur" butonuna tıklayın
3. İsterseniz son kullanma tarihi belirleyebilirsiniz (varsayılan: 7 gün)
4. Oluşturulan bağlantıyı kopyalayıp paylaşabilirsiniz

### Görüntülenen İçerikleri İnceleme
1. Ana ekranda sağ üst köşedeki profil butonuna tıklayın
2. Açılan menüden "Görüntülediğim İçerikler" seçeneğini seçin
3. Görüntülenen ekranda notlar ve PDF'ler sekmeleri arasında geçiş yapabilirsiniz
4. Listeye tıklayarak ilgili içeriğe gidebilirsiniz

## Gelecek Çalışmalar

- Arama ve filtreleme özellikleri tam olarak uygulanabilir
- PDF işaretleme sistemi geliştirilebilir
- Kullanıcı arayüzüne daha fazla analitik ve istatistik özellikleri eklenebilir
- Davet bağlantıları için daha gelişmiş yönetim özellikleri eklenebilir
