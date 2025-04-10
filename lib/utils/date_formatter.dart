import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Tarih formatlama yardımcı sınıfı
class DateFormatter {
  // Sınıf yüklenir yüklenmez Türkçe yerel verileri initialize et
  static bool _initialized = false;
  
  static void _ensureInitialized() {
    if (!_initialized) {
      initializeDateFormatting('tr_TR', null);
      _initialized = true;
    }
  }
  /// DateTime'ı okunabilir formata dönüştürür (örn: "23 Nisan 2025 14:30")
  static String formatDateTime(DateTime dateTime) {
    _ensureInitialized();
    final formatter = DateFormat('dd MMMM yyyy HH:mm', 'tr_TR');
    return formatter.format(dateTime);
  }
  
  /// DateTime'ı kısa formata dönüştürür (örn: "23.04.2025")
  static String formatShortDate(DateTime dateTime) {
    _ensureInitialized();
    final formatter = DateFormat('dd.MM.yyyy', 'tr_TR');
    return formatter.format(dateTime);
  }
  
  /// DateTime'dan geçen süreyi okunabilir formata dönüştürür (örn: "2 gün önce")
  static String formatTimeAgo(DateTime dateTime) {
    _ensureInitialized();
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} yıl önce';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'az önce';
    }
  }
  
  /// DateTime'ı gün, ay formatına dönüştürür (örn: "23 Nis")
  static String formatDayMonth(DateTime dateTime) {
    _ensureInitialized();
    final formatter = DateFormat('dd MMM', 'tr_TR');
    return formatter.format(dateTime);
  }
}