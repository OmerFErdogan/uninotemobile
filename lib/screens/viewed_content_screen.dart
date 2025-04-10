import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uninote/models/view.dart' as view_model;
import 'package:uninote/services/view_service.dart';
import 'package:uninote/screens/note_detail_screen.dart';
import 'package:uninote/screens/pdf_viewer_screen.dart';
import 'package:uninote/widgets/loading_indicator.dart';
import 'package:uninote/utils/date_formatter.dart';

/// Kullanıcının görüntülediği içerikleri gösteren ekran
class ViewedContentScreen extends StatefulWidget {
  const ViewedContentScreen({super.key});

  @override
  State<ViewedContentScreen> createState() => _ViewedContentScreenState();
}

class _ViewedContentScreenState extends State<ViewedContentScreen> {
  final _viewService = GetIt.instance<ViewService>();
  
  bool _isLoading = true;
  List<view_model.View> _views = [];
  int _limit = 20;
  int _offset = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadViews();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  /// Kaydırma olayını dinler ve sayfalama yapar
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreViews();
      }
    }
  }

  /// Görüntüleme kayıtlarını yükler
  Future<void> _loadViews() async {
    if (_isLoading == false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final viewsResponse = await _viewService.getUserViews(
        limit: _limit,
        offset: _offset,
      );
      
      if (viewsResponse != null) {
        setState(() {
          _views = viewsResponse.views;
          _isLoading = false;
          _hasMore = viewsResponse.views.length >= _limit;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Görüntüleme kayıtları yüklenemedi';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Bir hata oluştu: ${e.toString()}';
      });
    }
  }

  /// Daha fazla görüntüleme kaydı yükler (sayfalama)
  Future<void> _loadMoreViews() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newOffset = _offset + _limit;
      final viewsResponse = await _viewService.getUserViews(
        limit: _limit,
        offset: newOffset,
      );
      
      if (viewsResponse != null && viewsResponse.views.isNotEmpty) {
        setState(() {
          _views.addAll(viewsResponse.views);
          _offset = newOffset;
          _hasMore = viewsResponse.views.length >= _limit;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daha fazla yüklenirken hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  /// İçeriğe yönlendirir
  void _navigateToContent(view_model.View viewItem) {
    if (viewItem.type == 'note') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteDetailScreen(noteId: viewItem.contentId),
        ),
      );
    } else if (viewItem.type == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(pdfId: viewItem.contentId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görüntülediğim İçerikler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _offset = 0;
                _hasMore = true;
              });
              _loadViews();
            },
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadViews,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : _views.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_off,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Henüz hiçbir içerik görüntülemediniz',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Herkese açık not ve PDF içeriklerini görüntülediğinizde burada listelenecektir.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              setState(() {
                                _offset = 0;
                                _hasMore = true;
                              });
                              await _loadViews();
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(8),
                              itemCount: _views.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _views.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                
                                final viewItem = _views[index];
                                return _buildViewCard(viewItem);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  /// Görüntüleme kartını oluşturur
  Widget _buildViewCard(view_model.View viewItem) {
    final bool isNote = viewItem.type == 'note';
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToContent(viewItem),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isNote
                      ? (isDarkMode ? Colors.blueGrey.shade700 : Colors.blue.shade50)
                      : (isDarkMode ? Colors.red.shade900 : Colors.red.shade50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    isNote ? Icons.note : Icons.picture_as_pdf,
                    color: isNote
                        ? (isDarkMode ? Colors.blue.shade200 : Colors.blue.shade700)
                        : (isDarkMode ? Colors.red.shade300 : Colors.red.shade700),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isNote ? 'Not' : 'PDF',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isNote
                            ? (isDarkMode ? Colors.blue.shade200 : Colors.blue.shade700)
                            : (isDarkMode ? Colors.red.shade300 : Colors.red.shade700),
                      ),
                    ),
                    Text(
                      'İçerik ID: ${viewItem.contentId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Görüntüleme Tarihi: ${DateFormatter.formatDateTime(viewItem.viewedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}