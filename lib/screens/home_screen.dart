import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'detail_mua_screen.dart';
import 'chatbot_screen.dart';
import 'image_search_screen.dart';
import 'my_bookings_screen.dart';
import 'notification_screen.dart';  // ← ini yang baru

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int           _currentIndex = 0;
  List<dynamic> _muas         = [];
  bool          _isLoading    = true;
  String        _userName     = 'Pengguna';

  static const Color maroon   = Color(0xFF4D0012);
  static const Color pinkSoft = Color(0xFFCF4C4C);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await ApiService.getCachedUser();
      if (user != null) {
        setState(() => _userName = user['name'] ?? 'Pengguna');
      }
      final result = await ApiService.getMuas();
      if (result['success'] == true) {
        setState(() => _muas = result['data'] ?? []);
      }
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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

  Widget _buildHome() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [maroon, pinkSoft],
              begin : Alignment.topLeft,
              end   : Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding   : const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color       : Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName,
                          style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('Selamat datang',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),

                  // ── BELL NOTIFIKASI ──
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationScreen()),
                        ),
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size : 28,
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top  : 6,
                        child: Container(
                          width : 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color : Colors.amber,
                            shape : BoxShape.circle,
                            border: Border.all(color: pinkSoft, width: 1.5),
                          ),
                          child: const Center(
                            child: Text('2',
                              style: TextStyle(
                                color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold,
                              )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                padding   : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color       : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Cari impian make up mu disini..',
                        style: TextStyle(color: Colors.grey)),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 2),
                      child: Container(
                        padding   : const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color       : pinkSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: pinkSoft))
              : _muas.isEmpty
                  ? const Center(child: Text('Belum ada MUA tersedia'))
                  : RefreshIndicator(
                      color    : pinkSoft,
                      onRefresh: _loadData,
                      child    : ListView.builder(
                        padding    : const EdgeInsets.all(16),
                        itemCount  : _muas.length,
                        itemBuilder: (_, i) => _buildMuaCard(_muas[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildMuaCard(dynamic mua) {
    return Container(
      margin    : const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow   : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child  : Row(
              children: [
                CircleAvatar(
                  radius         : 22,
                  backgroundColor: pinkSoft,
                  backgroundImage: mua['avatar'] != null ? NetworkImage(mua['avatar']) : null,
                  child: mua['avatar'] == null ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children          : [
                      Text((mua['name'] ?? '').toString().toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Row(children: [
                        const Icon(Icons.location_on, size: 12, color: pinkSoft),
                        const SizedBox(width: 2),
                        Text(mua['location'] ?? 'Indonesia',
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ]),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => DetailMuaScreen(muaId: mua['id']))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkSoft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  child: const Text('Lihat Profil',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),

          if (mua['sample_portfolios'] != null &&
              (mua['sample_portfolios'] as List).isNotEmpty)
            ClipRRect(
              child: Image.network(
                mua['sample_portfolios'][0]['image_url'],
                height: 220, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderImage(),
              ),
            )
          else
            _placeholderImage(),

          Padding(
            padding: const EdgeInsets.all(12),
            child  : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children          : [
                Row(children: [
                  Text(mua['name'] ?? '',
                    style: const TextStyle(
                      color: pinkSoft, fontWeight: FontWeight.bold, fontSize: 15)),
                  const Spacer(),
                  const Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${mua['total_reviews'] ?? 0}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 12),
                  const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                  const SizedBox(width: 12),
                  const Icon(Icons.share_outlined, size: 18, color: Colors.grey),
                ]),
                const SizedBox(height: 4),
                Text(mua['bio'] ?? 'Makeup Artist profesional',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => DetailMuaScreen(muaId: mua['id']))),
                  child: const Text('Selengkapnya..',
                    style: TextStyle(
                      color: pinkSoft, fontSize: 13, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 220, color: Colors.grey.shade200,
      child : const Center(child: Icon(Icons.face_retouching_natural, size: 60, color: Colors.grey)),
    );
  }

  Widget _buildProfil() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50, backgroundColor: pinkSoft,
              child : Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(_userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await ApiService.logout();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pinkSoft,
                shape  : RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin   : const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      padding  : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color       : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(40),
        boxShadow   : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children         : [
          _navItem('assets/icons/home.png',       'Home',    0),
          _navItem('assets/icons/booking.png',    'Booking', 1),
          _navItemCenter(),
          _navItem('assets/icons/notifikasi.png', 'Chatbot', 3),
          _navItem('assets/icons/profil.png',     'Profil',  4),
        ],
      ),
    );
  }

  Widget _navItem(String iconPath, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children    : [
          Image.asset(iconPath, width: 24, height: 24,
            color: isActive ? pinkSoft : Colors.grey),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(
            fontSize: 10, color: isActive ? pinkSoft : Colors.grey)),
        ],
      ),
    );
  }

  Widget _navItemCenter() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        padding   : const EdgeInsets.all(14),
        decoration: const BoxDecoration(color: pinkSoft, shape: BoxShape.circle),
        child     : const Icon(Icons.search, color: Colors.white, size: 26),
      ),
    );
  }
}