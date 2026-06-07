import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/mua_model.dart';
import 'login_screen.dart';
import 'detail_mua_screen.dart';
import 'chatbot_screen.dart';
import 'image_search_screen.dart';
import 'booking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MuaModel> _muas        = [];
  bool           _isLoading   = true;
  String?        _errorMessage;
  int            _currentPage = 1;
  bool           _hasMore     = true;

  // Filter state
  String _sort = 'rating';

  @override
  void initState() {
    super.initState();
    _loadMuas();
  }

  // ─── GET /api/muas ────────────────────────────────────────────────
  Future<void> _loadMuas({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _muas        = [];
        _hasMore     = true;
      });
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getMuas(
        sort   : _sort,
        perPage: 10,
        page   : _currentPage,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'] as List;
        final meta = result['meta'];

        final newMuas = data.map((m) => MuaModel.fromJson(m)).toList();

        setState(() {
          _muas        = [..._muas, ...newMuas];
          _hasMore     = meta['current_page'] < meta['last_page'];
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = 'Gagal memuat data MUA');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Tidak bisa terhubung ke server\n$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title  : const Text('Keluar'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child    : const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.logout();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style    : ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child    : const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title          : const Text(
          'BeautyHub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        actions        : [
          // Tombol Search by Image
          IconButton(
            icon    : const Icon(Icons.image_search),
            tooltip : 'Cari berdasarkan gambar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ImageSearchScreen()),
            ),
          ),
          // Tombol Logout
          IconButton(
            icon    : const Icon(Icons.logout),
            tooltip : 'Keluar',
            onPressed: _logout,
          ),
        ],
      ),

      // ── Floating Button: Chatbot ─────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        onPressed      : () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        ),
        icon : const Icon(Icons.chat_bubble_outline),
        label: const Text('Chatbot'),
      ),

      body: RefreshIndicator(
        onRefresh    : () => _loadMuas(refresh: true),
        color        : const Color(0xFFE91E8C),
        child        : CustomScrollView(
          slivers: [
            // ── Header / Banner ──────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color  : const Color(0xFFE91E8C),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child  : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Temukan MUA Terbaikmu 💄',
                      style: TextStyle(
                        color     : Colors.white,
                        fontSize  : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih dari MUA profesional yang telah terverifikasi',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    // Sort filter chips
                    Row(
                      children: [
                        _SortChip(
                          label    : 'Rating',
                          value    : 'rating',
                          selected : _sort == 'rating',
                          onTap    : () {
                            setState(() => _sort = 'rating');
                            _loadMuas(refresh: true);
                          },
                        ),
                        const SizedBox(width: 8),
                        _SortChip(
                          label    : 'Pengalaman',
                          value    : 'experience',
                          selected : _sort == 'experience',
                          onTap    : () {
                            setState(() => _sort = 'experience');
                            _loadMuas(refresh: true);
                          },
                        ),
                        const SizedBox(width: 8),
                        _SortChip(
                          label    : 'Ulasan',
                          value    : 'reviews',
                          selected : _sort == 'reviews',
                          onTap    : () {
                            setState(() => _sort = 'reviews');
                            _loadMuas(refresh: true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Error ─────────────────────────────────────────────
            if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Container(
                  margin : const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color       : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border      : Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.red, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style    : const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _loadMuas(refresh: true),
                        child    : const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),

            // ── List MUA ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < _muas.length) {
                      return _MuaCard(
                        mua    : _muas[index],
                        onTap  : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailMuaScreen(muaId: _muas[index].id),
                          ),
                        ),
                      );
                    }

                    // Load more button
                    if (_hasMore && !_isLoading) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child  : Center(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _currentPage++);
                              _loadMuas();
                            },
                            child: const Text('Muat Lebih Banyak'),
                          ),
                        ),
                      );
                    }

                    return null;
                  },
                  childCount: _muas.length + (_hasMore ? 1 : 0),
                ),
              ),
            ),

            // ── Loading indicator ─────────────────────────────────
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child  : Center(
                    child: CircularProgressIndicator(color: Color(0xFFE91E8C)),
                  ),
                ),
              ),

            // ── Empty state ───────────────────────────────────────
            if (!_isLoading && _muas.isEmpty && _errorMessage == null)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child  : Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada MUA tersedia',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget: Sort Chip ─────────────────────────────────────────────
class _SortChip extends StatelessWidget {
  final String   label;
  final String   value;
  final bool     selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap  : onTap,
      child  : Container(
        padding   : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color       : selected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color     : selected ? const Color(0xFFE91E8C) : Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize  : 12,
          ),
        ),
      ),
    );
  }
}

// ─── Widget: MUA Card ─────────────────────────────────────────────
class _MuaCard extends StatelessWidget {
  final MuaModel mua;
  final VoidCallback onTap;

  const _MuaCard({required this.mua, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin       : const EdgeInsets.only(bottom: 12),
      shape        : RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation    : 2,
      child        : InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap       : onTap,
        child       : Padding(
          padding: const EdgeInsets.all(16),
          child  : Row(
            children: [
              // ── Avatar ────────────────────────────────────────
              CircleAvatar(
                radius         : 36,
                backgroundColor: const Color(0xFFE91E8C).withOpacity(0.1),
                backgroundImage: mua.avatar != null
                    ? NetworkImage(mua.avatar!)
                    : null,
                child          : mua.avatar == null
                    ? const Icon(Icons.person, size: 36, color: Color(0xFFE91E8C))
                    : null,
              ),
              const SizedBox(width: 12),

              // ── Info ──────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children          : [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mua.name,
                            style: const TextStyle(
                              fontSize  : 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (mua.isVerified)
                          const Icon(Icons.verified, color: Colors.blue, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (mua.location != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            mua.location!,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          mua.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${mua.totalReviews} ulasan)',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Harga mulai dari layanan pertama
                    if (mua.services.isNotEmpty)
                      Text(
                        'Mulai Rp ${_formatPrice(mua.services.first.price)}',
                        style: const TextStyle(
                          color     : Color(0xFFE91E8C),
                          fontWeight: FontWeight.bold,
                          fontSize  : 13,
                        ),
                      ),
                  ],
                ),
              ),

              // ── Arrow ─────────────────────────────────────────
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    // Format angka dengan titik ribuan
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}