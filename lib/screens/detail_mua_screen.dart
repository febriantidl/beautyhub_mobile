import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/mua_model.dart';
import 'booking_screen.dart';

class DetailMuaScreen extends StatefulWidget {
  final int muaId;
  const DetailMuaScreen({super.key, required this.muaId});

  @override
  State<DetailMuaScreen> createState() => _DetailMuaScreenState();
}

class _DetailMuaScreenState extends State<DetailMuaScreen>
    with SingleTickerProviderStateMixin {
  MuaModel? _mua;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;
  List<ReviewModel> _reviews = [];
  bool _loadingReviews = false;
  double _avgRating = 0;

  static const Color maroon   = Color(0xFF4D0012);
  static const Color pinkSoft = Color(0xFFCF4C4C);
  static const LinearGradient mainGradient = LinearGradient(
    colors: [maroon, pinkSoft],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await ApiService.getMuaDetail(widget.muaId);
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() => _mua = MuaModel.fromJson(result['data']));
        _loadReviews();
      } else {
        setState(() => _error = 'Gagal memuat detail MUA');
      }
    } catch (_) {
      setState(() => _error = 'Tidak bisa terhubung ke server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReviews() async {
    setState(() => _loadingReviews = true);
    try {
      final result = await ApiService.getMuaReviews(widget.muaId);
      if (!mounted) return;
      if (result['success'] == true) {
        final data = result['data'] as List;
        final summary = result['summary'];
        setState(() {
          _reviews   = data.map((r) => ReviewModel.fromJson(r)).toList();
          _avgRating = (summary?['average_rating'] as num?)?.toDouble() ?? 0;
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F0F0),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(pinkSoft),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F0F0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: pinkSoft),
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              _gradientButton('Coba Lagi', _loadDetail),
            ],
          ),
        ),
      );
    }

    final mua = _mua!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F0),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: maroon,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildHeader(mua),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: maroon,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Profil'),
                    Tab(text: 'Portofolio'),
                    Tab(text: 'Ulasan'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ProfileTab(mua: mua),
            _PortfolioTab(muaId: mua.id, portfolios: mua.portfolios),
            _ReviewsTab(reviews: _reviews, avgRating: _avgRating, loading: _loadingReviews),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: _gradientButton('Buat Booking Sekarang', () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookingScreen(mua: mua)),
          )),
        ),
      ),
    );
  }

  Widget _buildHeader(MuaModel mua) {
    return Container(
      decoration: const BoxDecoration(gradient: mainGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // ── Avatar ──
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(color: Color(0x554D0012), blurRadius: 16, offset: Offset(0, 6)),
                ],
              ),
              child: CircleAvatar(
                radius: 52,
                backgroundColor: Colors.white24,
                backgroundImage: mua.avatar != null ? NetworkImage(mua.avatar!) : null,
                child: mua.avatar == null
                    ? const Icon(Icons.person_rounded, size: 52, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            // ── Nama + verified ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(mua.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3)),
                if (mua.isVerified) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded, color: Colors.lightBlueAccent, size: 18),
                ],
              ],
            ),
            if (mua.location != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_rounded, size: 13, color: Colors.white70),
                  const SizedBox(width: 2),
                  Text(mua.location!,
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // ── Stats row (ala IG) ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statCol(mua.portfolios.length.toString(), 'Portofolio'),
                _vDivider(),
                _statCol(mua.totalReviews.toString(), 'Ulasan'),
                _vDivider(),
                _statCol(mua.rating.toStringAsFixed(1), 'Rating'),
                _vDivider(),
                _statCol('${mua.experienceYears ?? 0} thn', 'Pengalaman'),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _statCol(String value, String label) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      );

  Widget _vDivider() =>
      Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.25));

  Widget _gradientButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [maroon, pinkSoft],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Color(0x884D0012), blurRadius: 14, offset: Offset(0, 5)),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

