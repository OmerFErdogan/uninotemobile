import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:uninote/services/api_service.dart';
import 'package:uninote/services/auth_service.dart';
import 'package:uninote/services/note_service.dart';
import 'package:uninote/screens/login_screen.dart';

// GetIt instance
final GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bağımlılıkları kaydet
  _setupDependencies();

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
}

/// Uygulamanın kök widget'ı.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Şimdilik Provider kullanmıyoruz, doğrudan MaterialApp döndürüyoruz
    return MaterialApp(
      title: 'UniNote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
    );
  }
}
