import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:uninote/models/user.dart';
import 'package:uninote/services/auth_service.dart';
import 'package:uninote/screens/home_screen.dart';
import 'package:uninote/screens/register_screen.dart';
import 'package:uninote/screens/invite_access_screen.dart';
import 'package:uninote/utils/validators.dart';
import 'package:uninote/widgets/loading_indicator.dart';
import 'package:get_it/get_it.dart';

/// Kullanıcı giriş ekranı
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _authService = GetIt.instance<AuthService>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // Logo veya uygulama adı
                  const Center(
                    child: Text(
                      'UniNote',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Giriş formu
                  FormBuilder(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        // E-posta alanı
                        FormBuilderTextField(
                          name: 'email',
                          decoration: const InputDecoration(
                            labelText: 'E-posta',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),
                        // Şifre alanı
                        FormBuilderTextField(
                          name: 'password',
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible 
                                  ? Icons.visibility 
                                  : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 8),
                        // Şifremi unuttum linki
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Şifremi unuttum ekranına yönlendir
                            },
                            child: const Text('Şifremi Unuttum'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Hata mesajı
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        // Giriş butonu
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _login,
                            child: const Text(
                              'Giriş Yap',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Kaydol ve davet bağlantısı ile giriş seçenekleri
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Hesabınız yok mu?'),
                            TextButton(
                              onPressed: () {
                                // Kayıt ekranına yönlendir
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text('Kayıt Ol'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        // Davet bağlantısı ile erişim
                        Center(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.link),
                            label: const Text('Davet Bağlantısı ile Erişim'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const InviteAccessScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Giriş işlemini gerçekleştirir
  Future<void> _login() async {
    // Form doğrulama
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final formData = _formKey.currentState!.value;
        final loginRequest = LoginRequest(
          email: formData['email'],
          password: formData['password'],
        );

        print('Giriş bilgileri: ${loginRequest.toJson()}');
        final token = await _authService.login(loginRequest);
        print('Dönen token: $token');

        if (token != null) {
          // Giriş başarılı, ana ekrana yönlendir
          print('Giriş başarılı, ana ekrana yönlendir');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
        } else {
          // Giriş başarısız
          print('Giriş başarısız: token null');
          setState(() {
            _errorMessage = 'E-posta veya şifre hatalı';
            _isLoading = false;
          });
        }
      } catch (e) {
        // Hata durumu
        print('Login sırasında hata: $e');
        setState(() {
          _errorMessage = 'Bir hata oluştu: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
}