// ── TAB PROFIL ────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final MuaModel mua;
  const _ProfileTab({required this.mua});

  static const Color maroon   = Color(0xFF4D0012);
  static const Color pinkSoft = Color(0xFFCF4C4C);
  static const LinearGradient grad = LinearGradient(
    colors: [maroon, pinkSoft],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          if (mua.bio != null && mua.bio!.isNotEmpty) ...[
            _sectionTitle('Tentang'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: pinkSoft.withValues(alpha: 0.08), blurRadius: 10),
                ],
              ),
              child: Text(mua.bio!,
                  style: const TextStyle(color: Colors.black87, height: 1.6, fontSize: 14)),
            ),
            const SizedBox(height: 20),
          ],

          // Keahlian tags
          if (mua.styleTags.isNotEmpty) ...[
            _sectionTitle('Keahlian'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mua.styleTags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [maroon, pinkSoft],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: pinkSoft.withValues(alpha: 0.3), blurRadius: 6),
                  ],
                ),
                child: Text(tag,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              )).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Layanan
          if (mua.services.isNotEmpty) ...[
            _sectionTitle('Layanan'),
            const SizedBox(height: 10),
            ...mua.services.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: pinkSoft.withValues(alpha: 0.08), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: grad,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 14)),
                        if (s.description != null)
                          Text(s.description!,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (b) => grad.createShader(b),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      'Rp ${_fmt(s.price)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => ShaderMask(
        shaderCallback: (b) => grad.createShader(b),
        blendMode: BlendMode.srcIn,
        child: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900)),
      );

  String _fmt(double price) => price.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

// ── TAB PORTOFOLIO (grid ala IG) ─────────────────────────────────
class _PortfolioTab extends StatelessWidget {
  final int muaId;
  final List<PortfolioModel> portfolios;
  const _PortfolioTab({required this.muaId, required this.portfolios});

  static const Color maroon   = Color(0xFF4D0012);
  static const Color pinkSoft = Color(0xFFCF4C4C);

  @override
  Widget build(BuildContext context) {
    if (portfolios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [maroon, pinkSoft],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(b),
              blendMode: BlendMode.srcIn,
              child: const Icon(Icons.photo_library_outlined,
                  size: 64, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text('Belum ada portofolio',
                style: TextStyle(color: Colors.black45)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: portfolios.length,
      itemBuilder: (_, i) {
        final p = portfolios[i];
        return GestureDetector(
          onTap: () => _showFullImage(context, p),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                p.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
              if (p.styleCategory != null)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Text(p.styleCategory!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showFullImage(BuildContext context, PortfolioModel p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.network(p.imageUrl, fit: BoxFit.contain),
              if (p.styleCategory != null)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Text(p.styleCategory!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── TAB ULASAN ───────────────────────────────────────────────────
class _ReviewsTab extends StatelessWidget {
  final List<ReviewModel> reviews;
  final double avgRating;
  final bool loading;
  const _ReviewsTab({required this.reviews, required this.avgRating, required this.loading});

  static const Color maroon   = Color(0xFF4D0012);
  static const Color pinkSoft = Color(0xFFCF4C4C);
  static const LinearGradient grad = LinearGradient(
    colors: [maroon, pinkSoft],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(pinkSoft),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        // Rating summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: grad,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0x554D0012), blurRadius: 14, offset: Offset(0, 5)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(avgRating.toStringAsFixed(1),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w900)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 22,
                    )),
                  ),
                  const SizedBox(height: 4),
                  Text('${reviews.length} ulasan',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (reviews.isEmpty)
          const Center(
            child: Text('Belum ada ulasan',
                style: TextStyle(color: Colors.black45)),
          )
        else
          ...reviews.map((r) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: pinkSoft.withValues(alpha: 0.08), blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: grad),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      backgroundImage: r.reviewerAvatar != null
                          ? NetworkImage(r.reviewerAvatar!)
                          : null,
                      child: r.reviewerAvatar == null
                          ? Text(r.reviewerName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.reviewerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                        Row(
                          children: List.generate(5, (i) => Icon(
                            i < r.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 14,
                          )),
                        ),
                      ],
                    ),
                  ),
                  if (r.createdAt != null)
                    Text(r.createdAt!,
                        style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ]),
                if (r.comment != null && r.comment!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(r.comment!,
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 13, height: 1.5)),
                ],
              ],
            ),
          )),
      ],
    );
  }
}