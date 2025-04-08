import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uninote/models/note.dart';
import 'package:uninote/services/note_service.dart';
import 'package:uninote/widgets/loading_indicator.dart';

class NoteDetailScreen extends StatefulWidget {
  final int noteId;
  final bool isEditing;

  const NoteDetailScreen({
    Key? key,
    required this.noteId,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final NoteService _noteService = GetIt.instance<NoteService>();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  Note? _note;
  List<NoteComment> _comments = [];
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  
  bool _isPublic = true;
  bool _isEditMode = false;
  bool _isSubmitting = false;
  bool _isFetchingComments = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.isEditing;
    _fetchNoteDetails();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchNoteDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Not görüntüleme kaydı oluştur
      await _noteService.viewNote(widget.noteId);
      
      // Not detaylarını getir
      final note = await _noteService.getNote(widget.noteId);
      
      if (note != null) {
        setState(() {
          _note = note;
          _titleController.text = note.title;
          _contentController.text = note.content;
          _tagsController.text = note.tags.join(', ');
          _isPublic = note.isPublic;
          _isLoading = false;
        });
        
        // Yorumları getir
        _fetchComments();
      } else {
        // Not bulunamadı
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not bulunamadı')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Not detayları getirme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not detayları getirilirken bir hata oluştu')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isFetchingComments = true;
    });

    try {
      final comments = await _noteService.getComments(widget.noteId);
      setState(() {
        _comments = comments;
        _isFetchingComments = false;
      });
    } catch (e) {
      print('Yorumları getirme hatası: $e');
      setState(() {
        _isFetchingComments = false;
      });
    }
  }

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

        final request = UpdateNoteRequest(
          title: _titleController.text,
          content: _contentController.text,
          tags: tags,
          isPublic: _isPublic,
        );

        final updatedNote = await _noteService.updateNote(widget.noteId, request);

        if (updatedNote != null) {
          setState(() {
            _note = updatedNote;
            _isEditMode = false;
            _isSubmitting = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not başarıyla güncellendi')),
          );
        } else {
          setState(() {
            _isSubmitting = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not güncellenirken bir hata oluştu')),
          );
        }
      } catch (e) {
        print('Not güncelleme hatası: $e');
        setState(() {
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not güncellenirken bir hata oluştu')),
        );
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final request = CreateNoteCommentRequest(
          content: _commentController.text,
        );

        final comment = await _noteService.addComment(widget.noteId, request);

        if (comment != null) {
          _commentController.clear();
          _fetchComments();
        }

        setState(() {
          _isSubmitting = false;
        });
      } catch (e) {
        print('Yorum ekleme hatası: $e');
        setState(() {
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorum eklenirken bir hata oluştu')),
        );
      }
    }
  }

  Future<void> _likeNote() async {
    try {
      final isLiked = await _noteService.likeNote(widget.noteId);
      
      if (isLiked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not beğenildi')),
        );
        _fetchNoteDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not beğenilirken bir hata oluştu')),
        );
      }
    } catch (e) {
      print('Not beğenme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not beğenilirken bir hata oluştu')),
      );
    }
  }

  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notu Sil'),
        content: const Text('Bu notu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final isDeleted = await _noteService.deleteNote(widget.noteId);
        
        if (isDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not başarıyla silindi')),
          );
          Navigator.pop(context, true); // Silindi bilgisiyle dön
        } else {
          setState(() {
            _isSubmitting = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not silinirken bir hata oluştu')),
          );
        }
      } catch (e) {
        print('Not silme hatası: $e');
        setState(() {
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not silinirken bir hata oluştu')),
        );
      }
    }
  }

  Future<void> _shareNote() async {
    try {
      final invite = await _noteService.createInvite(widget.noteId);
      
      if (invite != null) {
        final token = invite['token'] as String;
        final shareUrl = 'https://uninotes.com/notes/invite/$token';
        
        // Paylaşım URL'sini göster
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notu Paylaş'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Bu link ile notunuzu paylaşabilirsiniz:'),
                const SizedBox(height: 10),
                SelectableText(shareUrl),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paylaşım linki oluşturulurken bir hata oluştu')),
        );
      }
    } catch (e) {
      print('Not paylaşım hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paylaşım linki oluşturulurken bir hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Not Detayı'),
        ),
        body: const Center(
          child: LoadingIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Notu Düzenle' : 'Not Detayı'),
        actions: [
          if (!_isEditMode) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditMode = true;
                });
              },
              tooltip: 'Düzenle',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareNote,
              tooltip: 'Paylaş',
            ),
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: _likeNote,
              tooltip: 'Beğen',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNote,
              tooltip: 'Sil',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSubmitting ? null : _saveNote,
              tooltip: 'Kaydet',
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        _titleController.text = _note!.title;
                        _contentController.text = _note!.content;
                        _tagsController.text = _note!.tags.join(', ');
                        _isPublic = _note!.isPublic;
                        _isEditMode = false;
                      });
                    },
              tooltip: 'İptal',
            ),
          ],
        ],
      ),
      body: _isEditMode ? _buildEditForm() : _buildNoteDetail(),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Başlık',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen bir başlık girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'İçerik',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 10,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen içerik girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Etiketler (virgülle ayırın)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Switch(
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
              ),
              const Text('Herkese Açık'),
            ],
          ),
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoteDetail() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                _note!.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      _note!.isPublic ? Icons.public : Icons.lock,
                      size: 16.0,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      _note!.isPublic ? 'Herkese Açık' : 'Özel',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 16.0),
                    Icon(
                      Icons.favorite,
                      size: 16.0,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '${_note!.likeCount ?? 0}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 16.0),
                    Icon(
                      Icons.visibility,
                      size: 16.0,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '${_note!.viewCount ?? 0}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: _note!.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.blue.shade100,
                      ),
                    )
                    .toList(),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(_note!.content),
              ),
              const Divider(),
              const SizedBox(height: 16.0),
              const Text(
                'Yorumlar',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              if (_isFetchingComments)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_comments.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Henüz yorum yapılmamış'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _comments.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    return ListTile(
                      title: Text(
                        comment.fullName ?? comment.username ?? 'Anonim',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment.content),
                          const SizedBox(height: 4.0),
                          if (comment.createdAt != null)
                            Text(
                              comment.createdAt!.toString(), // Burada bir tarih formatlayıcı kullanılabilir
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.grey.shade200,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Yorum yaz...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isSubmitting ? null : _addComment,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
