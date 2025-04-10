import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uninote/models/view.dart' as view_model;
import 'package:uninote/services/view_service.dart';
import 'package:uninote/widgets/loading_indicator.dart';
import 'package:uninote/utils/date_formatter.dart';

/// İçerik görüntüleme kayıtlarını gösteren ekran
class ContentViewsScreen extends StatefulWidget {
  final String contentType; // 'note' veya 'pdf'
  final int contentId;
  final String? contentTitle;

  const ContentViewsScreen({
    super.key,
    required this.contentType,
    required this.contentId,
    this.contentTitle,
  });

  @override
  State<ContentViewsScreen> createState() => _ContentViewsScreenState();
}

class _ContentViewsScreenState extends State<ContentViewsScreen> {
  final _viewService = GetIt.instance<ViewService>();
  
  bool _isLoading = true;
  List<view_model.View> _views = [];
  final int _limit = 20;
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
      final viewsResponse = await _viewService.getContentViews(
        widget.contentType,
        widget.contentId,
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
      final viewsResponse = await _viewService.getContentViews(
        widget.contentType,
        widget.contentId,
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final String contentTypeStr = widget.contentType == 'note' ? 'Not' : 'PDF';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.contentTitle ?? contentTypeStr} Görüntülemeleri'),
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
                          Text(
                            'Bu $contentTypeStr henüz görüntülenmemiş',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              '$contentTypeStr herkese açık olduğunda ve başkaları tarafından görüntülendiğinde burada listelenecektir.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Geri Dön'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Özet bilgi kartı
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        size: 32,
                                        color: isDarkMode 
                                            ? Colors.blue.shade300 
                                            : Colors.blue.shade700,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${_views.length}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text('Görüntülenme'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.people,
                                        size: 32,
                                        color: isDarkMode 
                                            ? Colors.green.shade300 
                                            : Colors.green.shade700,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${_countUniqueViewers()}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text('Farklı İzleyici'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 32,
                                        color: isDarkMode 
                                            ? Colors.orange.shade300 
                                            : Colors.orange.shade700,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _getLastViewDate(),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text('Son Görüntülenme'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Liste başlığı
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, 
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.people_alt),
                              const SizedBox(width: 8),
                              Text(
                                'Görüntüleyen Kullanıcılar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Görüntüleme listesi
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
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    
    // Kullanıcı bilgileri olmaması durumu
    final bool hasUserInfo = viewItem.username != null || viewItem.firstName != null;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Kullanıcı avatarı
            CircleAvatar(
              backgroundColor: hasUserInfo 
                  ? (isDarkMode ? Colors.blue.shade800 : Colors.blue.shade100)
                  : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
              radius: 20,
              child: hasUserInfo
                  ? Text(
                      _getInitials(viewItem),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.grey),
            ),
            
            const SizedBox(width: 16),
            
            // Kullanıcı bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kullanıcı adı
                  Text(
                    hasUserInfo
                        ? viewItem.fullName ?? viewItem.username ?? 'Misafir'
                        : 'Misafir',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  
                  // Kullanıcı adı (varsa)
                  if (viewItem.username != null && viewItem.fullName != null)
                    Text(
                      '@${viewItem.username}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    
                  const SizedBox(height: 4),
                  
                  // Görüntüleme zamanı
                  Text(
                    DateFormatter.formatDateTime(viewItem.viewedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Zaman aralığı
            Chip(
              backgroundColor: isDarkMode 
                  ? Colors.blue.shade900
                  : Colors.blue.shade50,
              label: Text(
                DateFormatter.formatTimeAgo(viewItem.viewedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white : Colors.blue.shade800,
                ),
              ),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Kullanıcı adının baş harflerini alır
  String _getInitials(view_model.View viewItem) {
    if (viewItem.firstName != null && viewItem.lastName != null) {
      return '${viewItem.firstName![0]}${viewItem.lastName![0]}';
    } else if (viewItem.firstName != null) {
      return viewItem.firstName![0];
    } else if (viewItem.lastName != null) {
      return viewItem.lastName![0];
    } else if (viewItem.username != null) {
      return viewItem.username![0];
    }
    return '?';
  }
  
  /// Benzersiz izleyici sayısını sayar
  int _countUniqueViewers() {
    final Set<int?> uniqueUserIds = {};
    
    for (final viewItem in _views) {
      if (viewItem.userId != null) {
        uniqueUserIds.add(viewItem.userId);
      }
    }
    
    return uniqueUserIds.length;
  }
  
  /// Son görüntüleme tarihini döndürür
  String _getLastViewDate() {
    if (_views.isEmpty) {
      return '-';
    }
    
    // En son görüntüleme tarihini bul
    DateTime lastViewDate = _views[0].viewedAt;
    for (final viewItem in _views) {
      if (viewItem.viewedAt.isAfter(lastViewDate)) {
        lastViewDate = viewItem.viewedAt;
      }
    }
    
    // Son görüntülemenin bugün olup olmadığını kontrol et
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final viewDate = DateTime(lastViewDate.year, lastViewDate.month, lastViewDate.day);
    
    if (viewDate == today) {
      return 'Bugün';
    } else if (viewDate == today.subtract(const Duration(days: 1))) {
      return 'Dün';
    }
    
    return DateFormatter.formatDayMonth(lastViewDate);
  }
}