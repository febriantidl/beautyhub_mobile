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
  MuaModel?      _mua;
  bool           _isLoading = true;
  String?        _error;
  late TabController _tabController;

  // Reviews
  List<ReviewModel> _reviews = [];
  bool   _loadingReviews = false;
  double _avgRating = 0;

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

  // ─── GET /api/muas/{id} ──────────────────────────────────────────
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
    } catch (e) {
      setState(() => _error = 'Tidak bisa terhubung ke server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── GET /api/muas/{id}/reviews ──────────────────────────────────
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE91E8C))),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail MUA')),
        body  : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadDetail, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    final mua = _mua!;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight : 200,
            pinned         : true,
            backgroundColor: const Color(0xFFE91E8C),
            foregroundColor: Colors.white,
            flexibleSpace  : FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
                        begin : Alignment.topLeft,
                        end   : Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Avatar besar
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children         : [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius         : 50,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: mua.avatar != null
                              ? NetworkImage(mua.avatar!)
                              : null,
                          child          : mua.avatar == null
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children         : [
                            Text(
                              mua.name,
                              style: const TextStyle(
                                color     : Colors.white,
                                fontSize  : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (mua.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Colors.white, size: 18),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller       : _tabController,
              indicatorColor   : Colors.white,
              labelColor       : Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs             : const [
                Tab(text: 'Profil'),
                Tab(text: 'Portofolio'),
                Tab(text: 'Ulasan'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children  : [
            _ProfileTab(mua: mua),
            _PortfolioTab(muaId: mua.id, portfolios: mua.portfolios),
            _ReviewsTab(reviews: _reviews, avgRating: _avgRating, loading: _loadingReviews),
          ],
        ),
      ),

      // ── Tombol Booking ────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child  : ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingScreen(mua: mua),
              ),
            ),
            style  : ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E8C),
              foregroundColor: Colors.white,
              padding        : const EdgeInsets.symmetric(vertical: 16),
              shape          : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Buat Booking Sekarang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tab Profil ────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final MuaModel mua;
  const _ProfileTab({required this.mua});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child  : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children          : [
          // Info cepat
          Row(
            children: [
              _InfoChip(icon: Icons.star, label: mua.rating.toStringAsFixed(1)),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.reviews, label: '${mua.totalReviews} ulasan'),
              const SizedBox(width: 8),
              if (mua.experienceYears != null)
                _InfoChip(icon: Icons.work, label: '${mua.experienceYears} thn'),
            ],
          ),
          if (mua.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(mua.location!, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],

          if (mua.bio != null && mua.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Tentang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(mua.bio!, style: const TextStyle(color: Colors.black87, height: 1.5)),
          ],

          // Style tags
          if (mua.styleTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Keahlian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: mua.styleTags
                  .map((tag) => Chip(
                        label          : Text(tag),
                        backgroundColor: const Color(0xFFE91E8C).withOpacity(0.1),
                        labelStyle     : const TextStyle(color: Color(0xFFE91E8C)),
                      ))
                  .toList(),
            ),
          ],

          // Layanan
          if (mua.services.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Layanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...mua.services.map((s) => Card(
              margin : const EdgeInsets.only(bottom: 8),
              shape  : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child  : ListTile(
                title   : Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: s.description != null ? Text(s.description!) : null,
                trailing: Text(
                  'Rp ${_formatPrice(s.price)}',
                  style: const TextStyle(
                    color: Color(0xFFE91E8C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )),
          ],
        ],
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

// ─── Tab Portofolio ────────────────────────────────────────────────
class _PortfolioTab extends StatelessWidget {
  final int muaId;
  final List<PortfolioModel> portfolios;
  const _PortfolioTab({required this.muaId, required this.portfolios});

  @override
  Widget build(BuildContext context) {
    if (portfolios.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children         : [
            Icon(Icons.photo_library_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 8),
            Text('Belum ada portofolio', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding        : const EdgeInsets.all(16),
      gridDelegate   : const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount : 2,
        crossAxisSpacing: 8,
        mainAxisSpacing : 8,
      ),
      itemCount      : portfolios.length,
      itemBuilder    : (_, i) {
        final p = portfolios[i];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child       : Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                p.imageUrl,
                fit        : BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
              if (p.styleCategory != null)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding   : const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        begin : Alignment.topCenter,
                        end   : Alignment.bottomCenter,
                      ),
                    ),
                    child: Text(
                      p.styleCategory!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Tab Ulasan ────────────────────────────────────────────────────
class _ReviewsTab extends StatelessWidget {
  final List<ReviewModel> reviews;
  final double avgRating;
  final bool   loading;

  const _ReviewsTab({
    required this.reviews,
    required this.avgRating,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFE91E8C)));
    }

    return ListView(
      padding : const EdgeInsets.all(16),
      children: [
        // Rata-rata rating
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child  : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children         : [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children          : [
                    Row(children: List.generate(5, (i) => Icon(
                      i < avgRating.round() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size : 20,
                    ))),
                    Text(
                      '${reviews.length} ulasan',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (reviews.isEmpty)
          const Center(child: Text('Belum ada ulasan', style: TextStyle(color: Colors.grey)))
        else
          ...reviews.map((r) => Card(
            margin : const EdgeInsets.only(bottom: 8),
            shape  : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child  : Padding(
              padding: const EdgeInsets.all(12),
              child  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children          : [
                  Row(
                    children: [
                      CircleAvatar(
                        radius         : 18,
                        backgroundImage: r.reviewerAvatar != null
                            ? NetworkImage(r.reviewerAvatar!)
                            : null,
                        child          : r.reviewerAvatar == null
                            ? Text(r.reviewerName[0].toUpperCase())
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children          : [
                            Text(r.reviewerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: List.generate(5, (i) => Icon(
                                i < r.rating.round() ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size : 14,
                              )),
                            ),
                          ],
                        ),
                      ),
                      if (r.createdAt != null)
                        Text(r.createdAt!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  if (r.comment != null && r.comment!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(r.comment!),
                  ],
                ],
              ),
            ),
          )),
      ],
    );
  }
}

// ─── Widget helper ─────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding   : const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color       : const Color(0xFFE91E8C).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children    : [
          Icon(icon, size: 14, color: const Color(0xFFE91E8C)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Color(0xFFE91E8C), fontSize: 12)),
        ],
      ),
    );
  }
}