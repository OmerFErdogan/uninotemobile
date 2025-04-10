import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uninote/models/note.dart';
import 'package:uninote/services/note_service.dart';

class CreateNoteScreen extends StatefulWidget {
  final Note? existingNote; // Düzenleme için mevcut not
  
  const CreateNoteScreen({
    super.key, 
    this.existingNote,
  });

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final NoteService _noteService = GetIt.instance<NoteService>();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  
  bool _isPublic = true;
  bool _isSubmitting = false;
  bool _hasUnsavedChanges = false;
  bool _isEditMode = false;
  
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  final FocusNode _tagsFocusNode = FocusNode();

  // Önerilen etiketler listesi
  final List<String> _suggestedTags = [
    'üniversite', 'matematik', 'fizik', 'kimya', 'biyoloji', 
    'edebiyat', 'tarih', 'coğrafya', 'felsefe', 'psikoloji',
    'bilgisayar', 'programlama', 'flutter', 'dart', 'python',
    'sınav', 'proje', 'ödev', 'makale', 'araştırma'
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Eğer varolan bir not varsa, bilgileri doldur
    if (widget.existingNote != null) {
      _isEditMode = true;
      _titleController.text = widget.existingNote!.title;
      _contentController.text = widget.existingNote!.content;
      _tagsController.text = widget.existingNote!.tags.join(', ');
      _isPublic = widget.existingNote!.isPublic;
    }
    
    // Text değişikliklerini dinle
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
    _tagsController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onTextChanged);
    _tagsController.removeListener(_onTextChanged);
    
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _tagsFocusNode.dispose();
    
