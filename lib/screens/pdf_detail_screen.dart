import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/pdf.dart';
import '../services/pdf_service.dart';
import '../widgets/loading_indicator.dart';
import 'pdf_upload_screen.dart';
import '../screens/invite_screen.dart';

class PDFDetailScreen extends StatefulWidget {
  final int pdfId;
  final String? inviteToken;

  const PDFDetailScreen({
    Key? key,
    required this.pdfId,
    this.inviteToken,
  }) : super(key: key);

  @override
  _PDFDetailScreenState createState() => _PDFDetailScreenState();
}

class _PDFDetailScreenState extends State<PDFDetailScreen> with SingleTickerProviderStateMixin {
  late Future<PDF> _pdfFuture;
  late Future<String?> _pdfContentFuture;
  late TabController _tabController;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  
  bool _isLoading = false;
  PDF? _pdf;
  String? _pdfPath;
  
  // Yorumlar ve işaretlemeler
  List<PDFComment> _comments = [];
  List<PDFAnnotation> _annotations = [];
  bool _isLoadingComments = false;
  bool _isLoadingAnnotations = false;
  
  // Yorum ekleme
  final TextEditingController _commentController = TextEditingController();
  int? _commentPageNumber;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPDF();
    _recordView();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPDF() async {
    final pdfService = Provider.of<PDFService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (widget.inviteToken != null) {
        _pdfFuture = pdfService.getPDFByInvite(widget.inviteToken!);
      } else {
        _pdfFuture = pdfService.getPDF(widget.pdfId);
      }
      
      _pdf = await _pdfFuture;
      _pdfContentFuture = pdfService.getPDFContent(_pdf!.id!);
      _pdfPath = await _pdfContentFuture;
      
      await _loadComments();
      await _loadAnnotations();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('PDF yüklenirken bir hata oluştu');
    }
  }
  
  Future<void> _recordView() async {
    try {
      final pdfService = Provider.of<PDFService>(context, listen: false);
      await pdfService.viewPDF(widget.pdfId);
    } catch (e) {
      // Görüntüleme kaydı oluşturulurken hata olursa sessizce devam et
    }
  }
  
  Future<void> _loadComments() async {
    if (_pdf == null) return;
    
    setState(() {
      _isLoadingComments = true;
    });
    
    try {
      final pdfService = Provider.of<PDFService>(context, listen: false);
      final comments = await pdfService.getPDFComments(_pdf!.id!);
      
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });
      _showErrorSnackBar('Yorumlar yüklenirken bir hata oluştu');
    }
  }
  
  Future<void> _loadAnnotations() async {
    if (_pdf == null) return;
    
    setState(() {
      _isLoadingAnnotations = true;
    });
    
    try {
      final pdfService = Provider.of<PDFService>(context, listen: false);
      final annotations = await pdfService.getPDFAnnotations(_pdf!.id!);
      
      setState(() {
        _annotations = annotations;
        _isLoadingAnnotations = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAnnotations = false;
      });
      // Sessizce devam et, işaretlemeler görüntüleme deneyimini engellemez
    }
  }
  
  Future<void> _toggleLike() async {
    if (_pdf == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final pdfService = Provider.of<PDFService>(context, listen: false);
      
      // PDF beğenildi mi kontrolü basit bir örnek için burada yapılıyor
      // Gerçek uygulamada bu bilgi API'den gelmeli
      final isLiked = (_pdf!.likeCount ?? 0) > 0;
      
      if (isLiked) {
        await pdfService.unlikePDF(_pdf!.id!);
        setState(() {
          _pdf = _pdf!.copyWith(
            likeCount: (_pdf!.likeCount ?? 1) - 1,
          );
        });
      } else {
        await pdfService.likePDF(_pdf!.id!);
        setState(() {
          _pdf = _pdf!.copyWith(
            likeCount: (_pdf!.likeCount ?? 0) + 1,
          );
        });
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Beğeni işlemi sırasında bir hata oluştu');
    }
  }
  
  Future<void> _addComment() async {
    if (_pdf == null || _commentController.text.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final pdfService = Provider.of<PDFService>(context, listen: false);
      final comment = await pdfService.addCommentToPDF(
        _pdf!.id!,
        _commentController.text.trim(),
        pageNumber: _commentPageNumber,
      );
      
      setState(() {
        _comments.add(comment);
        _commentController.clear();
        _commentPageNumber = null;
        _isLoading = false;
        _pdf = _pdf!.copyWith(
          commentCount: (_pdf!.commentCount ?? 0) + 1,
        );
      });
      
      _showSuccessSnackBar('Yorum başarıyla eklendi');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Yorum eklenirken bir hata oluştu');
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
    if (_isLoading && _pdf == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PDF Detayı')),
        body: const Center(child: LoadingIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_pdf?.title ?? 'PDF Detayı'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: (_pdf?.likeCount ?? 0) > 0 ? Colors.red : null,
            ),
            onPressed: _toggleLike,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareDialog,
          ),
          if (_pdf?.userId == 42) // Gerçek uygulamada mevcut kullanıcı ID'si ile kontrol edilmeli
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editPDF,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'PDF'),
            Tab(text: 'Yorumlar'),
            Tab(text: 'Bilgiler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPDFViewer(),
          _buildCommentsTab(),
          _buildInfoTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: _showAddCommentDialog,
              child: const Icon(Icons.add_comment),
            )
          : null,
    );
  }
  
  Widget _buildPDFViewer() {
    if (_pdfPath == null) {
      return const Center(child: LoadingIndicator());
    }
    
    return SfPdfViewer.file(
      File(_pdfPath!),
      key: _pdfViewerKey,
      onPageChanged: (PdfPageChangedDetails details) {
        setState(() {
          _commentPageNumber = details.newPageNumber;
        });
      },
    );
  }
  
  Widget _buildCommentsTab() {
    if (_isLoadingComments) {
      return const Center(child: LoadingIndicator());
    }
    
    if (_comments.isEmpty) {
      return const Center(
        child: Text('Henüz yorum yok'),
      );
    }
    
    return ListView.builder(
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Row(
              children: [
                Text(
                  comment.username ?? 'Anonim',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (comment.pageNumber != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Sayfa ${comment.pageNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(comment.content),
                const SizedBox(height: 4),
                Text(
                  '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year} ${comment.createdAt.hour}:${comment.createdAt.minute}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInfoTab() {
    if (_pdf == null) {
      return const Center(child: LoadingIndicator());
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Başlık',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            _pdf!.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Açıklama',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(_pdf!.description),
          const SizedBox(height: 16),
          Text(
            'Etiketler',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Wrap(
            spacing: 8,
            children: _pdf!.tags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: Theme.of(context).colorScheme.surface,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'İstatistikler',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.remove_red_eye, size: 20),
              const SizedBox(width: 8),
              Text('${_pdf!.viewCount ?? 0} görüntüleme'),
              const SizedBox(width: 16),
              const Icon(Icons.favorite, size: 20),
              const SizedBox(width: 8),
              Text('${_pdf!.likeCount ?? 0} beğeni'),
              const SizedBox(width: 16),
              const Icon(Icons.comment, size: 20),
              const SizedBox(width: 8),
              Text('${_pdf!.commentCount ?? 0} yorum'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Yükleme Bilgileri',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 8),
              Text(
                'Yüklenme: ${_pdf!.createdAt.day}/${_pdf!.createdAt.month}/${_pdf!.createdAt.year}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.update, size: 20),
              const SizedBox(width: 8),
              Text(
                'Güncelleme: ${_pdf!.updatedAt.day}/${_pdf!.updatedAt.month}/${_pdf!.updatedAt.year}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.public, size: 20),
              const SizedBox(width: 8),
              Text(_pdf!.isPublic ? 'Herkese açık' : 'Özel'),
            ],
          ),
        ],
      ),
    );
  }
  
  Future<void> _showAddCommentDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yorum Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_commentPageNumber != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Sayfa $_commentPageNumber için yorum'),
                  ),
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Yorumunuzu yazın...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                _commentController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ekle'),
              onPressed: () {
                Navigator.of(context).pop();
                _addComment();
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _showShareDialog() async {
    if (_pdf == null) return;
    
    // Davet ekranına yönlendir
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InviteScreen(
          contentId: _pdf!.id!,
          contentType: 'pdf',
          contentTitle: _pdf?.title ?? 'PDF',
        ),
      ),
    );
  }
  
  void _editPDF() async {
    if (_pdf == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFUploadScreen(pdf: _pdf),
      ),
    );
    
    if (result == true) {
      _loadPDF();
    }
  }
}