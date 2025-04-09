import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pdf.dart';
import '../services/pdf_service.dart';
import '../widgets/loading_indicator.dart';
import 'pdf_detail_screen.dart';
import 'pdf_upload_screen.dart';

class PDFListScreen extends StatefulWidget {
  final bool myPDFs; // true: Kullanıcının kendi PDF'leri, false: Herkese açık PDF'ler

  const PDFListScreen({Key? key, this.myPDFs = false}) : super(key: key);

  @override
  _PDFListScreenState createState() => _PDFListScreenState();
}

class _PDFListScreenState extends State<PDFListScreen> {
  late Future<List<PDF>> _pdfsFuture;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 10;
  List<PDF> _pdfs = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPDFs();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _loadMorePDFs();
      }
    }
  }

  Future<void> _loadPDFs() async {
    setState(() {
      _isLoading = true;
      _offset = 0;
      _pdfs = [];
      _hasMore = true;
    });

    try {
      final pdfService = Provider.of<PDFService>(context, listen: false);
      List<PDF> pdfs;

      if (_searchQuery.isNotEmpty) {
        pdfs = await pdfService.searchPDFs(_searchQuery, limit: _limit, offset: _offset);
      } else if (widget.myPDFs) {
        pdfs = await pdfService.getMyPDFs(limit: _limit, offset: _offset);
      } else {
        pdfs = await pdfService.getPublicPDFs(limit: _limit, offset: _offset);
      }

      setState(() {
        _pdfs = pdfs;
        _offset += pdfs.length;
        _hasMore = pdfs.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('PDF\'ler yüklenirken bir hata oluştu');
    }
  }

  Future<void> _loadMorePDFs() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final pdfService = Provider.of<PDFService>(context, listen: false);
      List<PDF> morePDFs;

      if (_searchQuery.isNotEmpty) {
        morePDFs = await pdfService.searchPDFs(_searchQuery, limit: _limit, offset: _offset);
      } else if (widget.myPDFs) {
        morePDFs = await pdfService.getMyPDFs(limit: _limit, offset: _offset);
      } else {
        morePDFs = await pdfService.getPublicPDFs(limit: _limit, offset: _offset);
      }

      setState(() {
        _pdfs.addAll(morePDFs);
        _offset += morePDFs.length;
        _hasMore = morePDFs.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Daha fazla PDF yüklenirken bir hata oluştu');
    }
  }

  void _searchPDFs(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadPDFs();
  }

  void _refreshPDFs() {
    _loadPDFs();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.myPDFs ? 'Benim PDF\'lerim' : 'PDF\'ler'),
        actions: [
          if (widget.myPDFs)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PDFUploadScreen()),
                );
                if (result == true) {
                  _refreshPDFs();
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'PDF Ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchPDFs('');
                        },
                      )
                    : null,
              ),
              onSubmitted: _searchPDFs,
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _refreshPDFs();
              },
              child: _pdfs.isEmpty && !_isLoading
                  ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'Arama sonucu bulunamadı'
                            : widget.myPDFs
                                ? 'Henüz PDF yüklemediniz'
                                : 'Henüz PDF bulunmuyor',
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _pdfs.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _pdfs.length) {
                          return _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(child: LoadingIndicator()),
                                )
                              : const SizedBox.shrink();
                        }
                        final pdf = _pdfs[index];
                        return _buildPDFCard(pdf);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPDFCard(PDF pdf) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        title: Text(
          pdf.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pdf.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.remove_red_eye, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${pdf.viewCount ?? 0}'),
                const SizedBox(width: 8),
                Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${pdf.likeCount ?? 0}'),
                const SizedBox(width: 8),
                Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${pdf.commentCount ?? 0}'),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: pdf.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  padding: const EdgeInsets.all(0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  labelStyle: const TextStyle(fontSize: 10),
                );
              }).toList(),
            ),
          ],
        ),
        trailing: widget.myPDFs
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    // PDF düzenleme ekranına yönlendir
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(pdf);
                  } else if (value == 'share') {
                    _showShareDialog(pdf);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('Sil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Paylaş'),
                      ],
                    ),
                  ),
                ],
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFDetailScreen(pdfId: pdf.id!),
            ),
          ).then((_) => _refreshPDFs());
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(PDF pdf) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('PDF\'i Sil'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bu PDF\'i silmek istediğinizden emin misiniz?'),
                Text('Bu işlem geri alınamaz.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sil'),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePDF(pdf);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePDF(PDF pdf) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final pdfService = Provider.of<PDFService>(context, listen: false);
      await pdfService.deletePDF(pdf.id!);

      setState(() {
        _pdfs.removeWhere((item) => item.id == pdf.id);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF başarıyla silindi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('PDF silinirken bir hata oluştu');
    }
  }

  Future<void> _showShareDialog(PDF pdf) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final pdfService = Provider.of<PDFService>(context, listen: false);
      final invite = await pdfService.createPDFInvite(pdf.id!);
      final inviteToken = invite['token'] as String;
      final inviteUrl = '${Uri.base.origin}/pdf/invite/$inviteToken';

      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PDF Paylaş'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Aşağıdaki bağlantıyı paylaşarak PDF\'i başkalarıyla paylaşabilirsiniz:'),
              const SizedBox(height: 16),
              SelectableText(inviteUrl),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Davet bağlantısı oluşturulurken bir hata oluştu');
    }
  }
}