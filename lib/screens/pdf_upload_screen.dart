import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/pdf.dart';
import '../services/pdf_service.dart';
import '../widgets/loading_indicator.dart';
import '../utils/validators.dart';

class PDFUploadScreen extends StatefulWidget {
  final PDF? pdf; // Düzenleme modu için

  const PDFUploadScreen({Key? key, this.pdf}) : super(key: key);

  @override
  _PDFUploadScreenState createState() => _PDFUploadScreenState();
}

class _PDFUploadScreenState extends State<PDFUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _isPublic = true;
  bool _isLoading = false;
  File? _selectedFile;
  String? _selectedFileName;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.pdf != null) {
      _isEditMode = true;
      _titleController.text = widget.pdf!.title;
      _descriptionController.text = widget.pdf!.description;
      _tagsController.text = widget.pdf!.tags.join(', ');
      _isPublic = widget.pdf!.isPublic;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickPDF() async {
    try {
      // Web platformu kontrolü
      if (!kIsWeb) {
        // Mobil platformlarda izin kontrolü
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          // İzin iste
          status = await Permission.storage.request();
          if (!status.isGranted) {
            _showErrorSnackBar('Dosya seçmek için depolama izni gereklidir.');
            return;
          }
        }
      }
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        if (kIsWeb) {
          // Web için özel işleme
          setState(() {
            _selectedFileName = result.files.single.name;
            // Web'de File nesnesi ile çalışmak farklıdır
            // Burada bytes ile çalışmak gerekebilir
          });
          debugPrint('Web - Seçilen dosya: ${result.files.single.name}');
          debugPrint('Web - Dosya boyutu: ${result.files.single.size} bytes');
        } else {
          // Mobil için işleme
          setState(() {
            _selectedFile = File(result.files.single.path!);
            _selectedFileName = result.files.single.name;
          });
          debugPrint('Seçilen dosya: ${_selectedFile!.path}');
          debugPrint('Dosya boyutu: ${await _selectedFile!.length()} bytes');
        }
      }
    } catch (e) {
      debugPrint('PDF seçme hatası: $e');
      _showErrorSnackBar('PDF seçilirken bir hata oluştu: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isEditMode) {
      if (kIsWeb) {
        if (_selectedFileName == null) {
          _showErrorSnackBar('Lütfen bir PDF dosyası seçin.');
          return;
        }
      } else {
        if (_selectedFile == null) {
          _showErrorSnackBar('Lütfen bir PDF dosyası seçin.');
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final pdfService = Provider.of<PDFService>(context, listen: false);
      final List<String> tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      debugPrint('Form gönderiliyor...');
      debugPrint('Başlık: ${_titleController.text}');
      debugPrint('Açıklama: ${_descriptionController.text}');
      debugPrint('Etiketler: $tags');
      debugPrint('Herkese açık: $_isPublic');
      
      if (_isEditMode) {
        debugPrint('PDF güncelleniyor...');
        await pdfService.updatePDF(
          id: widget.pdf!.id!,
          title: _titleController.text,
          description: _descriptionController.text,
          tags: tags,
          isPublic: _isPublic,
        );
        _showSuccessSnackBar('PDF başarıyla güncellendi');
      } else {
        debugPrint('PDF yükleniyor...');
        // Web platformu için
        if (kIsWeb) {
          // PDF yükleme ekranını web için özel olarak güncelledik
          // Ancak şu anda web platformunda tam PDF yükleme desteği yok
          _showErrorSnackBar('Web yüzünden PDF yükleme işlemi tamamlanamıyor.');
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context, false); 
          return;
        } else {
          debugPrint('Dosya boyutu: ${await _selectedFile!.length()} bytes');
          
          await pdfService.uploadPDF(
            file: _selectedFile!,
            title: _titleController.text,
            description: _descriptionController.text,
            tags: tags,
            isPublic: _isPublic,
          );
          _showSuccessSnackBar('PDF başarıyla yüklendi');
        }
      }
      
      setState(() {
        _isLoading = false;
      });
      
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(_isEditMode 
          ? 'PDF güncellenirken bir hata oluştu: $e' 
          : 'PDF yüklenirken bir hata oluştu: $e');
      debugPrint('Form gönderme hatası: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
  title: Text(_isEditMode ? 'PDF Düzenle' : 'PDF Yükle'),
  ),
  body: _isLoading
  ? const Center(child: LoadingIndicator())
  : SingleChildScrollView(
  child: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Form(
  key: _formKey,
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
  if (!_isEditMode) ...[                        
  if (kIsWeb) ...[                          
  // Web platformu için bilgilendirme metni
  const Card(
  color: Colors.lightBlue,
  child: Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
      children: [
          Icon(Icons.info, color: Colors.white, size: 30),
            SizedBox(height: 8),
            Text(
                'Web tarayıcısında PDF yükleme işlemi sınırlı özelliklere sahiptir. En iyi deneyim için lütfen mobil uygulama kullanın.',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16)
                        ],
                        ElevatedButton.icon(
                          icon: const Icon(Icons.file_upload),
                          label: Text(_selectedFileName != null
                              ? 'Seçilen Dosya: $_selectedFileName'
                              : 'PDF Seç'),
                          onPressed: _pickPDF,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Başlık',
                          border: OutlineInputBorder(),
                        ),
                        validator: Validators.requiredField,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Açıklama',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: Validators.requiredField,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Etiketler (virgülle ayırın)',
                          border: OutlineInputBorder(),
                          hintText: 'matematik, fizik, ders notları',
                        ),
                        validator: Validators.requiredField,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Herkese Açık'),
                        subtitle: const Text(
                          'Açık olarak işaretlerseniz, PDF\'iniz tüm kullanıcılar tarafından görüntülenebilir.',
                        ),
                        value: _isPublic,
                        onChanged: (bool value) {
                          setState(() {
                            _isPublic = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          _isEditMode ? 'Güncelle' : 'Yükle',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}