import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:uninote/models/user.dart';
import 'package:uninote/services/auth_service.dart';
import 'package:uninote/utils/validators.dart';
import 'package:uninote/widgets/loading_indicator.dart';
import 'package:get_it/get_it.dart';

/// Kullanıcı profil ekranı
class ProfileScreen extends StatefulWidget {
  /// Kullanıcı bilgileri
  final User? user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _passwordFormKey = GlobalKey<FormBuilderState>();
  final _authService = GetIt.instance<AuthService>();
  bool _isLoading = false;
  bool _isPasswordLoading = false;
  String? _errorMessage;
  String? _passwordErrorMessage;
  String? _successMessage;
  String? _passwordSuccessMessage;
  bool _showPasswordForm = false;

  @override
  void initState() {
    super.initState();
    // Form alanlarını kullanıcı bilgileriyle doldur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.user != null) {
        _formKey.currentState?.patchValue({
          'firstName': widget.user!.firstName,
          'lastName': widget.user!.lastName,
          'university': widget.user!.university,
          'department': widget.user!.department,
          'classYear': widget.user!.classYear,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: widget.user == null
          ? const Center(
              child: Text('Kullanıcı bilgileri yüklenemedi'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Kullanıcı bilgileri
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                widget.user!.firstName[0] + widget.user!.lastName[0],
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              widget.user!.fullName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              widget.user!.email,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'Kullanıcı Adı: ${widget.user!.username}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Üniversite: ${widget.user!.university}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bölüm: ${widget.user!.department}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sınıf: ${widget.user!.classYear}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Profil güncelleme formu
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profil Bilgilerini Güncelle',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _isLoading
                              ? const LoadingIndicator()
                              : FormBuilder(
                                  key: _formKey,
                                  autovalidateMode: AutovalidateMode.disabled,
                                  child: Column(
                                    children: [
                                      // Ad alanı
                                      FormBuilderTextField(
                                        name: 'firstName',
                                        decoration: const InputDecoration(
                                          labelText: 'Ad',
                                          prefixIcon: Icon(Icons.person_outline),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: Validators.firstName,
                                      ),
                                      const SizedBox(height: 16),
                                      // Soyad alanı
                                      FormBuilderTextField(
                                        name: 'lastName',
                                        decoration: const InputDecoration(
                                          labelText: 'Soyad',
                                          prefixIcon: Icon(Icons.person_outline),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: Validators.lastName,
                                      ),
                                      const SizedBox(height: 16),
                                      // Üniversite alanı
                                      FormBuilderTextField(
                                        name: 'university',
                                        decoration: const InputDecoration(
                                          labelText: 'Üniversite',
                                          prefixIcon: Icon(Icons.school),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: Validators.university,
                                      ),
                                      const SizedBox(height: 16),
                                      // Bölüm alanı
                                      FormBuilderTextField(
                                        name: 'department',
                                        decoration: const InputDecoration(
                                          labelText: 'Bölüm',
                                          prefixIcon: Icon(Icons.business),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: Validators.department,
                                      ),
                                      const SizedBox(height: 16),
                                      // Sınıf alanı
                                      FormBuilderTextField(
                                        name: 'classYear',
                                        decoration: const InputDecoration(
                                          labelText: 'Sınıf',
                                          prefixIcon: Icon(Icons.class_),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: Validators.classYear,
                                      ),
                                      const SizedBox(height: 16),
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
                                      // Başarı mesajı
                                      if (_successMessage != null)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: Text(
                                            _successMessage!,
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      // Güncelleme butonu
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: _updateProfile,
                                          child: const Text(
                                            'Profili Güncelle',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Şifre değiştirme butonu
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Şifre Değiştir',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(_showPasswordForm
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down),
                                onPressed: () {
                                  setState(() {
                                    _showPasswordForm = !_showPasswordForm;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_showPasswordForm) ...[
                            const SizedBox(height: 16),
                            _isPasswordLoading
                                ? const LoadingIndicator()
                                : FormBuilder(
                                    key: _passwordFormKey,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    child: Column(
                                      children: [
                                        // Eski şifre alanı
                                        FormBuilderTextField(
                                          name: 'oldPassword',
                                          decoration: const InputDecoration(
                                            labelText: 'Eski Şifre',
                                            prefixIcon: Icon(Icons.lock),
                                            border: OutlineInputBorder(),
                                          ),
                                          obscureText: true,
                                          validator: Validators.oldPassword,
                                        ),
                                        const SizedBox(height: 16),
                                        // Yeni şifre alanı
                                        FormBuilderTextField(
                                          name: 'newPassword',
                                          decoration: const InputDecoration(
                                            labelText: 'Yeni Şifre',
                                            prefixIcon: Icon(Icons.lock),
                                            border: OutlineInputBorder(),
                                          ),
                                          obscureText: true,
                                          validator: Validators.newPassword,
                                          onChanged: (_) {
                                            // Şifre değiştiğinde formu yeniden doğrula
                                            _passwordFormKey.currentState?.validate();
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        // Yeni şifre tekrar alanı
                                        FormBuilderTextField(
                                          name: 'newPasswordConfirm',
                                          decoration: const InputDecoration(
                                            labelText: 'Yeni Şifre Tekrar',
                                            prefixIcon: Icon(Icons.lock),
                                            border: OutlineInputBorder(),
                                          ),
                                          obscureText: true,
                                          validator: (value) {
                                            if (value != _passwordFormKey.currentState?.fields['newPassword']?.value) {
                                              return 'Şifreler eşleşmiyor';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        // Hata mesajı
                                        if (_passwordErrorMessage != null)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 16),
                                            child: Text(
                                              _passwordErrorMessage!,
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.error,
                                              ),
                                            ),
                                          ),
                                        // Başarı mesajı
                                        if (_passwordSuccessMessage != null)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 16),
                                            child: Text(
                                              _passwordSuccessMessage!,
                                              style: const TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        // Şifre değiştirme butonu
                                        SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: _changePassword,
                                            child: const Text(
                                              'Şifreyi Değiştir',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Profil güncelleme işlemini gerçekleştirir
  Future<void> _updateProfile() async {
    // Form doğrulama
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });

      try {
        final formData = _formKey.currentState!.value;
        final updateProfileRequest = UpdateProfileRequest(
          firstName: formData['firstName'],
          lastName: formData['lastName'],
          university: formData['university'],
          department: formData['department'],
          classYear: formData['classYear'],
        );

        final success = await _authService.updateProfile(updateProfileRequest);

        if (success) {
          // Güncelleme başarılı
          setState(() {
            _successMessage = 'Profil başarıyla güncellendi';
            _isLoading = false;
          });
        } else {
          // Güncelleme başarısız
          setState(() {
            _errorMessage = 'Profil güncellenirken bir hata oluştu';
            _isLoading = false;
          });
        }
      } catch (e) {
        // Hata durumu
        setState(() {
          _errorMessage = 'Bir hata oluştu: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// Şifre değiştirme işlemini gerçekleştirir
  Future<void> _changePassword() async {
    // Form doğrulama
    if (_passwordFormKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isPasswordLoading = true;
        _passwordErrorMessage = null;
        _passwordSuccessMessage = null;
      });

      try {
        final formData = _passwordFormKey.currentState!.value;
        final changePasswordRequest = ChangePasswordRequest(
          oldPassword: formData['oldPassword'],
          newPassword: formData['newPassword'],
        );

        final success = await _authService.changePassword(changePasswordRequest);

        if (success) {
          // Şifre değiştirme başarılı
          setState(() {
            _passwordSuccessMessage = 'Şifre başarıyla değiştirildi';
            _isPasswordLoading = false;
          });
          // Formu temizle
          _passwordFormKey.currentState?.reset();
        } else {
          // Şifre değiştirme başarısız
          setState(() {
            _passwordErrorMessage = 'Şifre değiştirilirken bir hata oluştu';
            _isPasswordLoading = false;
          });
        }
      } catch (e) {
        // Hata durumu
        setState(() {
          _passwordErrorMessage = 'Bir hata oluştu: ${e.toString()}';
          _isPasswordLoading = false;
        });
      }
    }
  }
}
