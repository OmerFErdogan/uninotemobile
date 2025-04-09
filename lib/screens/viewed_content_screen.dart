import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uninote/models/view.dart';
import 'package:uninote/services/view_service.dart';
import 'package:uninote/widgets/loading_indicator.dart';
import 'package:uninote/screens/note_detail_screen.dart';
import 'package:uninote/screens/pdf_detail_screen.dart';

/// Kullanıcının görüntülediği içerikleri listeleyen ekran
class ViewedContentScreen extends StatefulWidget {
  const ViewedContentScreen({Key? key}) : super(key: key);

  @override
  _ViewedContentScreenState createState() => _ViewedContentScreenState();
}

class _ViewedContentScreenState extends State<ViewedContentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = true;
  ViewListResponse? _viewListResponse;
  
  // Sayfalama için
  int _limit = 10;
  int _offset = 0;
  bool _hasMoreItems = true;
  bool _isLoadingMore = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadViewHistory();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadViewHistory({bool reset = true}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _offset = 0;
        _hasMoreItems = true;
      });
    } else {
      if (!_hasMoreItems || _isLoadingMore) return;
      
      setState(() {
        _isLoadingMore = true;
      });
    }
    
    try {
      final viewService = Provider.of<ViewService>(context, listen: false);
      final response = await viewService.getUserViews(
        limit: _limit,
        offset: _offset,
      );
      
      setState(() {
        if (reset) {
          _viewListResponse = response;
        } else if (_viewListResponse != null && response != null) {
          _viewListResponse!.views.addAll(response.views);
        } else {
          _viewListResponse = response;
        }
        
        _isLoading = false;
        _isLoadingMore = false;
        _offset += _limit;
        _hasMoreItems = response != null && response.views.length == _limit;
      });
    } catch (e) {
      print('Görüntüleme geçmişi yükleme hatası: $e');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      
      _showErrorSnackBar('Görüntüleme geçmişi yüklenirken bir hata oluştu');
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
  
  void _navigateToContent(ContentView view) {
    if (view.type == 'note') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteDetailScreen(noteId: view.contentId),
        ),
      );
    } else if (view.type == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFDetailScreen(pdfId: view.contentId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görüntülenen İçerikler'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Notlar'),
            Tab(text: 'PDF\'ler'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _viewListResponse == null || _viewListResponse!.views.isEmpty
              ? _buildEmptyState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildContentList('note'),
                    _buildContentList('pdf'),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _loadViewHistory(),
        tooltip: 'Yenile',
        child: const Icon(Icons.refresh),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.visibility_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz hiç içerik görüntülemediniz',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Görüntülediğiniz notlar ve PDF\'ler burada listelenecek',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Ana Sayfaya Dön'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContentList(String type) {
    final filteredViews = _viewListResponse!.views
        .where((view) => view.type == type)
        .toList();
    
    if (filteredViews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'note' ? Icons.notes_rounded : Icons.picture_as_pdf,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              type == 'note'
                  ? 'Henüz hiç not görüntülemediniz'
                  : 'Henüz hiç PDF görüntülemediniz',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            _hasMoreItems && !_isLoadingMore) {
          _loadViewHistory(reset: false);
        }
        return true;
      },
      child: ListView.builder(
        itemCount: filteredViews.length + (_hasMoreItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filteredViews.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          final view = filteredViews[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              leading: Icon(
                view.type == 'note' ? Icons.description : Icons.picture_as_pdf,
                color: Theme.of(context).primaryColor,
              ),
              title: Text('İçerik ID: ${view.contentId}'),
              subtitle: Text(
                'Görüntülenme: ${view.viewedAt.day}/${view.viewedAt.month}/${view.viewedAt.year} ${view.viewedAt.hour}:${view.viewedAt.minute}',
              ),
              trailing: const Icon(Icons.navigate_next),
              onTap: () => _navigateToContent(view),
            ),
          );
        },
      ),
    );
  }
}
