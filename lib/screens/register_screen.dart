import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:uninote/models/user.dart';
import 'package:uninote/services/auth_service.dart';
import 'package:uninote/screens/login_screen.dart';
import 'package:uninote/utils/validators.dart';
import 'package:uninote/widgets/loading_indicator.dart';
import 'package:uninote/config/api_config.dart';
import 'package:get_it/get_it.dart';

/// Kullanıcı kayıt ekranı
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _authService = GetIt.instance<AuthService>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
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
                  const SizedBox(height: 32),
                  // Kayıt formu
                  FormBuilder(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        // Kullanıcı adı alanı
                        FormBuilderTextField(
                          name: 'username',
                          decoration: const InputDecoration(
                            labelText: 'Kullanıcı Adı',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: Validators.username,
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        // Şifre tekrar alanı
                        FormBuilderTextField(
                          name: 'passwordConfirm',
                          decoration: InputDecoration(
                            labelText: 'Şifre Tekrar',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible 
                                  ? Icons.visibility 
                                  : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isConfirmPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifre tekrar alanı boş olamaz';
                            }
                            final password = _formKey.currentState?.fields['password']?.value;
                            if (value != password) {
                              return 'Şifreler eşleşmiyor';
                            }
                            return null;
                          },
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
                        // Kayıt butonu
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _register,
                            child: const Text(
                              'Kayıt Ol',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Giriş yap linki
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Zaten hesabınız var mı?'),
                            TextButton(
                              onPressed: () {
                                // Giriş ekranına yönlendir
                                Navigator.pop(context);
                              },
                              child: const Text('Giriş Yap'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Kayıt işlemini gerçekleştirir
  Future<void> _register() async {
    // Önce odak noktalarını temizle
    FocusScope.of(context).unfocus();
    
    // Form doğrulama
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final formData = _formKey.currentState!.value;
        
        // Kayıt isteği oluştur - API'nin gerektirdiği diğer alanlar için varsayılan değerler kullan
        final registerRequest = RegisterRequest(
          username: formData['username'],
          email: formData['email'],
          password: formData['password'],
          firstName: 'Kullanıcı', // Varsayılan ad
          lastName: formData['username'], // Kullanıcı adını kullan
          university: 'Belirtilmemiş', // Varsayılan üniversite
          department: 'Belirtilmemiş', // Varsayılan bölüm
          classYear: 'Belirtilmemiş', // Varsayılan sınıf
        );
        
        print('Kayıt isteği: ${registerRequest.toJson()}');
        final success = await _authService.register(registerRequest);

        if (success) {
          // Kayıt başarılı, giriş ekranına yönlendir
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kayıt başarılı! Giriş yapabilirsiniz.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          }
        } else {
          // Kayıt başarısız
          setState(() {
            _errorMessage = 'Kayıt işlemi başarısız oldu. Lütfen tekrar deneyin.';
            _isLoading = false;
          });
        }
      } catch (e) {
        // Hata durumu
        print('Kayıt işleminde hata: $e');
        setState(() {
          if (e.toString().contains('connection error')) {
            _errorMessage = ApiConfig.connectionError;
          } else if (e.toString().contains('timeout')) {
            _errorMessage = ApiConfig.timeoutError;
          } else {
            _errorMessage = 'Kayıt işlemi sırasında hata: ${e.toString()}';
          }
          _isLoading = false;
        });
      }
    }
  }
}
