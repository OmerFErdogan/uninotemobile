import 'package:flutter/material.dart';
import 'package:uninote/models/note.dart';

/// Not kartı widget'ı
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;

  const NoteCard({
    Key? key,
    required this.note,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    
    // Rastgele bir renk seçmek için notun ID'sini kullan
    final List<Color> cardColors = isDarkMode 
      ? [
          Colors.blueGrey.shade800, 
          Colors.grey.shade800,
          Colors.brown.shade800,
          Colors.indigo.shade800,
          Colors.purple.shade900,
        ]
      : [
          Colors.blue.shade50,
          Colors.green.shade50,
          Colors.orange.shade50,
          Colors.purple.shade50,
          Colors.indigo.shade50,
        ];
    
    final int colorIndex = note.id != null ? note.id! % cardColors.length : 0;
    final Color cardColor = cardColors[colorIndex];
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      color: cardColor,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve ikon satırı
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: note.isPublic 
                        ? (isDarkMode ? Colors.green.shade700 : Colors.green.shade100)
                        : (isDarkMode ? Colors.red.shade700 : Colors.red.shade100),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          note.isPublic ? Icons.public : Icons.lock,
                          size: 14.0,
                          color: note.isPublic 
                            ? (isDarkMode ? Colors.green.shade100 : Colors.green.shade800)
                            : (isDarkMode ? Colors.red.shade100 : Colors.red.shade800),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          note.isPublic ? 'Açık' : 'Özel',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: note.isPublic 
                              ? (isDarkMode ? Colors.green.shade100 : Colors.green.shade800)
                              : (isDarkMode ? Colors.red.shade100 : Colors.red.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 16.0),
              
              // İçerik
              Text(
                note.content,
                style: TextStyle(
                  fontSize: 14.0,
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12.0),
              
              // Etiketler
              if (note.tags.isNotEmpty)
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: note.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.blue.shade700 : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade300,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.blue.shade100 : Colors.blue.shade800,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              
              const SizedBox(height: 12.0),
              
              // Alt bilgi çubuğu
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: isDarkMode 
                    ? Colors.black.withOpacity(0.2) 
                    : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    if (note.likeCount != null && note.likeCount! > 0) ...[
                      Icon(Icons.favorite, size: 16.0, color: Colors.red.shade400),
                      const SizedBox(width: 4.0),
                      Text(
                        '${note.likeCount}',
                        style: TextStyle(
                          fontSize: 12.0, 
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                    ],
                    if (note.commentCount != null && note.commentCount! > 0) ...[
                      Icon(Icons.comment, size: 16.0, color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700),
                      const SizedBox(width: 4.0),
                      Text(
                        '${note.commentCount}',
                        style: TextStyle(
                          fontSize: 12.0, 
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                    ],
                    if (note.viewCount != null && note.viewCount! > 0) ...[
                      Icon(Icons.visibility, size: 16.0, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700),
                      const SizedBox(width: 4.0),
                      Text(
                        '${note.viewCount}',
                        style: TextStyle(
                          fontSize: 12.0, 
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (note.updatedAt != null)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time, 
                            size: 14.0, 
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            _formatDate(note.updatedAt!),
                            style: TextStyle(
                              fontSize: 12.0, 
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tarih formatı
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Az önce';
        }
        return '${diff.inMinutes} dk önce';
      }
      return '${diff.inHours} saat önce';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} gün önce';
    } else {
      // Ay isimlerini belirt
      final List<String> months = [
        'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }
}
