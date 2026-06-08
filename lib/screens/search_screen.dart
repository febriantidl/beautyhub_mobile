import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'detail_mua_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color maroon   = Color(0xFF4D0012);
  static const Color pinkSoft = Color(0xFFCF4C4C);
  static const LinearGradient mainGradient = LinearGradient(
    colors: [maroon, pinkSoft],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  final TextEditingController _ctrl = TextEditingController();
  List<dynamic> _results   = [];
  bool _isLoading          = false;
  bool _hasSearched        = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _results = []; _hasSearched = false; });
      return;
    }
    setState(() { _isLoading = true; _hasSearched = true; });
    try {
      // pakai endpoint getMuas dengan filter nama/location
      final result = await ApiService.getMuas(location: query.trim());
      if (result['success'] == true) {
        setState(() => _results = result['data'] ?? []);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F0),
      body: Column(
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.only(top: 52, left: 16, right: 16, bottom: 16),
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
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => mainGradient.createShader(b),
                          child: const Icon(Icons.search_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            autofocus: true,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Cari nama MUA atau lokasi...',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: _search,
                            onSubmitted: _search,
                          ),
                        ),
                        if (_ctrl.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _ctrl.clear();
                              setState(() { _results = []; _hasSearched = false; });
                            },
                            child: const Icon(Icons.close, color: Colors.grey, size: 18),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Hasil / placeholder ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(pinkSoft),
                      strokeWidth: 3,
                    ),
                  )
                : !_hasSearched
                    ? _buildHint()
                    : _results.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            itemCount: _results.length,
                            itemBuilder: (_, i) => _buildCard(_results[i]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (b) => mainGradient.createShader(b),
            blendMode: BlendMode.srcIn,
            child: const Icon(Icons.search_rounded, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text('Ketik nama MUA atau kota',
              style: TextStyle(color: Colors.black45, fontSize: 14)),
        ],
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
          Text('Tidak ada MUA untuk\n"${_ctrl.text}"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black45, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCard(dynamic mua) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: pinkSoft.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailMuaScreen(muaId: mua['id'])),
        ),
        leading: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: mainGradient),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.transparent,
            backgroundImage: mua['avatar'] != null ? NetworkImage(mua['avatar']) : null,
            child: mua['avatar'] == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
        ),
        title: Text(mua['name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        subtitle: Row(children: [
          const Icon(Icons.location_on_rounded, size: 12, color: pinkSoft),
          const SizedBox(width: 2),
          Text(mua['location'] ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 8),
          const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
          Text(' ${mua['rating'] ?? 0}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [maroon, pinkSoft],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Lihat',
              style: TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}