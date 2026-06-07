import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/mua_model.dart';
import 'detail_mua_screen.dart';

class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  File?        _selectedImage;
  String?      _selectedCategory; // field: style_category (opsional)
  bool         _isLoading  = false;
  String?      _errorMessage;
  List<dynamic> _results   = [];
  bool         _hasSearched = false;

  final _picker = ImagePicker();

  // Kategori style yang tersedia (sesuai data portfolio di Laravel)
  final List<String> _categories = [
    'wedding',
    'wisuda',
    'natural',
    'glam',
    'party',
    'editorial',
  ];

  // ─── Pilih gambar dari galeri atau kamera ─────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source  : source,
      maxWidth: 1024,   // compress agar < 5MB (limit Laravel)
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

  // ─── POST /api/search/by-image ────────────────────────────────────
  // Field: image (File, wajib), style_category (string, opsional)
  Future<void> _searchByImage() async {
    if (_selectedImage == null) {
      setState(() => _errorMessage = 'Pilih gambar terlebih dahulu');
      return;
    }

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
      _results      = [];
    });

    try {
      final result = await ApiService.searchByImage(
        imageFile    : _selectedImage!,
        styleCategory: _selectedCategory, // bisa null
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _results     = result['data'] as List;
          _hasSearched = true;
        });
      } else {
        setState(() => _errorMessage = 'Pencarian gagal. Coba lagi.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Tidak bisa terhubung ke server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape  : const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children    : [
            const Padding(
              padding: EdgeInsets.all(16),
              child  : Text(
                'Pilih Gambar Referensi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading  : const Icon(Icons.photo_library, color: Color(0xFFE91E8C)),
              title    : const Text('Dari Galeri'),
              onTap    : () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading  : const Icon(Icons.camera_alt, color: Color(0xFFE91E8C)),
              title    : const Text('Ambil Foto'),
              onTap    : () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title          : const Text('Cari MUA by Foto'),
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child  : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children          : [

            // ── Penjelasan ────────────────────────────────────────
            Container(
              padding    : const EdgeInsets.all(12),
              decoration : BoxDecoration(
                color       : const Color(0xFFE91E8C).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border      : Border.all(color: const Color(0xFFE91E8C).withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFE91E8C)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upload foto referensi makeup yang kamu suka, kami akan carikan MUA yang sesuai!',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Upload gambar ─────────────────────────────────────
            GestureDetector(
              onTap : _showImageSourceSheet,
              child : Container(
                height    : 200,
                decoration: BoxDecoration(
                  color       : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border      : Border.all(
                    color    : const Color(0xFFE91E8C).withOpacity(0.3),
                    style    : BorderStyle.solid,
                    width    : 2,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child       : Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children         : [
                          Icon(Icons.add_photo_alternate_outlined, size: 60, color: Color(0xFFE91E8C)),
                          SizedBox(height: 8),
                          Text(
                            'Tap untuk pilih gambar referensi',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Maks. 5MB',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
              ),
            ),

            if (_selectedImage != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _showImageSourceSheet,
                icon     : const Icon(Icons.refresh),
                label    : const Text('Ganti Gambar'),
                style    : TextButton.styleFrom(foregroundColor: const Color(0xFFE91E8C)),
              ),
            ],

            const SizedBox(height: 20),

            // ── Filter kategori (opsional) ─────────────────────────
            // field: style_category
            const Text(
              'Kategori Style (opsional)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing  : 8,
              runSpacing: 4,
              children : [
                ChoiceChip(
                  label    : const Text('Semua'),
                  selected : _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                  selectedColor: const Color(0xFFE91E8C),
                  labelStyle: TextStyle(
                    color: _selectedCategory == null ? Colors.white : Colors.black,
                  ),
                ),
                ..._categories.map((cat) => ChoiceChip(
                  label    : Text(cat[0].toUpperCase() + cat.substring(1)),
                  selected : _selectedCategory == cat,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: const Color(0xFFE91E8C),
                  labelStyle: TextStyle(
                    color: _selectedCategory == cat ? Colors.white : Colors.black,
                  ),
                )),
              ],
            ),

            const SizedBox(height: 20),

            // ── Error message ──────────────────────────────────────
            if (_errorMessage != null) ...[
              Container(
                padding    : const EdgeInsets.all(12),
                decoration : BoxDecoration(
                  color       : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border      : Border.all(color: Colors.red[200]!),
                ),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 12),
            ],

            // ── Tombol Cari ────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _searchByImage,
              icon     : const Icon(Icons.search),
              label    : const Text(
                'Cari MUA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style    : ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C),
                foregroundColor: Colors.white,
                padding        : const EdgeInsets.symmetric(vertical: 14),
                shape          : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Loading ────────────────────────────────────────────
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFFE91E8C)),
                    SizedBox(height: 8),
                    Text('Mencari MUA yang cocok...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),

            // ── Hasil ─────────────────────────────────────────────
            if (_hasSearched && _results.isNotEmpty) ...[
              Text(
                '${_results.length} MUA ditemukan',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ..._results.map((m) => _SearchResultCard(data: m)),
            ],

            if (_hasSearched && _results.isEmpty && !_isLoading)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 60, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Tidak ada MUA yang cocok', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Kartu hasil pencarian ─────────────────────────────────────────
class _SearchResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _SearchResultCard({required this.data});

  @override
  Widget build(BuildContext context) {
    // data mengikuti response JSON Laravel SearchApiController
    final name          = data['name'] ?? '';
    final avatar        = data['avatar'];
    final location      = data['location'] ?? '';
    final rating        = (data['rating'] as num?)?.toDouble() ?? 0;
    final totalReviews  = data['total_reviews'] ?? 0;
    final isVerified    = data['is_verified'] ?? false;
    final services      = data['services'] as List? ?? [];
    final samplePortfolios = data['sample_portfolios'] as List? ?? [];
    final id            = data['id'];

    return Card(
      margin     : const EdgeInsets.only(bottom: 12),
      shape      : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation  : 2,
      child      : InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap       : () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailMuaScreen(muaId: id)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children          : [
            // Sample portfolio images (horizontal scroll)
            if (samplePortfolios.isNotEmpty)
              SizedBox(
                height : 100,
                child  : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding        : const EdgeInsets.all(8),
                  itemCount      : samplePortfolios.length,
                  itemBuilder    : (_, i) {
                    final imgUrl = samplePortfolios[i]['image_url'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child  : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child       : Image.network(
                          imgUrl,
                          width      : 80,
                          height     : 80,
                          fit        : BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80, height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child  : Row(
                children: [
                  CircleAvatar(
                    radius         : 28,
                    backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                    backgroundColor: const Color(0xFFE91E8C).withOpacity(0.1),
                    child          : avatar == null
                        ? const Icon(Icons.person, color: Color(0xFFE91E8C))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children          : [
                        Row(
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Colors.blue, size: 14),
                            ],
                          ],
                        ),
                        Text(location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            Text(
                              ' $rating ($totalReviews ulasan)',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        if (services.isNotEmpty)
                          Text(
                            'Mulai Rp ${_formatPrice((services[0]['price'] as num).toDouble())}',
                            style: const TextStyle(
                              color     : Color(0xFFE91E8C),
                              fontSize  : 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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