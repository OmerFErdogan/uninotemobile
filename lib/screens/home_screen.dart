import 'package:flutter/material.dart';
import 'package:uninote/models/user.dart';
import 'package:uninote/models/note.dart';
import 'package:uninote/services/auth_service.dart';
import 'package:uninote/services/note_service.dart';
import 'package:uninote/screens/login_screen.dart';
import 'package:uninote/screens/profile_screen.dart';
import 'package:uninote/screens/note_detail_screen.dart';
import 'package:uninote/screens/create_note_screen.dart';
import 'package:uninote/widgets/loading_indicator.dart';
import 'package:uninote/widgets/note_card.dart';
import 'package:get_it/get_it.dart';

/// Ana ekran
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _authService = GetIt.instance<AuthService>();
  final _noteService = GetIt.instance<NoteService>();
  
  late TabController _tabController;
  
  bool _isLoading = true;
  bool _isLoadingNotes = false;
  User? _user;
  List<Note> _myNotes = [];
  List<Note> _publicNotes = [];
  List<Note> _likedNotes = [];
  
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadUserProfile();
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
      _loadNotes();
    }
  }

  /// Kullanıcı profil bilgilerini yükler
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.getProfile();
      setState(() {
        _user = user;
        _isLoading = false;
      });
      
      // Notları yükle
      _loadNotes();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil bilgileri yüklenemedi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Notları yükler
  Future<void> _loadNotes() async {
    if (_isLoadingNotes) return;
    
    setState(() {
      _isLoadingNotes = true;
    });

    try {
      switch (_selectedTabIndex) {
        case 0: // Notlarım
          final notes = await _noteService.getUserNotes();
          setState(() {
            _myNotes = notes;
            _isLoadingNotes = false;
          });
          break;
        case 1: // Herkese Açık Notlar
          final notes = await _noteService.getPublicNotes();
          setState(() {
            _publicNotes = notes;
            _isLoadingNotes = false;
          });
          break;
        case 2: // Beğendiğim Notlar
          final notes = await _noteService.getLikedNotes();
          setState(() {
            _likedNotes = notes;
            _isLoadingNotes = false;
          });
          break;
      }
    } catch (e) {
      print('Notları yükleme hatası: $e');
      setState(() {
        _isLoadingNotes = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notlar yüklenirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Çıkış işlemini gerçekleştirir
  Future<void> _logout() async {
    // Onay isteği göster
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Çıkış Yap'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    
    if (shouldLogout != true) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış yapılırken hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
            ? TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Not ara...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Row(
                children: [
                  Icon(
                    Icons.note_alt,
                    color: isDarkMode ? Colors.white : Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'UniNote',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_user != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.blueGrey.shade700 : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _user!.username ?? 'Kullanıcı',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
        elevation: 0,
        bottom: _isLoading || _user == null 
            ? null 
            : PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.grey.shade800 
                        : Colors.blue.shade50,
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkMode 
                            ? Colors.grey.shade700 
                            : Colors.blue.shade200,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: isDarkMode 
                        ? Colors.blue 
                        : Colors.blue.shade700,
                    labelColor: isDarkMode 
                        ? Colors.white 
                        : Colors.blue.shade700,
                    unselectedLabelColor: isDarkMode 
                        ? Colors.grey.shade400 
                        : Colors.grey.shade700,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.note),
                        text: 'Notlarım',
                      ),
                      Tab(
                        icon: Icon(Icons.explore),
                        text: 'Keşfet',
                      ),
                      Tab(
                        icon: Icon(Icons.favorite),
                        text: 'Beğendiklerim',
                      ),
                    ],
                  ),
                ),
              ),
        actions: [
          // Arama butonu
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                }
              });
            },
          ),
          // Profil butonu
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Profil ekranına yönlendir
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: _user),
                ),
              ).then((_) => _loadUserProfile());
            },
          ),
          // Çıkış butonu
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: LoadingIndicator(size: 60.0),
            )
          : _user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Kullanıcı bilgileri yüklenemedi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadUserProfile,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : Container(
                  color: isDarkMode ? Colors.black : Colors.grey.shade50,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMyNotesTab(),
                      _buildPublicNotesTab(),
                      _buildLikedNotesTab(),
                    ],
                  ),
                ),
      floatingActionButton: _isLoading || _user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                // Yeni not oluştur
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateNoteScreen(),
                  ),
                ).then((created) {
                  if (created == true) {
                    _loadNotes();
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Yeni Not'),
              elevation: 4,
            ),
    );
  }

  /// Filtrelenmiş notları döndürür
  List<Note> _getFilteredNotes(List<Note> notes) {
    if (_searchQuery.isEmpty) {
      return notes;
    }
    
    final query = _searchQuery.toLowerCase();
    return notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  /// Notlarım tab sayfasını oluşturur
  Widget _buildMyNotesTab() {
    if (_isLoadingNotes) {
      return const Center(child: LoadingIndicator());
    }
    
    final filteredNotes = _getFilteredNotes(_myNotes);
    
    if (filteredNotes.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                '"$_searchQuery" aramasıyla eşleşen not bulunamadı',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _isSearching = false;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Aramayı Temizle'),
              ),
            ],
          ),
        );
      }
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue.shade100,
                child: Icon(
                  Icons.note_alt,
                  size: 60,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hoş geldin, ${_user?.firstName ?? "Kullanıcı"}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Henüz not oluşturmadınız. Yeni bir not oluşturmak için aşağıdaki butonu kullanabilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            // Not oluşturma butonu
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateNoteScreen(),
                  ),
                ).then((created) {
                  if (created == true) {
                    _loadNotes();
                  }
                });
              },
              icon: const Icon(Icons.note_add),
              label: const Text('Yeni Not Oluştur'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: Scrollbar(
        child: ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: filteredNotes.length,
          itemBuilder: (context, index) {
            final note = filteredNotes[index];
            return NoteCard(
              note: note,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailScreen(noteId: note.id!),
                  ),
                ).then((_) => _loadNotes());
              },
            );
          },
        ),
      ),
    );
  }
  
  /// Herkese açık notlar tab sayfasını oluşturur
  Widget _buildPublicNotesTab() {
    if (_isLoadingNotes) {
      return const Center(child: LoadingIndicator());
    }
    
    final filteredNotes = _getFilteredNotes(_publicNotes);
    
    if (filteredNotes.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                '"$_searchQuery" aramasıyla eşleşen not bulunamadı',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _isSearching = false;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Aramayı Temizle'),
              ),
            ],
          ),
        );
      }
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.public, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Herkese açık not bulunamadı',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Diğer kullanıcıların paylaştığı notlar burada görünecek.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadNotes,
              icon: const Icon(Icons.refresh),
              label: const Text('Yenile'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: Scrollbar(
        child: ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: filteredNotes.length,
          itemBuilder: (context, index) {
            final note = filteredNotes[index];
            return NoteCard(
              note: note,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailScreen(noteId: note.id!),
                  ),
                ).then((_) => _loadNotes());
              },
            );
          },
        ),
      ),
    );
  }
  
  /// Beğenilen notlar tab sayfasını oluşturur
  Widget _buildLikedNotesTab() {
    if (_isLoadingNotes) {
      return const Center(child: LoadingIndicator());
    }
    
    final filteredNotes = _getFilteredNotes(_likedNotes);
    
    if (filteredNotes.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                '"$_searchQuery" aramasıyla eşleşen beğenilen not bulunamadı',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _isSearching = false;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Aramayı Temizle'),
              ),
            ],
          ),
        );
      }
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 80, color: Colors.red.shade200),
            const SizedBox(height: 16),
            const Text(
              'Henüz beğendiğiniz not yok',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Beğendiğiniz notlar burada listelenecek. Keşfet bölümünde beğenebileceğiniz notları bulabilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _tabController.animateTo(1); // Keşfet tabına git
              },
              icon: const Icon(Icons.explore),
              label: const Text('Keşfet\'e Git'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: Scrollbar(
        child: ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: filteredNotes.length,
          itemBuilder: (context, index) {
            final note = filteredNotes[index];
            return NoteCard(
              note: note,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailScreen(noteId: note.id!),
                  ),
                ).then((_) => _loadNotes());
              },
            );
          },
        ),
      ),
    );
  }
}
