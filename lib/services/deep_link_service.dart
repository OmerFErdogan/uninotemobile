import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uninote/screens/invite_access_screen.dart';

/// Deep Link işlemlerini yöneten servis
class DeepLinkService {
  final GlobalKey<NavigatorState> navigatorKey;
  
  DeepLinkService({required this.navigatorKey});

  /// Uygulama başladığında deep link'leri dinlemeye başlar
  Future<void> init() async {
    // NOT: Bu sınıf, "uni_links" paketi kullanılarak tamamlanmalıdır
    // pubspec.yaml dosyasına aşağıdaki dependency eklenmelidir:
    // uni_links: ^0.5.1
    
    // Bu fonksiyon, uygulama açıldığında gelen ilk deep link'i işler
    await _handleInitialUri();
    
    // Bu fonksiyon, uygulama çalışırken gelen deep link'leri dinler
    _handleIncomingLinks();
  }
  
  /// Uygulama açılışında gelen ilk URI'yi işler
  Future<void> _handleInitialUri() async {
    try {
      // uni_links paketi eklendikten sonra, bu kısım şu şekilde güncellenmelidir:
      // final initialUri = await getInitialUri();
      // if (initialUri != null) {
      //   _processUri(initialUri);
      // }
      
      print("Initial URI işleme hazır");
    } catch (e) {
      print("Initial URI işleme hatası: $e");
    }
  }
  
  /// Uygulama çalışırken gelen bağlantıları dinler
  void _handleIncomingLinks() {
    // uni_links paketi eklendikten sonra, bu kısım şu şekilde güncellenmelidir:
    // uriLinkStream.listen((Uri? uri) {
    //   if (uri != null) {
    //     _processUri(uri);
    //   }
    // }, onError: (Object err) {
    //   print('Bağlantı dinleme hatası: $err');
    // });
    
    print("Gelen bağlantıları dinleme hazır");
  }
  
  /// URI'yi işleyerek uygun ekrana yönlendirir
  void _processUri(Uri uri) {
    print("İşlenen URI: $uri");
    
    final pathSegments = uri.pathSegments;
    
    // notes/invite/{token} formatını kontrol et
    if (pathSegments.length >= 3 && 
        pathSegments[0] == 'notes' && 
        pathSegments[1] == 'invite') {
      final token = pathSegments[2];
      _navigateToInviteScreen(token);
    }
    // pdfs/invite/{token} formatını kontrol et
    else if (pathSegments.length >= 3 && 
             pathSegments[0] == 'pdfs' && 
             pathSegments[1] == 'invite') {
      final token = pathSegments[2];
      _navigateToInviteScreen(token);
    }
    // uninote://invite/{token} şemasını kontrol et
    else if (uri.scheme == 'uninote' && 
             uri.host == 'invite' && 
             pathSegments.isNotEmpty) {
      final token = pathSegments[0];
      _navigateToInviteScreen(token);
    }
    else {
      print("Desteklenmeyen URI formatı: $uri");
    }
  }
  
  /// Davet erişim ekranına yönlendirir
  void _navigateToInviteScreen(String token) {
    print("Davet erişim ekranına yönlendiriliyor, token: $token");
    
    // Navigasyon anahtarı ile geçerli navigator state'e erişerek yönlendirme yap
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => InviteAccessScreen(token: token),
      ),
    );
  }
  
  /// Açık bir şekilde gelen URI'yi işler (örneğin: sistem tarafından uygulama açıldığında)
  void handleUri(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      _processUri(uri);
    } catch (e) {
      print("URI işleme hatası: $e");
    }
  }
}
