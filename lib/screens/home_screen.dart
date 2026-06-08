import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'detail_mua_screen.dart';
import 'chatbot_screen.dart';
import 'image_search_screen.dart';
import 'my_bookings_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  List<dynamic> _muas = [];
  bool _isLoading = true;
  String _userName = 'Pengguna';
  String? _selectedCategory; // null = Semua

  static const Color maroon    = Color(0xFF4D0012);
  static const Color pinkSoft  = Color(0xFFCF4C4C);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [maroon, pinkSoft],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [maroon, pinkSoft],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Kategori layanan ──────────────────────────────────────────
  static const List<Map<String, String>> _categories = [
    {'label': 'Semua',      'value': '',           'emoji': '🌸'},
    {'label': 'Wedding',    'value': 'Wedding',    'emoji': '💍'},
    {'label': 'Wisuda',     'value': 'Wisuda',     'emoji': '🎓'},
    {'label': 'Party',      'value': 'Party',      'emoji': '🎉'},
    {'label': 'Photoshoot', 'value': 'Photoshoot', 'emoji': '📸'},
    {'label': 'Formal',     'value': 'Formal',     'emoji': '👔'},
    {'label': 'Lainnya',    'value': 'Lainnya',    'emoji': '✨'},
  ];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData({String? category}) async {
    setState(() => _isLoading = true);
    try {
      final user = await ApiService.getCachedUser();
      if (user != null) {
        setState(() => _userName = user['name'] ?? 'Pengguna');
      }
      final result = await ApiService.getMuas(
        style: (category != null && category.isNotEmpty) ? category : null,
      );
      if (result['success'] == true) {
        setState(() => _muas = result['data'] ?? []);
      }
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onCategoryTap(String value) {
    setState(() => _selectedCategory = value.isEmpty ? null : value);
    _loadData(category: value.isEmpty ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F0),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHome(),
          const MyBookingsScreen(),
          const ImageSearchScreen(),
          const ChatbotScreen(),
          _buildProfil(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HOME
  // ─────────────────────────────────────────────────────────────
  Widget _buildHome() {
    return Column(
      children: [
        _buildHeader(),
        _buildCategoryChips(),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(pinkSoft),
                    strokeWidth: 3,
                  ),
                )
              : _muas.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: pinkSoft,
                      onRefresh: () => _loadData(category: _selectedCategory),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: _muas.length,
                        itemBuilder: (_, i) => _buildMuaCard(_muas[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: mainGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x554D0012), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          // ── Row: avatar + nama + notif ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    const Text('Selamat datang ✨',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              // Badge notifikasi animasi
              ScaleTransition(
                scale: _pulseAnim,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const NotificationScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.notifications_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                          shape: BoxShape.circle,
                          border: Border.all(color: maroon, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Color(0x88FFA500), blurRadius: 6)
                          ],
                        ),
                        child: const Center(
                          child: Text('3',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Search bar ──
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Color(0x334D0012), blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (b) => mainGradient.createShader(b),
                    child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Cari impian make up mu disini..',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 2),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: cardGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Color(0x55CF4C4C), blurRadius: 8, offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── KATEGORI CHIPS ────────────────────────────────────────────
  Widget _buildCategoryChips() {
    return Container(
      height: 54,
      margin: const EdgeInsets.only(top: 14),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isActive = (_selectedCategory == null && cat['value']!.isEmpty) ||
              (_selectedCategory == cat['value']);
          return GestureDetector(
            onTap: () => _onCategoryTap(cat['value']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isActive ? mainGradient : null,
                color: isActive ? null : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? maroon.withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: isActive ? 10 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: isActive
                    ? null
                    : Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat['emoji']!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    cat['label']!,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black54,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (b) => mainGradient.createShader(b),
            blendMode: BlendMode.srcIn,
            child: const Icon(Icons.search_off_rounded, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedCategory != null
                ? 'Belum ada MUA untuk kategori\n"$_selectedCategory"'
                : 'Belum ada MUA tersedia',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black45, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MUA CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildMuaCard(dynamic mua) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: pinkSoft.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: cardGradient,
                    boxShadow: [
                      BoxShadow(
                          color: pinkSoft.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 23,
                    backgroundColor: Colors.transparent,
                    backgroundImage:
                        mua['avatar'] != null ? NetworkImage(mua['avatar']) : null,
                    child: mua['avatar'] == null
                        ? const Icon(Icons.person, color: Colors.white, size: 24)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((mua['name'] ?? '').toString().toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.4)),
                      const SizedBox(height: 3),
                      Row(children: [
                        ShaderMask(
                          shaderCallback: (b) => cardGradient.createShader(b),
                          child: const Icon(Icons.location_on_rounded,
                              size: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 2),
                        Text(mua['location'] ?? 'Indonesia',
                            style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ]),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => DetailMuaScreen(muaId: mua['id']))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: cardGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: pinkSoft.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: const Text('Lihat Profil',
                        style: TextStyle(
                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          // ── Foto portofolio ──
          (mua['sample_portfolios'] != null &&
                  (mua['sample_portfolios'] as List).isNotEmpty)
              ? Image.network(
                  mua['sample_portfolios'][0]['image_url'],
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                )
              : _placeholderImage(),
          // ── Footer ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  ShaderMask(
                    shaderCallback: (b) => mainGradient.createShader(b),
                    blendMode: BlendMode.srcIn,
                    child: Text(mua['name'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                  ),
                  const Spacer(),
                  _actionIcon(Icons.favorite_border_rounded),
                  const SizedBox(width: 4),
                  Text('${mua['total_reviews'] ?? 0}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(width: 12),
                  _actionIcon(Icons.chat_bubble_outline_rounded),
                  const SizedBox(width: 12),
                  _actionIcon(Icons.share_outlined),
                ]),
                const SizedBox(height: 6),
                Text(mua['bio'] ?? 'Makeup Artist profesional',
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => DetailMuaScreen(muaId: mua['id']))),
                  child: ShaderMask(
                    shaderCallback: (b) => cardGradient.createShader(b),
                    blendMode: BlendMode.srcIn,
                    child: const Text('Selengkapnya..',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: pinkSoft)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon) => ShaderMask(
        shaderCallback: (b) => cardGradient.createShader(b),
        blendMode: BlendMode.srcIn,
        child: Icon(icon, size: 19, color: Colors.white),
      );

  Widget _placeholderImage() => Container(
        height: 230,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [pinkSoft.withValues(alpha: 0.08), maroon.withValues(alpha: 0.06)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ShaderMask(
            shaderCallback: (b) => mainGradient.createShader(b),
            blendMode: BlendMode.srcIn,
            child: const Icon(Icons.face_retouching_natural, size: 60, color: Colors.white),
          ),
        ),
      );

  // ─────────────────────────────────────────────────────────────
  // PROFIL
  // ─────────────────────────────────────────────────────────────
  Widget _buildProfil() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 60, left: 20, right: 20, bottom: 32),
              decoration: const BoxDecoration(
                gradient: mainGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x554D0012), blurRadius: 20, offset: Offset(0, 8))
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 3),
                        ),
                        child: const CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person_rounded,
                              size: 62, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                            shape: BoxShape.circle,
                            border: Border.all(color: maroon, width: 2),
                            boxShadow: const [
                              BoxShadow(color: Color(0x66FFA500), blurRadius: 8)
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 15, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(_userName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text('✨ Pengguna BeautyHub',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem('Booking', '3'),
                      _statDivider(),
                      _statItem('Favorit', '5'),
                      _statDivider(),
                      _statItem('Ulasan', '2'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _sectionCard([
              _infoItem(Icons.person_outline_rounded, 'Nama', _userName),
              _divider(),
              _infoItem(Icons.email_outlined, 'Email', '-'),
              _divider(),
              _infoItem(Icons.phone_outlined, 'No. Telepon', '-'),
            ], 'Informasi Akun'),
            const SizedBox(height: 16),
            _sectionCard([
              _menuItem(Icons.person_outline_rounded, 'Edit Profil',
                  'Ubah nama, foto, dan info pribadi', () {}),
              _divider(),
              _menuItem(Icons.bookmark_outline_rounded, 'MUA Favorit',
                  'MUA yang kamu simpan', () {}),
              _divider(),
              _menuItem(Icons.history_rounded, 'Riwayat Booking',
                  'Lihat semua riwayat pemesanan',
                  () => setState(() => _currentIndex = 1)),
              _divider(),
              _menuItem(Icons.star_outline_rounded, 'Ulasan Saya',
                  'Ulasan yang pernah kamu tulis', () {}),
            ], 'Akun'),
            const SizedBox(height: 16),
            _sectionCard([
              _menuItem(Icons.logout_rounded, 'Keluar',
                  'Keluar dari akun Beauty Hub', () async {
                await ApiService.logout();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/');
              }, isRed: true),
            ], ''),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 34, color: Colors.white.withValues(alpha: 0.3));

  Widget _statItem(String label, String value) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      );

  Widget _divider() =>
      const Divider(height: 1, indent: 58, color: Color(0xFFEEE0E0));

  Widget _sectionCard(List<Widget> children, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: pinkSoft.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: ShaderMask(
                shaderCallback: (b) => mainGradient.createShader(b),
                blendMode: BlendMode.srcIn,
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
            ),
          ...children,
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: cardGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: pinkSoft.withValues(alpha: 0.3), blurRadius: 6)
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
      IconData icon, String label, String subtitle, VoidCallback onTap,
      {bool isRed = false}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          gradient: isRed
              ? const LinearGradient(
                  colors: [Color(0xFFFF5252), Color(0xFFFF1744)])
              : cardGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: (isRed ? Colors.red : pinkSoft).withValues(alpha: 0.3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 17),
      ),
      title: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isRed ? Colors.red : Colors.black87)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BOTTOM NAV
  // ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [maroon, pinkSoft],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: Color(0x884D0012), blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem('assets/icons/home.png', 'Home', 0),
          _navItem('assets/icons/booking.png', 'Booking', 1),
          _navItemCenter(),
          _navItem('assets/icons/notifikasi.png', 'Chatbot', 3),
          _navItem('assets/icons/profil.png', 'Profil', 4),
        ],
      ),
    );
  }

  Widget _navItem(String iconPath, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconPath,
                width: 22,
                height: 22,
                color: isActive ? Colors.white : Colors.white38),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                    color: isActive ? Colors.white : Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _navItemCenter() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Color(0x88FFA500), blurRadius: 14, offset: Offset(0, 4)),
          ],
        ),
        child: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}