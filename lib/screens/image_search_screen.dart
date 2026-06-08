import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'detail_mua_screen.dart';

class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen>
    with SingleTickerProviderStateMixin {
  File?         _selectedImage;
  bool          _isLoading   = false;
  String?       _errorMessage;
  List<dynamic> _results     = [];
  bool          _hasSearched = false;

  final _picker = ImagePicker();

  static const Color maroon   = Color(0xFF4D0012);
  static const Color pinkSoft = Color(0xFFCF4C4C);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [maroon, pinkSoft],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  late AnimationController _scanCtrl;
  late Animation<double> _scanAnim;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _results       = [];
        _hasSearched   = false;
        _errorMessage  = null;
      });
    }
  }

  Future<void> _searchByImage() async {
    if (_selectedImage == null) return;
    setState(() {
      _isLoading    = true;
      _errorMessage = null;
      _results      = [];
    });
    try {
      final result = await ApiService.searchByImage(imageFile: _selectedImage!);
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          _results     = result['data'] as List;
          _hasSearched = true;
        });
      } else {
        setState(() => _errorMessage = 'Analisis gagal. Coba lagi.');
      }
    } catch (_) {
      setState(() => _errorMessage = 'Tidak bisa terhubung ke server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: maroon,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _hasSearched ? _buildResults() : _buildMain(),
          ),
        ],
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cari dengan Foto',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                Text('Temukan gaya makeup yang cocok untukmu',
                    style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [pinkSoft, Color(0xFFE8736B)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('AI',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── MAIN (belum ada foto / sudah pilih foto) ─────────────────
  Widget _buildMain() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),

          // ── Area foto / placeholder ──
          if (_selectedImage == null) _buildPlaceholder(),
          if (_selectedImage != null) _buildImagePreview(),

          const SizedBox(height: 24),

          // ── Tips atau tombol analisis ──
          if (_selectedImage == null) _buildTips(),
          if (_selectedImage != null) _buildAnalyzeSection(),

          const SizedBox(height: 24),

          // ── Tombol bawah ──
          _buildBottomButtons(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      children: [
        // Lingkaran logo animasi
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: pinkSoft.withValues(alpha: 0.4), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: mainGradient,
              ),
              child: const Center(
                child: Icon(Icons.face_retouching_natural,
                    size: 72, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text('Foto Wajahmu',
            style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'AI kami akan menganalisis portofolio MUA\ndan merekomendasikan yang paling cocok untukmu',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Corner brackets
        SizedBox(
          width: 260,
          height: 300,
          child: CustomPaint(painter: _CornerPainter()),
        ),
        // Foto
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            _selectedImage!,
            width: 240,
            height: 280,
            fit: BoxFit.cover,
          ),
        ),
        // Scan line animasi
        if (_isLoading)
          Positioned(
            child: SizedBox(
              width: 240,
              height: 280,
              child: AnimatedBuilder(
                animation: _scanAnim,
                builder: (_, __) => Stack(
                  children: [
                    Positioned(
                      top: 280 * _scanAnim.value,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              pinkSoft.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // X button
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedImage = null;
              _results       = [];
              _hasSearched   = false;
            }),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white38),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTips() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tips Foto Terbaik',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 10),
          _tipRow('💡', 'Gunakan pencahayaan yang terang'),
          const SizedBox(height: 6),
          _tipRow('🎯', 'Pastikan wajah terlihat jelas & penuh'),
          const SizedBox(height: 6),
          _tipRow('📸', 'Hindari foto yang buram atau terlalu gelap'),
        ],
      ),
    );
  }

  Widget _tipRow(String emoji, String text) => Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      );

  Widget _buildAnalyzeSection() {
    return Column(
      children: [
        // Status
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text('Foto siap dianalisis',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 16),

        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
          ),

        const SizedBox(height: 12),

        // Tombol analisis
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: _isLoading
                ? Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [maroon, pinkSoft],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Menganalisis...',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ],
                    ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [maroon, pinkSoft],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x884D0012),
                            blurRadius: 14,
                            offset: Offset(0, 5)),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _searchByImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      icon: const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 18),
                      label: const Text('Analisis Makeup yang Cocok',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => setState(() {
            _selectedImage = null;
            _results       = [];
            _hasSearched   = false;
          }),
          child: const Text('Ganti Foto',
              style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white60)),
        ),
      ],
    );
  }

  // ── Tombol Galeri & Kamera ────────────────────────────────────
  Widget _buildBottomButtons() {
    if (_selectedImage != null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Galeri
          Expanded(
            child: GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Galeri',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Ambil Foto
          Expanded(
            child: GestureDetector(
              onTap: () => _pickImage(ImageSource.camera),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [maroon, pinkSoft],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x884D0012),
                        blurRadius: 12,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Ambil Foto',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HASIL ────────────────────────────────────────────────────
  Widget _buildResults() {
    return Column(
      children: [
        // Sub header hasil
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_results.length} MUA cocok ditemukan',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _hasSearched   = false;
                  _selectedImage = null;
                  _results       = [];
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Cari Lagi',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: _results.length,
            itemBuilder: (_, i) => _buildResultCard(_results[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(dynamic mua) {
    final name      = mua['name'] ?? '';
    final avatar    = mua['avatar'];
    final location  = mua['location'] ?? '';
    final rating    = (mua['rating'] as num?)?.toDouble() ?? 0;
    final reviews   = mua['total_reviews'] ?? 0;
    final verified  = mua['is_verified'] ?? false;
    final services  = mua['services'] as List? ?? [];
    final portfolios = mua['sample_portfolios'] as List? ?? [];
    final id        = mua['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailMuaScreen(muaId: id)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portofolio scroll
            if (portfolios.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  itemCount: portfolios.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        portfolios[i]['image_url'],
                        width: 85,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 85,
                          height: 90,
                          color: Colors.white10,
                          child: const Icon(Icons.image,
                              color: Colors.white38),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [maroon, pinkSoft],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.transparent,
                      backgroundImage:
                          avatar != null ? NetworkImage(avatar) : null,
                      child: avatar == null
                          ? const Icon(Icons.person,
                              color: Colors.white, size: 26)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14)),
                          if (verified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                color: Colors.lightBlueAccent, size: 14),
                          ],
                        ]),
                        Row(children: [
                          const Icon(Icons.location_on_rounded,
                              size: 12, color: pinkSoft),
                          const SizedBox(width: 2),
                          Text(location,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                        ]),
                        Row(children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: Colors.amber),
                          Text(' $rating ($reviews ulasan)',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                        ]),
                        if (services.isNotEmpty)
                          Text(
                            'Mulai Rp ${_formatPrice((services[0]['price'] as num).toDouble())}',
                            style: const TextStyle(
                                color: pinkSoft,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [maroon, pinkSoft],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

// ── Painter corner bracket ────────────────────────────────────────
class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 24.0;
    const r   = 10.0;

    // Top-left
    canvas.drawLine(const Offset(r, 0), const Offset(r + len, 0), paint);
    canvas.drawLine(const Offset(0, r), const Offset(0, r + len), paint);
    canvas.drawArc(const Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14, 1.57, false, paint);

    // Top-right
    canvas.drawLine(Offset(size.width - r - len, 0), Offset(size.width - r, 0), paint);
    canvas.drawLine(Offset(size.width, r), Offset(size.width, r + len), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2), -1.57, 1.57, false, paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height - r - len), Offset(0, size.height - r), paint);
    canvas.drawLine(Offset(r, size.height), Offset(r + len, size.height), paint);
    canvas.drawArc(Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2), 1.57, 1.57, false, paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height - r - len), Offset(size.width, size.height - r), paint);
    canvas.drawLine(Offset(size.width - r - len, size.height), Offset(size.width - r, size.height), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, size.height - r * 2, r * 2, r * 2), 0, 1.57, false, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}