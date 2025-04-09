# UniNote Davet Bağlantıları Kullanım Kılavuzu

Bu belge, UniNote uygulamasında davet bağlantılarının (invite links) nasıl kullanılacağını ve gerekli yapılandırmaları açıklamaktadır.

## Davet Bağlantısı Nedir?

Davet bağlantıları, normalde özel olan içeriklerinizi (notlar veya PDF'ler) başkalarıyla güvenli bir şekilde paylaşmanızı sağlar. Bu bağlantılar, içeriğe erişim için gereken bir token içerir ve belirli bir süre sonra otomatik olarak sona erer.

## Davet Bağlantısı Oluşturma

1. **Not veya PDF Detay Ekranı**'nda sağ üst köşedeki "Paylaş" butonuna tıklayın.
2. "Paylaşım Bağlantıları" ekranında "Yeni Bağlantı Oluştur" düğmesine tıklayın.
3. İsterseniz, bağlantı için bir son kullanma tarihi belirleyin. Belirtmezseniz, bağlantı varsayılan olarak 7 gün sonra sona erer.
4. "Bağlantı Oluştur" düğmesine tıklayın.
5. Oluşturulan bağlantı, diğer bağlantılar listesinde görünecektir.
6. Bağlantıyı kopyalamak için "Kopyala" veya "Paylaş" düğmesine tıklayın.

## Davet Bağlantısı ile Erişim

#### Mobil Uygulama Kullanarak Erişim:

1. UniNote uygulamasını açın.
2. Giriş ekranında "Davet Bağlantısı ile Erişim" düğmesini tıklayın.
3. Aldığınız davet bağlantısını veya token'ı girin.
4. "İçeriğe Eriş" düğmesine tıklayın.

#### Oturum Açmış Kullanıcılar İçin:

1. Ana ekrandan profil menüsüne tıklayın.
2. "Davet Bağlantısı ile Erişim" seçeneğini seçin.
3. Bağlantıyı veya token'ı girin ve "İçeriğe Eriş" düğmesine tıklayın.

#### Web Tarayıcı Kullanarak Erişim:

Davet bağlantısını (örn. `https://uninotes.com/notes/invite/token`) doğrudan tarayıcınıza yapıştırın. Web uygulaması içeriği gösterecektir.

## Davet Bağlantısı Yönetimi

- **Bağlantıları Görüntüleme**: İçerik detay sayfasından "Paylaş" düğmesine tıklayarak mevcut tüm bağlantılarınızı görüntüleyebilirsiniz.
- **Bağlantıyı Devre Dışı Bırakma**: Bir bağlantıyı devre dışı bırakmak için, bağlantı listesinde "Devre Dışı Bırak" düğmesine tıklayın.
- **Yeni Bağlantı Oluşturma**: İstediğiniz zaman aynı içerik için birden fazla bağlantı oluşturabilirsiniz.

## Güvenlik ve Gizlilik

- Davet bağlantıları, yalnızca bağlantıya sahip olan kişilere içeriğe erişim sağlar.
- Özel içeriklerinizin güvenliği için bağlantıları yalnızca güvendiğiniz kişilerle paylaşın.
- Bağlantıların süresi dolduktan sonra veya devre dışı bırakıldıktan sonra artık erişilemez.

## Mobil Uygulamalar İçin Deep Link Yapılandırması

UniNote uygulamasının harici davet bağlantılarına tepki verebilmesi için, aşağıdaki yapılandırmaların tamamlanması gerekmektedir:

### Android Yapılandırması

`android/app/src/main/AndroidManifest.xml` dosyasına aşağıdaki yapılandırmayı ekleyin:

```xml
<manifest ...>
    <application ...>
        <!-- Mevcut activity tanımı -->
        <activity
            android:name=".MainActivity"
            ...>
            
            <!-- Intent filter ekleyin -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                
                <!-- https://uninotes.com/notes/invite/TOKEN formatı için -->
                <data
                    android:scheme="https"
                    android:host="uninotes.com"
                    android:pathPattern="/notes/invite/.*" />
                
                <!-- https://uninotes.com/pdfs/invite/TOKEN formatı için -->
                <data
                    android:scheme="https"
                    android:host="uninotes.com"
                    android:pathPattern="/pdfs/invite/.*" />
                
                <!-- Özel uninote:// şema için (opsiyonel) -->
                <data
                    android:scheme="uninote"
                    android:host="invite" />
            </intent-filter>
            
            ...
        </activity>
        ...
    </application>
</manifest>
```

### iOS Yapılandırması

`ios/Runner/Info.plist` dosyasına aşağıdaki yapılandırmayı ekleyin:

```xml
<dict>
    <!-- Diğer ayarlar... -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.example.uninote</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>uninote</string>
            </array>
        </dict>
    </array>
    
    <!-- Universal Links için yapılandırma -->
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:uninotes.com</string>
    </array>
</dict>
```

Ayrıca, Apple'ın Universal Links sistemini kullanmak için `apple-app-site-association` dosyasını web sunucunuza eklemeniz gerekecektir.

### Deep Link Yönlendirme Servisi Uygulaması

Yukarıdaki yapılandırmaları tamamladıktan sonra, uygulamanızda gelen deep link'leri işleyecek bir servis eklemeniz gerekecektir. Bunun için aşağıdaki paketleri kullanabilirsiniz:

1. `uni_links`: Gelen deep link'leri dinlemek ve yakalamak için.
2. `flutter_uri_router`: URI'leri belirli ekranlara yönlendirmek için.

Basit bir örnek uygulama:

```dart
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

// Uygulama başlangıcında ilk deep link'i yakalamak için
Future<void> initDeepLinks() async {
  try {
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }
    
    // Uygulama çalışırken gelen deep link'leri dinleme
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri.toString());
      }
    }, onError: (error) {
      print('Deep link hata: $error');
    });
  } on PlatformException {
    print('Platform exception deep link işlemede');
  }
}

// Deep link'i işleme
void _handleDeepLink(String link) {
  print('Gelen link: $link');
  
  final uri = Uri.parse(link);
  final pathSegments = uri.pathSegments;
  
  if (pathSegments.length >= 3) {
    if (pathSegments[0] == 'notes' && pathSegments[1] == 'invite') {
      final token = pathSegments[2];
      // Not davet bağlantısı ekranına yönlendir
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => InviteAccessScreen(token: token),
      ));
    } else if (pathSegments[0] == 'pdfs' && pathSegments[1] == 'invite') {
      final token = pathSegments[2];
      // PDF davet bağlantısı ekranına yönlendir
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => InviteAccessScreen(token: token),
      ));
    }
  }
}
```

Bu örnekte:
- `navigatorKey`: Ana Material uygulamanızda tanımlanmış global bir `GlobalKey<NavigatorState>` olmalıdır.
- Yönlendirme mantığı basit URI parçalama ile yapılmaktadır.

## Web Platformu İçin Yapılandırma

Flutter web uygulaması için davet bağlantılarını desteklemek:

```dart
// web/index.html
<script>
  // Sayfa yüklendiğinde çalışacak script
  window.addEventListener('load', function () {
    // URL'den token'ı çıkar
    var currentUrl = window.location.href;
    if (currentUrl.includes('/notes/invite/') || currentUrl.includes('/pdfs/invite/')) {
      // Flutter uygulamasına URL'i bildirmek için gerekli kod
      window.flutterWebInvite = currentUrl;
    }
  });
</script>
```

Flutter uygulamanız içinde:

```dart
import 'dart:html' as html;

void checkWebInviteLink() {
  if (html.window.hasProperty('flutterWebInvite')) {
    final inviteUrl = html.window.getPropertyValue('flutterWebInvite');
    _handleDeepLink(inviteUrl);
  }
}
```

## Örnek Kullanım Senaryoları

1. **Özel Not Paylaşımı**: Bir öğrenci, özel ders notlarını sadece sınıf arkadaşlarıyla paylaşmak istiyor. Davet bağlantısı oluşturup WhatsApp grubunda paylaşır.

2. **Sınırlı Süreli Erişim**: Bir öğretmen, bir sınav öncesinde belirli bir PDF'i öğrencileriyle paylaşır, ancak sadece sınav tarihine kadar erişim sağlar.

3. **İçerik Kontrolü**: Bir kullanıcı, içeriğini kimlerin görüntülediğini takip etmek için her kişiye farklı bir davet bağlantısı gönderir.

4. **Güvenli Belge Paylaşımı**: Hassas bilgiler içeren bir belgeyi, sadece belirli kişilerin erişebileceği şekilde paylaşmak için davet bağlantısı kullanılır.

## Sık Sorulan Sorular

**S: Davet bağlantımın süresini uzatabilir miyim?**
C: Hayır, mevcut bir bağlantının süresini uzatamazsınız. Bunun yerine, daha uzun süreli yeni bir bağlantı oluşturmanız gerekir.

**S: Davet bağlantısını kullanan kişileri görebilir miyim?**
C: Şu anda bu özellik mevcut değildir, ancak gelecekteki güncellemelerde eklenebilir.

**S: Aynı içerik için kaç davet bağlantısı oluşturabilirim?**
C: Teorik olarak sınırsız sayıda davet bağlantısı oluşturabilirsiniz.

**S: Bağlantıyı devre dışı bıraktığımda, bağlantıyı kullanan kişilerin erişimi hemen kesilir mi?**
C: Evet, bağlantıyı devre dışı bıraktığınızda, o bağlantıyı kullanan herkesin erişimi anında kesilir.
