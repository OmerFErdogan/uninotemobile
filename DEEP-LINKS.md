# UniNote Deep Link (Derin Bağlantı) Yapılandırması

Bu belge, UniNote uygulamasının derin bağlantı (deep link) yapılandırmasını açıklar. Bu yapılandırma sayesinde, kullanıcılar web tarayıcıları veya diğer uygulamalar üzerinden UniNote'a yönlendirilebilir ve doğrudan belirli içeriklere (notlar, PDF'ler) erişebilirler.

## Yapılandırılan Bağlantı Formatları

UniNote uygulaması şu an aşağıdaki bağlantı formatlarını desteklemektedir:

1. **Web URL Formatı**
   - Not için: `https://uninotes.com/notes/invite/{TOKEN}`
   - PDF için: `https://uninotes.com/pdfs/invite/{TOKEN}`

2. **Özel Şema Formatı**
   - `uninote://invite/{TOKEN}`

## Teknik Uygulama

### Android Yapılandırması

Android yapılandırması `AndroidManifest.xml` dosyasında aşağıdaki intent filtreleri ile sağlanmıştır:

```xml
<!-- Web URL formatları için -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    
    <data
        android:scheme="https"
        android:host="uninotes.com"
        android:pathPattern="/notes/invite/.*" />
    
    <data
        android:scheme="https"
        android:host="uninotes.com"
        android:pathPattern="/pdfs/invite/.*" />
</intent-filter>

<!-- Özel şema için -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    
    <data
        android:scheme="uninote"
        android:host="invite" />
</intent-filter>
```

### iOS Yapılandırması

iOS yapılandırması `Info.plist` dosyasında şu şekilde sağlanmıştır:

```xml
<!-- URL şema tanımları -->
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

<!-- Universal Links yapılandırması -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:uninotes.com</string>
</array>
```

### Web Sunucusu Yapılandırması

#### iOS Universal Links için Apple App Site Association Dosyası

iOS'un Universal Links özelliğini kullanabilmek için, web sunucunuza `.well-known` dizini altında `apple-app-site-association` adlı bir dosya eklemeniz gerekmektedir:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.example.uninote",
        "paths": [
          "/notes/invite/*",
          "/pdfs/invite/*"
        ]
      }
    ]
  }
}
```

**Not:** `TEAM_ID` kısmını Apple Developer hesabınızdan alacağınız gerçek Team ID ile değiştirmeniz gerekmektedir.

#### Android App Links için Digital Asset Links Dosyası

Android App Links özelliğini kullanabilmek için, web sunucunuza `.well-known` dizini altında `assetlinks.json` adlı bir dosya eklemeniz gerekmektedir:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.example.uninote",
      "sha256_cert_fingerprints": ["YOUR_APP_FINGERPRINT"]
    }
  }
]
```

**Not:** `YOUR_APP_FINGERPRINT` kısmını, Android uygulamanızın imza parmak izi ile değiştirmeniz gerekmektedir.

## Uygulama İçi İşleme

Uygulamanın web bağlantılarını ve özel şema bağlantılarını işlemesi için `DeepLinkService` sınıfı oluşturulmuştur. Bu servis, `uni_links` paketini kullanarak:

1. Uygulama başlangıcında ilk deep link'i yakalamak için `getInitialUri()` fonksiyonunu kullanır.
2. Uygulama çalışırken gelen deep link'leri dinlemek için `uriLinkStream` Stream'ini dinler.

## Nasıl Test Edilir?

### Android'de Test Etme

1. Terminal veya Command Prompt'ta şu komutu çalıştırın:
   ```
   adb shell am start -a android.intent.action.VIEW -d "https://uninotes.com/notes/invite/TEST_TOKEN" com.example.uninote
   ```

   veya özel şema için:
   ```
   adb shell am start -a android.intent.action.VIEW -d "uninote://invite/TEST_TOKEN" com.example.uninote
   ```

2. Alternatif olarak, bir test web sayfası oluşturup aşağıdaki linkleri deneyebilirsiniz:
   ```html
   <a href="https://uninotes.com/notes/invite/TEST_TOKEN">Web URL Test</a>
   <a href="uninote://invite/TEST_TOKEN">Özel Şema Test</a>
   ```

### iOS'ta Test Etme

1. Gerçek bir cihazda Universal Links'i test etmek için Safari'de `https://uninotes.com/notes/invite/TEST_TOKEN` adresine gidin.

2. Özel şema için, Safari'de aşağıdaki HTML sayfasını test edebilirsiniz:
   ```html
   <a href="uninote://invite/TEST_TOKEN">Özel Şema Test</a>
   ```

## Sorun Giderme

1. **Android'de bağlantılar açılmıyor:**
   - `AndroidManifest.xml` dosyasındaki intent filtrelerin doğru yapılandırıldığından emin olun.
   - Uygulama paket adının `AndroidManifest.xml` içinde doğru olduğundan emin olun.

2. **iOS'ta Universal Links çalışmıyor:**
   - Apple Developer hesabınızda "Associated Domains" özelliğinin etkinleştirildiğinden emin olun.
   - Doğru team ID'yi kullandığınızdan emin olun.
   - Web sunucunuzdaki `apple-app-site-association` dosyasının HTTPS üzerinden erişilebilir olduğundan emin olun.

3. **uni_links paketi hataları:**
   - En son sürümün yüklü olduğundan emin olun: `flutter pub upgrade uni_links`
   - iOS için, `Info.plist` dosyasında gerekli yapılandırmaların olduğundan emin olun.
   - Android için, `AndroidManifest.xml` dosyasında gerekli intent filtrelerin olduğundan emin olun.

## Sık Sorulan Sorular

**S: Davet bağlantısını kullanan kişi uygulamayı yüklü değilse ne olur?**
C: Web formatı bağlantılar için (`https://uninotes.com/...`), kullanıcı web sayfasına yönlendirilir. Burada, uygulamayı indirmeleri için bir teşvik gösterilebilir veya içerik web arayüzünde gösterilebilir.

**S: Özel şema bağlantıları (`uninote://...`) telefonda uygulama yüklü değilse ne olur?**
C: Bu bağlantılar, uygulama yüklü değilse bir hata veya hiçbir şey göstermez. Bu nedenle, paylaşım için web formatı URL'leri kullanmak daha güvenlidir.

**S: Farklı platformlarda (Android, iOS, web) nasıl tutarlı bir deneyim sağlayabilirim?**
C: Çok platformlu uygulamalarda, her zaman web URL formatını (`https://uninotes.com/...`) kullanın ve uygulamanın platformlar arası çalışması için gerekli tüm yapılandırmaları tamamlayın.
