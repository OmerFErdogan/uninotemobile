import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import 'package:uninote/services/invite_service.dart';
import 'package:uninote/screens/note_detail_screen.dart';
import 'package:uninote/screens/pdf_viewer_screen.dart';
import 'package:uninote/widgets/loading_indicator.dart';

/// Davet bağlantısı ile not veya PDF'e erişim ekranı
class InviteAccessScreen extends StatefulWidget {
  final String? token; // Opsiyonel - Doğrudan token verilebilir

  const InviteAccessScreen({super.key, this.token});

  @override
  State<InviteAccessScreen> createState() => _InviteAccessScreenState();
}

class _InviteAccessScreenState extends State<InviteAccessScreen> {
  final _inviteService = GetIt.instance<InviteService>();
  final _tokenController = TextEditingController();
  
  bool _isLoading = false;
  bool _isValidating = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    
    // Eğer widget'a doğrudan token verilmişse, otomatik olarak işle
    if (widget.token != null && widget.token!.isNotEmpty) {
      _tokenController.text = widget.token!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _accessContent();
      });
    }
  }
  
  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }
  
  /// Davet bağlantısı ile içeriğe erişir
  Future<void> _accessContent() async {
    // Token'i al ve temizle
    final token = _tokenController.text.trim();
    
    // Token boş mu kontrol et
    if (token.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen bir davet bağlantısı veya token girin';
      });
      return;
    }
    
    // URL'den token çıkar
    final extractedToken = _extractTokenFromInput(token);
    print('Extract edilen token: $extractedToken');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Önce token'ın geçerli olup olmadığını doğrula
      setState(() {
        _isValidating = true;
      });
      
      final validationResponse = await _inviteService.validateInvite(extractedToken);
      print('Doğrulama yanıtı: $validationResponse');
      
      setState(() {
        _isValidating = false;
      });
      
      if (validationResponse == null || !validationResponse.valid) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Geçersiz veya süresi dolmuş davet bağlantısı';
        });
        print('Doğrulama başarısız: ${validationResponse?.valid}');
        return;
      }
      
      // Yanıt geçerli ama eksik bilgi içeriyorsa ek bilgileri debugla
      if (validationResponse.contentId == null) {
        print('Uyarı: Doğrulama yanıtında contentId eksik!');
      }
      
      if (validationResponse.type == null) {
        print('Uyarı: Doğrulama yanıtında type eksik!');
      }
      
      // Backend'in değişikliği ile ilgili olabilecek alternatif yol - direkt token'la içeriğini almaya çalış
      // Doğrulama yanıtındaki içerik türünü kontrol edelim
      print('Doğrudan token ile içerik erişimi deneniyor: $extractedToken');
      print('Doğrulamada dönen içerik türü: ${validationResponse.type}');
      
      // içerik türüne göre doğru endpoint'i çağıralım
      if (validationResponse.type == 'note') {
        try {
          final note = await _inviteService.getNoteByInvite(extractedToken);
          print('Not getirme yanıtı: $note');
          
          if (note != null) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(
                    noteId: note.id!,
                    inviteToken: extractedToken, // Davet token'ını geçir
                  ),
                ),
              );
            }
            return; // Not bulundu, işlem tamamlandı
          }
        } catch (e) {
          print('Not getirme hatası: $e');
        }
      } else if (validationResponse.type == 'pdf') {
        try {
          final pdf = await _inviteService.getPdfByInvite(extractedToken);
          print('PDF getirme yanıtı: $pdf');
          
          if (pdf != null) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerScreen(pdfId: pdf.id!),
                ),
              );
            }
            return; // PDF bulundu, işlem tamamlandı
          }
        } catch (e) {
          print('PDF getirme hatası: $e');
        }
      } else {
        // Bilinmeyen içerik türü
        setState(() {
          _isLoading = false;
          _errorMessage = 'Bilinmeyen içerik türü: ${validationResponse.type}';
        });
        return;
      }
      
      // Buraya geldiysek, ne not ne de PDF bulunamadı
      setState(() {
        _isLoading = false;
        _errorMessage = 'Davet bağlantısı geçerli ancak içerik bulunamadı veya erişim reddedildi';
      });
    } catch (e) {
      print('İçerik erişim hatası: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'İçeriğe erişilirken bir hata oluştu: ${e.toString()}';
      });
    }
  }
  
  /// URL veya kullanıcı girdisinden token'ı çıkarır
  String _extractTokenFromInput(String input) {
    // Base64 formatında token, URL'de '=' içerebilir
    // Önce URL formatında mı kontrol et
    if (input.startsWith('http://') || input.startsWith('https://')) {
      try {
        final uri = Uri.parse(input);
        
        // URL'in son kısmını al
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          return pathSegments.last;
        }
      } catch (e) {
        print('URL ayrıştırma hatası: $e');
      }
    }
    
    // Tüm URL'i almak yerine sadece token kısmını almaya çalış
    if (input.contains('/')) {
      // Son bölümü al
      return input.split('/').last;
    }
    
    // Zaten token biçimindeyse olduğu gibi döndür
    return input;
  }
  
  /// Kullanıcıdan aldığı token'i temizler ve URL formatını temizler
  void _handleInput(String value) {
    // Var olan hata mesajını temizle
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }
  
  /// Kopyalama tuşuna basıldığında panodaki veriyi alır
  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      _tokenController.text = data.text!;
      _handleInput(data.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Davet Bağlantısı ile Erişim'),
        leading: _isLoading ? null : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingIndicator(size: 60),
                  const SizedBox(height: 16),
                  Text(
                    _isValidating
                        ? 'Davet bağlantısı doğrulanıyor...'
                        : 'İçerik yükleniyor...',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Açıklama kartı
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Davet Bağlantısı ile Erişim',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Bir davet bağlantısı aldıysanız, bu bağlantıyı kullanarak özel içeriklere erişebilirsiniz. '
                            'Bağlantının tamamını veya sadece token kısmını yapıştırabilirsiniz.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Token giriş alanı
                  TextField(
                    controller: _tokenController,
                    decoration: InputDecoration(
                      labelText: 'Davet Bağlantısı veya Token',
                      hintText: 'https://uninotes.com/notes/invite/token veya token',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.link),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.content_paste),
                        tooltip: 'Panodan Yapıştır',
                        onPressed: _pasteFromClipboard,
                      ),
                      errorText: _errorMessage,
                    ),
                    onChanged: _handleInput,
                    maxLines: 3,
                    minLines: 1,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Erişim butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('İçeriğe Eriş'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _accessContent,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Örnekler
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Geçerli Format Örnekleri:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• https://uninotes.com/notes/invite/abcdef123456\n'
                            '• abcdef123456\n'
                            '• notes/invite/abcdef123456',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
