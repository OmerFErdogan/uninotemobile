import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:uninote/services/api_service.dart';
import 'package:uninote/services/auth_service.dart';
import 'package:uninote/services/note_service.dart';
import 'package:uninote/services/pdf_service.dart';
import 'package:uninote/services/storage_service.dart';
import 'package:uninote/services/invite_service.dart';
import 'package:uninote/services/view_service.dart';
import 'package:uninote/services/deep_link_service.dart';
import 'package:uninote/screens/login_screen.dart';

// GetIt instance
final GetIt getIt = GetIt.instance;

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bağımlılıkları kaydet
  _setupDependencies();

  // Deep Link'leri ayarla
  // TODO: Derin bağlantıları yönetmek için uni_links paketi eklenmelidir
  // Bu paket, uygulama açılışında veya çalışma sırasında gelen linkleri yakalayabilir.
  final deepLinkService = getIt<DeepLinkService>();
  await deepLinkService.init();

  runApp(const MyApp());
}

/// Bağımlılıkları kaydeder
void _setupDependencies() {
  // Dio instance
  getIt.registerLazySingleton<Dio>(() => Dio());

  // FlutterSecureStorage instance
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // ApiService instance
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(
      dio: getIt<Dio>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  // AuthService instance
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
      apiService: getIt<ApiService>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );
  
  // NoteService instance
  getIt.registerLazySingleton<NoteService>(
    () => NoteService(
      apiService: getIt<ApiService>(),
    ),
  );
  
  // StorageService instance
  getIt.registerLazySingleton<StorageService>(
    () => StorageService(getIt<Dio>()),
  );
  
  // PDFService instance
  getIt.registerLazySingleton<PDFService>(
    () => PDFService(getIt<Dio>()),
  );
  
  // InviteService instance
  getIt.registerLazySingleton<InviteService>(
    () => InviteService(
      apiService: getIt<ApiService>(),
    ),
  );
  
  // ViewService instance
  getIt.registerLazySingleton<ViewService>(
    () => ViewService(
      apiService: getIt<ApiService>(),
    ),
  );
  
  // DeepLinkService instance
  getIt.registerLazySingleton<DeepLinkService>(
    () => DeepLinkService(
      navigatorKey: navigatorKey,
    ),
  );
}

/// Uygulamanın kök widget'ı.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PDFService>(
          create: (_) => getIt<PDFService>(),
        ),
        Provider<StorageService>(
          create: (_) => getIt<StorageService>(),
        ),
        Provider<InviteService>(
          create: (_) => getIt<InviteService>(),
        ),
        Provider<ViewService>(
          create: (_) => getIt<ViewService>(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // Global navigator key eklendi
        title: 'UniNote',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }
}
