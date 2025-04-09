import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:uninote/models/invite.dart';
import 'package:uninote/services/invite_service.dart';
import 'package:uninote/widgets/loading_indicator.dart';

/// Davet bağlantılarını yönetmek için ekran
class InviteScreen extends StatefulWidget {
  final int contentId;
  final String contentType; // 'note' veya 'pdf'
  final String contentTitle;

  const InviteScreen({
    Key? key,
    required this.contentId,
    required this.contentType,
    required this.contentTitle,
  }) : super(key: key);

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final _inviteService = GetIt.instance<InviteService>();
  
  bool _isLoading = true;
  List<Invite> _invites = [];
  DateTime? _selectedExpiryDate;
  bool _isCreatingInvite = false;

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  /// Davet bağlantılarını yükler
  Future<void> _loadInvites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.contentType == 'note') {
        _invites = await _inviteService.getNoteInvites(widget.contentId);
      } else {
        _invites = await _inviteService.getPdfInvites(widget.contentId);
      }
    } catch (e) {
      print('Davet bağlantılarını yükleme hatası: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Yeni davet bağlantısı oluşturur
  Future<void> _createInvite() async {
    setState(() {
      _isCreatingInvite = true;
    });

    try {
      // Debug: Seçilen tarihi göster
      if (_selectedExpiryDate != null) {
        print('Seçilen tarih: $_selectedExpiryDate');
        // UTC'ye çevir
        final utcDate = _selectedExpiryDate!.toUtc();
        print('UTC tarih: $utcDate');
        // ISO 8601 formatına çevir
        final isoString = utcDate.toIso8601String();
        print('ISO 8601 string: $isoString');
      } else {
        print('Seçilen tarih: null (varsayılan tarih kullanılacak)');
      }
      
      Invite? invite;
      
      if (widget.contentType == 'note') {
        invite = await _inviteService.createNoteInvite(
          widget.contentId,
          expiresAt: _selectedExpiryDate,
        );
      } else {
        invite = await _inviteService.createPdfInvite(
          widget.contentId,
          expiresAt: _selectedExpiryDate,
        );
      }

      if (invite != null) {
        _loadInvites();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Davet bağlantısı başarıyla oluşturuldu'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Davet bağlantısı oluşturulamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Davet bağlantısı oluşturma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Davet bağlantısı oluşturma hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingInvite = false;
          _selectedExpiryDate = null;
        });
      }
    }
  }

  /// Davet bağlantısını devre dışı bırakır
  Future<void> _deactivateInvite(Invite invite) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Davet Bağlantısını Devre Dışı Bırak'),
        content: const Text(
          'Bu davet bağlantısını devre dışı bırakmak istediğinize emin misiniz? '
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Devre Dışı Bırak'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _inviteService.deactivateInvite(invite.id!);
      
      if (success) {
        _loadInvites();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Davet bağlantısı başarıyla devre dışı bırakıldı'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Davet bağlantısı devre dışı bırakılamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Davet bağlantısı devre dışı bırakma hatası: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Davet bağlantısı devre dışı bırakma hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Davet bağlantısını panoya kopyalar
  Future<void> _copyLinkToClipboard(Invite invite) async {
    final baseUrl = 'https://uninotes.com'; // Uygulamanızın URL'sini buraya ekleyin
    final fullUrl = invite.getFullUrl(baseUrl);
    
    await Clipboard.setData(ClipboardData(text: fullUrl));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Davet bağlantısı panoya kopyalandı'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Tarih seçiciyi gösterir
  Future<void> _selectExpiryDate() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = now.add(const Duration(days: 7)); // Varsayılan: 1 hafta sonra
    final DateTime lastDate = now.add(const Duration(days: 365)); // Maksimum: 1 yıl sonra
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.add(const Duration(days: 1)), // Minimum: yarın
      lastDate: lastDate,
      helpText: 'Davet bağlantısı son kullanma tarihi seçin',
      cancelText: 'İptal',
      confirmText: 'Seç',
    );
    
    if (picked != null) {
      // Saat seçiciyi göster
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        helpText: 'Davet bağlantısı son kullanma saati seçin',
        cancelText: 'İptal',
        confirmText: 'Seç',
      );
      
      if (timePicked != null) {
        // Tarih ve saati birleştir
        final DateTime dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          timePicked.hour,
          timePicked.minute,
        );
        
        setState(() {
          _selectedExpiryDate = dateTime;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final String contentTypeName = widget.contentType == 'note' ? 'Not' : 'PDF';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$contentTypeName Paylaşım Linkleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadInvites,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İçerik başlığı
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ListTile(
                        leading: Icon(
                          widget.contentType == 'note' ? Icons.description : Icons.picture_as_pdf,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          widget.contentTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${widget.contentType == 'note' ? 'Not' : 'PDF'} ID: ${widget.contentId}'),
                      ),
                    ),
                    
                    // Açıklama
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                const Text(
                                  'Paylaşım Bağlantıları Hakkında',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '• Paylaşım bağlantıları, özel içeriğinizi başkalarıyla güvenle paylaşmanızı sağlar.',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '• Bağlantıya sahip olan herkes, içeriğinize erişebilir.',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '• Her bağlantı için son kullanma tarihi belirleyebilirsiniz.',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '• İstediğiniz zaman bağlantıyı devre dışı bırakabilirsiniz.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Yeni bağlantı oluşturma bölümü
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.add_link, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                const Text(
                                  'Yeni Paylaşım Bağlantısı Oluştur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Son kullanma tarihi seçici
                            InkWell(
                              onTap: _selectExpiryDate,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Son Kullanma Tarihi',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _selectedExpiryDate != null
                                      ? DateFormat('dd.MM.yyyy HH:mm').format(_selectedExpiryDate!)
                                      : 'Son kullanma tarihi seçin',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  'Son kullanma tarihi seçmezseniz, bağlantı 7 gün sonra otomatik olarak sona erecektir.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.link),
                                label: Text(_isCreatingInvite ? 'Oluşturuluyor...' : 'Bağlantı Oluştur'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: _isCreatingInvite ? null : _createInvite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Mevcut bağlantılar
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.link, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Mevcut Bağlantılar (${_invites.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    if (_invites.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.link_off,
                                  size: 48,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Henüz hiç paylaşım bağlantısı oluşturmadınız',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Bu içeriği paylaşmak için yukarıdan yeni bir bağlantı oluşturabilirsiniz',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode ? Colors.grey[500] : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(_invites.length, (index) {
                        final invite = _invites[index];
                        final bool isExpired = invite.isExpired;
                        final bool isActive = invite.isActive;
                        final bool isValid = invite.isValid;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          color: !isValid
                              ? isDarkMode ? Colors.grey[800] : Colors.grey[200]
                              : null,
                          child: Column(
                            children: [
                              ListTile(
                                title: Row(
                                  children: [
                                    Text(
                                      'Bağlantı #${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: !isValid
                                            ? isDarkMode ? Colors.grey[400] : Colors.grey[600]
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (!isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Devre Dışı',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red[900],
                                          ),
                                        ),
                                      )
                                    else if (isExpired)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Süresi Dolmuş',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange[900],
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Aktif',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green[900],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.schedule, size: 14),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Oluşturulma: ${DateFormat('dd.MM.yyyy HH:mm').format(invite.createdAt)}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.event_busy, size: 14),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Son kullanma: ${DateFormat('dd.MM.yyyy HH:mm').format(invite.expiresAt)}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.vpn_key, size: 14),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Token: ${invite.token}',
                                            style: const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: isActive
                                    ? IconButton(
                                        icon: const Icon(Icons.copy),
                                        tooltip: 'Bağlantıyı Kopyala',
                                        onPressed: isValid
                                            ? () => _copyLinkToClipboard(invite)
                                            : null,
                                      )
                                    : null,
                              ),
                              if (isActive)
                                ButtonBar(
                                  alignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.share),
                                      label: const Text('Paylaş'),
                                      onPressed: isValid
                                          ? () => _copyLinkToClipboard(invite)
                                          : null,
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.link_off, color: Colors.red),
                                      label: const Text(
                                        'Devre Dışı Bırak',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () => _deactivateInvite(invite),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
      floatingActionButton: !_isLoading && _invites.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _loadInvites,
              icon: const Icon(Icons.refresh),
              label: const Text('Yenile'),
            )
          : null,
    );
  }
}
