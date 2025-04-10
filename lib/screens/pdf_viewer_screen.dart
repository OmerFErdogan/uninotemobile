import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get_it/get_it.dart';
import 'package:uninote/models/pdf.dart';
import 'package:uninote/services/pdf_service.dart';
import 'package:uninote/widgets/loading_indicator.dart';
import 'package:uninote/screens/content_views_screen.dart';

/// PDF görüntüleyici ekran
class PDFViewerScreen extends StatefulWidget {
  final int pdfId;

  const PDFViewerScreen({
    super.key,
    required this.pdfId,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  final _pdfService = GetIt.instance<PDFService>();
  
  bool _isLoading = true;
  PDF? _pdf;
  String? _pdfFilePath;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isLoadingPdf = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdfDetails();
  }

  Future<void> _loadPdfDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // PDF görüntüleme kaydı oluştur
      await _pdfService.viewPDF(widget.pdfId);
      
      // PDF bilgilerini getir
      final pdf = await _pdfService.getPDF(widget.pdfId);
      setState(() {
        _pdf = pdf;
        _isLoading = false;
      });
      
      // PDF içeriğini yükle
      _loadPdfContent();
    } catch (e) {
      print('PDF detayları getirme hatası: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'PDF detayları yüklenirken bir hata oluştu: ${e.toString()}';
      });
    }
  }

  Future<void> _loadPdfContent() async {
    setState(() {
      _isLoadingPdf = true;
      _errorMessage = null;
    });

    try {
      final filePath = await _pdfService.getPDFContent(widget.pdfId);
      
      if (filePath != null) {
        setState(() {
          _pdfFilePath = filePath;
          _isLoadingPdf = false;
        });
      } else {
        setState(() {
          _isLoadingPdf = false;
          _errorMessage = 'PDF içeriği alınamadı';
        });
      }
    } catch (e) {
      print('PDF içeriği yükleme hatası: $e');
      setState(() {
        _isLoadingPdf = false;
        _errorMessage = 'PDF içeriği yüklenirken bir hata oluştu: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('PDF Görüntüleyici'),
        ),
        body: const Center(
          child: LoadingIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_pdf?.title ?? 'PDF Görüntüleyici'),
        actions: [
          if (_pdf != null && _pdf!.userId == _pdf!.userId) // Kullanıcı PDF'in sahibi ise
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContentViewsScreen(
                      contentType: 'pdf',
                      contentId: widget.pdfId,
                      contentTitle: _pdf?.title,
                    ),
                  ),
                );
              },
              tooltip: 'Görüntülenme Kayıtları',
            ),
            
          // Paylaşım, beğenme, yorum gibi diğer eylemler burada eklenebilir
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () async {
              try {
                await _pdfService.likePDF(widget.pdfId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF beğenildi')),
                );
                _loadPdfDetails();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Beğenirken hata: ${e.toString()}')),
                );
              }
            },
            tooltip: 'Beğen',
          ),
        ],
      ),
      body: Column(
        children: [
          // PDF bilgileri
          if (_pdf != null)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve istatistikler
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pdf!.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _pdf!.description ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                size: 16,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.blue.shade300
                                    : Colors.blue.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_pdf!.viewCount ?? 0}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.blue.shade300
                                      : Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 16,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.red.shade300
                                    : Colors.red.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_pdf!.likeCount ?? 0}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.red.shade300
                                      : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Etiketler
                  const SizedBox(height: 8),
                  if (_pdf!.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _pdf!.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.blueGrey.shade700
                              : Colors.blue.shade100,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.blue.shade800,
                          ),
                        );
                      }).toList(),
                    ),
                  
                  // Sayfa bilgisi
                  if (_totalPages > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Sayfa: ${_currentPage + 1}/$_totalPages',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          
          // PDF görüntüleyici veya yükleme/hata durumu
          Expanded(
            child: _isLoadingPdf
                ? const Center(child: LoadingIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
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
                                onPressed: _loadPdfContent,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _pdfFilePath != null
                        ? PDFView(
                            filePath: _pdfFilePath!,
                            enableSwipe: true,
                            swipeHorizontal: true,
                            autoSpacing: true,
                            pageFling: true,
                            pageSnap: true,
                            onRender: (pages) {
                              setState(() {
                                _totalPages = pages!;
                              });
                            },
                            onPageChanged: (page, total) {
                              setState(() {
                                _currentPage = page!;
                              });
                            },
                            onError: (error) {
                              print('PDF görüntüleme hatası: $error');
                              setState(() {
                                _errorMessage = 'PDF görüntülenirken bir hata oluştu';
                              });
                            },
                            onPageError: (page, error) {
                              print('PDF sayfa hatası - Sayfa $page: $error');
                            },
                          )
                        : const Center(
                            child: Text('PDF dosyası bulunamadı'),
                          ),
          ),
        ],
      ),
    );
  }
}