    super.dispose();
  }
  
  void _onTextChanged() {
    final hasText = _titleController.text.isNotEmpty || 
                   _contentController.text.isNotEmpty || 
                   _tagsController.text.isNotEmpty;
                   
    // Düzenleme modunda ise ve içerik değiştiyse
    final hasChanges = _isEditMode && (
      _titleController.text != widget.existingNote!.title ||
      _contentController.text != widget.existingNote!.content ||
      _tagsController.text != widget.existingNote!.tags.join(', ') ||
      _isPublic != widget.existingNote!.isPublic
    );
    
    final newHasUnsavedChanges = _isEditMode ? hasChanges : hasText;
    
    if (_hasUnsavedChanges != newHasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = newHasUnsavedChanges;
      });
    }
  }
  
  // Etikete tıklandığında
  void _onTagTap(String tag) {
    final currentTags = _tagsController.text.isEmpty 
        ? <String>[]
        : _tagsController.text.split(',').map((e) => e.trim()).toList();
    
    if (currentTags.contains(tag)) {
      // Zaten varsa kaldır
      currentTags.remove(tag);
    } else {
      // Yoksa ekle
      currentTags.add(tag);
    }
    
    _tagsController.text = currentTags.join(', ');
  }
  
  // Seçilen etiketleri kontrol et
  bool _isTagSelected(String tag) {
    if (_tagsController.text.isEmpty) return false;
    
    final currentTags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .toList();
        
    return currentTags.contains(tag);
  }

  // Not oluştur/güncelle
  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final tags = _tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        if (_isEditMode && widget.existingNote != null) {
          // Not güncelleme
          final request = UpdateNoteRequest(
            title: _titleController.text,
            content: _contentController.text,
            tags: tags,
            isPublic: _isPublic,
          );

          final updatedNote = await _noteService.updateNote(widget.existingNote!.id!, request);

          setState(() {
            _isSubmitting = false;
          });

          if (updatedNote != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Not başarıyla güncellendi'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Başarı ile güncellendi bilgisiyle dön
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Not güncellenirken bir hata oluştu'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Yeni not oluşturma
          final request = CreateNoteRequest(
            title: _titleController.text,
            content: _contentController.text,
            tags: tags,
            isPublic: _isPublic,
          );

          final createdNote = await _noteService.createNote(request);

          setState(() {
            _isSubmitting = false;
          });

          if (createdNote != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Not başarıyla oluşturuldu'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Başarı ile oluşturuldu bilgisiyle dön
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Not oluşturulurken bir hata oluştu'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('Not kaydetme hatası: $e');
        setState(() {
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Not kaydedilirken bir hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    
    // Çıkış yapmak istediğinde değişiklik varsa uyar
    return WillPopScope(
      onWillPop: () async {
        if (!_hasUnsavedChanges) return true;
        
        // Değişiklikler varsa kullanıcıya sor
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Kaydedilmemiş Değişiklikler'),
            content: const Text('Kaydedilmemiş değişiklikleriniz var. Çıkmak istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Çık'),
              ),
            ],
          ),
        );
        
        return result ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'Notu Düzenle' : 'Yeni Not'),
          actions: [
            // Kaydet butonu
            _isSubmitting
                ? const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.save),
                    tooltip: 'Kaydet',
                    onPressed: _hasUnsavedChanges ? _saveNote : null,
                  ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Başlık alanı
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Başlık',
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade800,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      prefixIcon: Icon(
                        Icons.title,
                        color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade800,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir başlık girin';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_contentFocusNode);
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 16.0),
              
              // İçerik alanı
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description,
                              color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade800,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'İçerik',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                      TextFormField(
                        controller: _contentController,
                        focusNode: _contentFocusNode,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(fontSize: 16.0),
                        decoration: const InputDecoration(
                          hintText: 'Not içeriğini yazın...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        ),
                        maxLines: 15,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen içerik girin';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_tagsFocusNode);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16.0),
              
              // Etiket alanı
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _tagsController,
                          focusNode: _tagsFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Etiketler (virgülle ayırın)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintText: 'örn: üniversite, fizik, matematik',
                            prefixIcon: Icon(
                              Icons.tag,
                              color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ),
                      
                      // Önerilen etiketler
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Önerilen Etiketler:',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _suggestedTags.map((tag) {
                                final isSelected = _isTagSelected(tag);
                                return InkWell(
                                  onTap: () => _onTagTap(tag),
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDarkMode ? Colors.blue.shade700 : Colors.blue.shade100)
                                          : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(20.0),
                                      border: Border.all(
                                        color: isSelected
                                            ? (isDarkMode ? Colors.blue.shade400 : Colors.blue.shade400)
                                            : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          tag,
                                          style: TextStyle(
                                            color: isSelected
                                                ? (isDarkMode ? Colors.white : Colors.blue.shade700)
                                                : (isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(width: 4.0),
                                          Icon(
                                            Icons.check,
                                            size: 16.0,
                                            color: isDarkMode ? Colors.white : Colors.blue.shade700,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16.0),
              
              // Görünürlük ayarı
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Görünürlük:',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: _buildVisibilityOption(
                              title: 'Herkese Açık',
                              icon: Icons.public,
                              isSelected: _isPublic,
                              description: 'Tüm kullanıcılar görebilir',
                              onTap: () {
                                setState(() {
                                  _isPublic = true;
                                  _onTextChanged();
                                });
                              },
                              isDarkMode: isDarkMode,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: _buildVisibilityOption(
                              title: 'Özel',
                              icon: Icons.lock,
                              isSelected: !_isPublic,
                              description: 'Sadece siz görebilirsiniz',
                              onTap: () {
                                setState(() {
                                  _isPublic = false;
                                  _onTextChanged();
                                });
                              },
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32.0),
              
              // Kaydet butonu
              ElevatedButton(
                onPressed: _isSubmitting || !_hasUnsavedChanges ? null : _saveNote,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSubmitting)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      const Icon(Icons.save),
                    const SizedBox(width: 8.0),
                    Text(_isEditMode ? 'Notu Güncelle' : 'Notu Kaydet'),
                  ],
                ),
              ),
              
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
  
  // Görünürlük seçeneği widget'ı
  Widget _buildVisibilityOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required String description,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.blue.shade900 : Colors.blue.shade50)
              : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected
                ? (isDarkMode ? Colors.blue.shade400 : Colors.blue.shade400)
                : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
            width: 2.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? (isDarkMode ? Colors.blue.shade200 : Colors.blue.shade700)
                      : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? (isDarkMode ? Colors.blue.shade200 : Colors.blue.shade700)
                          : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade700,
                  ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              description,
              style: TextStyle(
                fontSize: 12.0,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
