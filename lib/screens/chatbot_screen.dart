import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  static const Color maroon = Color(0xFF4D0012);
  static const Color pink = Color(0xFFCF4C4C);

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: 'Halo! Saya BeautyBot 💄 Saya siap membantu kamu seputar MUA, harga makeup, tips kecantikan, cara booking, dan masih banyak lagi. Tanyakan apa saja!',
      isBot: true,
    ));
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getResponse(String message) {
    final msg = message.toLowerCase();

    // ── SALAM ──────────────────────────────────────────────────────
    if (msg.contains('halo') || msg.contains('hai') || msg.contains('hello') ||
        msg.contains('hi') || msg.contains('selamat') || msg.contains('assalamualaikum') ||
        msg.contains('pagi') || msg.contains('siang') || msg.contains('malam') ||
        msg.contains('sore')) {
      return 'Halo! 👋 Selamat datang di BeautyBot!\n\nSaya siap membantu kamu seputar:\n💄 Informasi MUA dan harga\n📅 Cara booking\n✨ Tips makeup\n🏆 Sertifikasi BNSP\n📍 MUA di berbagai kota\n\nAda yang ingin kamu tanyakan?';
    }

    // ── TERIMA KASIH ───────────────────────────────────────────────
    if (msg.contains('terima kasih') || msg.contains('makasih') ||
        msg.contains('thanks') || msg.contains('thank') ||
        msg.contains('thx') || msg.contains('tq')) {
      return 'Sama-sama! 😊 Senang bisa membantu.\n\nJika ada pertanyaan lain seputar MUA atau makeup, jangan ragu untuk bertanya ya! 💄✨';
    }

    // ── HARGA ──────────────────────────────────────────────────────
    if (msg.contains('harga') || msg.contains('biaya') || msg.contains('tarif') ||
        msg.contains('bayar') || msg.contains('berapa') || msg.contains('cost') ||
        msg.contains('budget') || msg.contains('murah') || msg.contains('mahal') ||
        msg.contains('terjangkau') || msg.contains('rate') || msg.contains('fee')) {
      if (msg.contains('wedding') || msg.contains('nikah') || msg.contains('pengantin')) {
        return 'Harga makeup wedding:\n\n💍 Paket Basic: Rp 500.000 - 800.000\n💍 Paket Standard: Rp 800.000 - 1.500.000\n💍 Paket Premium: Rp 1.500.000 - 3.000.000\n\nSudah termasuk:\n✅ Makeup pengantin\n✅ Penataan rambut\n✅ Touch up sepanjang acara\n\nHarga bisa berbeda tergantung MUA dan lokasi!';
      }
      if (msg.contains('wisuda')) {
        return 'Harga makeup wisuda:\n\n🎓 Paket Simple: Rp 150.000 - 250.000\n🎓 Paket Elegant: Rp 250.000 - 400.000\n🎓 Paket Full Glam: Rp 400.000 - 600.000\n\nRekomendasi: Pilih paket elegant untuk kesan profesional di foto wisuda!';
      }
      if (msg.contains('party') || msg.contains('pesta') || msg.contains('ulang tahun') || msg.contains('ultah')) {
        return 'Harga makeup party/pesta:\n\n🎉 Paket Natural: Rp 150.000 - 250.000\n🎉 Paket Glam: Rp 250.000 - 450.000\n🎉 Paket Full Glam: Rp 450.000 - 700.000\n\nUntuk pesta malam, pilih full glam agar terlihat lebih berkilau!';
      }
      return 'Harga MUA di BeautyHub bervariasi:\n\n💄 Makeup Natural/Sehari-hari: Rp 100.000 - 250.000\n💍 Makeup Wedding: Rp 500.000 - 3.000.000\n🎓 Makeup Wisuda: Rp 150.000 - 600.000\n🎉 Makeup Party: Rp 150.000 - 700.000\n🎭 Makeup Karakter: Rp 300.000 - 1.000.000\n🌙 Makeup Prewedding: Rp 400.000 - 1.500.000\n\nHarga tergantung pengalaman MUA dan lokasi. Mau cari MUA dengan budget tertentu?';
    }

    // ── WEDDING ────────────────────────────────────────────────────
    if (msg.contains('wedding') || msg.contains('nikah') || msg.contains('pernikahan') ||
        msg.contains('pengantin') || msg.contains('bride') || msg.contains('menikah') ||
        msg.contains('akad') || msg.contains('resepsi')) {
      return 'Tips booking MUA untuk wedding:\n\n💍 Book MUA 2-3 bulan sebelum hari H\n💍 Lakukan trial makeup 1 bulan sebelumnya\n💍 Diskusikan tema: modern, tradisional, atau mix\n💍 Pastikan MUA berpengalaman makeup tahan 8-12 jam\n💍 Siapkan referensi foto makeup yang kamu inginkan\n\nMau cari MUA wedding di area kamu? Buka menu Home dan ketik lokasi kamu! 💍';
    }

    // ── WISUDA ─────────────────────────────────────────────────────
    if (msg.contains('wisuda') || msg.contains('graduation') || msg.contains('toga')) {
      return 'Tips makeup wisuda:\n\n🎓 Pilih makeup natural dan elegan\n🎓 Hindari warna terlalu mencolok\n🎓 Gunakan foundation tahan lama\n🎓 Book MUA minimal 1-2 minggu sebelumnya\n🎓 Datang lebih awal untuk persiapan\n\nBiaya makeup wisuda sekitar Rp 150.000 - 600.000. Cari MUA wisuda di menu Home!';
    }

    // ── PREWEDDING ─────────────────────────────────────────────────
    if (msg.contains('prewedding') || msg.contains('pre wedding') || msg.contains('foto prewed')) {
      return 'Tips makeup prewedding:\n\n📸 Pilih makeup yang fotogenik\n📸 Sesuaikan dengan konsep foto\n📸 Test makeup sebelum sesi foto\n📸 Bawa touch-up kit untuk retouching\n📸 Diskusikan dengan fotografer soal lighting\n\nHarga makeup prewedding Rp 400.000 - 1.500.000. Cari MUA prewedding di BeautyHub!';
    }

    // ── NATURAL MAKEUP ─────────────────────────────────────────────
    if (msg.contains('natural') || msg.contains('sehari') || msg.contains('casual') ||
        msg.contains('simpel') || msg.contains('simple') || msg.contains('ringan') ||
        msg.contains('no makeup') || msg.contains('bare')) {
      return 'Tips makeup natural:\n\n🌸 Gunakan BB cream atau cushion ringan\n🌸 Concealer tipis untuk noda\n🌸 Blush on peach atau pink nude\n🌸 Eyeshadow warna coklat atau peach\n🌸 Mascara dan eyeliner tipis\n🌸 Lip gloss atau lipstik nude\n\nMakeup natural cocok untuk aktivitas sehari-hari, kuliah, atau kerja kantoran!';
    }

    // ── GLAM MAKEUP ────────────────────────────────────────────────
    if (msg.contains('glam') || msg.contains('glamour') || msg.contains('bold') ||
        msg.contains('mencolok') || msg.contains('dramatis')) {
      return 'Tips full glam makeup:\n\n✨ Foundation full coverage\n✨ Contouring dan highlight\n✨ Eyeshadow smoky atau bold\n✨ Eyeliner tegas\n✨ False lashes\n✨ Lipstik merah atau bold\n\nFull glam cocok untuk pesta malam, konser, atau acara formal!';
    }

    // ── BOOKING ────────────────────────────────────────────────────
    if (msg.contains('booking') || msg.contains('pesan') || msg.contains('book') ||
        msg.contains('jadwal') || msg.contains('reservasi') || msg.contains('order') ||
        msg.contains('daftar') || msg.contains('mendaftar')) {
      return 'Cara booking MUA di BeautyHub:\n\n1️⃣ Buka halaman Home\n2️⃣ Scroll dan pilih MUA yang kamu suka\n3️⃣ Klik tombol "Lihat Profil"\n4️⃣ Pilih layanan yang diinginkan\n5️⃣ Pilih tanggal acara\n6️⃣ Isi alamat lokasi\n7️⃣ Klik Konfirmasi Booking\n\nSetelah MUA approve, kamu dapat QR Code untuk verifikasi! 📲';
    }

    // ── BATAL BOOKING ──────────────────────────────────────────────
    if (msg.contains('batal') || msg.contains('cancel') || msg.contains('batalkan')) {
      return 'Untuk membatalkan booking:\n\n❌ Buka menu Booking\n❌ Pilih booking yang ingin dibatalkan\n❌ Klik tombol Batalkan\n\n⚠️ Perhatian:\n- Pembatalan sebaiknya dilakukan minimal 3 hari sebelum acara\n- Hubungi MUA langsung jika ada keperluan mendesak\n\nAda yang bisa saya bantu lagi?';
    }

    // ── STATUS BOOKING ─────────────────────────────────────────────
    if (msg.contains('status') || msg.contains('konfirmasi') || msg.contains('approved') ||
        msg.contains('disetujui') || msg.contains('pending') || msg.contains('ditolak') ||
        msg.contains('rejected')) {
      return 'Status booking di BeautyHub:\n\n⏳ Pending = Menunggu konfirmasi MUA\n✅ Disetujui = Booking dikonfirmasi + QR Code tersedia\n❌ Ditolak = MUA tidak bisa memenuhi jadwal\n🚫 Dibatalkan = Kamu membatalkan booking\n✔️ Selesai = Acara telah berlangsung\n\nCek status booking di menu Booking ya!';
    }

    // ── QR CODE ────────────────────────────────────────────────────
    if (msg.contains('qr') || msg.contains('kode') || msg.contains('verifikasi') ||
        msg.contains('scan') || msg.contains('barcode')) {
      return 'QR Code untuk verifikasi booking:\n\n📲 QR Code muncul setelah booking disetujui MUA\n📲 Buka menu Booking → pilih booking approved\n📲 Klik "Lihat QR Code"\n📲 Tunjukkan ke MUA saat hari acara\n📲 MUA akan scan untuk konfirmasi kehadiran\n\nJaga QR Code agar tidak dibagikan ke orang lain ya!';
    }

    // ── NOTIFIKASI ─────────────────────────────────────────────────
    if (msg.contains('notif') || msg.contains('pemberitahuan') || msg.contains('notifikasi')) {
      return 'Notifikasi di BeautyHub:\n\n🔔 Kamu akan dapat notifikasi saat:\n- Booking disetujui MUA ✅\n- Booking ditolak MUA ❌\n- Reminder acara mendekati hari H\n\nCek notifikasi di ikon lonceng 🔔 di halaman Home!';
    }

    // ── BNSP ───────────────────────────────────────────────────────
    if (msg.contains('bnsp') || msg.contains('sertifikat') || msg.contains('certified') ||
        msg.contains('verified') || msg.contains('terverifikasi') || msg.contains('lisensi') ||
        msg.contains('profesional')) {
      return 'BNSP (Badan Nasional Sertifikasi Profesi):\n\n🏆 Lembaga pemerintah untuk sertifikasi profesi\n🏆 MUA bersertifikat BNSP telah melewati uji kompetensi\n🏆 Jaminan kualitas dan profesionalisme\n🏆 Standar nasional yang diakui\n\nSemua MUA di BeautyHub sudah diverifikasi! Cari MUA verified di menu Home.';
    }

    // ── TIPS MAKEUP ────────────────────────────────────────────────
    if (msg.contains('tips') || msg.contains('saran') || msg.contains('cara') ||
        msg.contains('rekomendasi') || msg.contains('rekomen') || msg.contains('suggest') ||
        msg.contains('pilih') || msg.contains('memilih')) {
      return 'Tips memilih MUA yang tepat:\n\n⭐ Lihat portfolio karya mereka\n⭐ Cek ulasan dari pelanggan sebelumnya\n⭐ Pastikan MUA memiliki sertifikasi BNSP\n⭐ Diskusikan konsep sebelum booking\n⭐ Lakukan trial jika memungkinkan\n⭐ Sesuaikan budget dengan layanan\n⭐ Pastikan MUA bisa datang ke lokasi kamu\n\nSemua MUA di BeautyHub sudah terverifikasi dan berpengalaman!';
    }

    // ── LOKASI ─────────────────────────────────────────────────────
    if (msg.contains('indramayu') || msg.contains('cirebon') || msg.contains('bandung') ||
        msg.contains('jakarta') || msg.contains('surabaya') || msg.contains('yogyakarta') ||
        msg.contains('jogja') || msg.contains('semarang') || msg.contains('malang') ||
        msg.contains('lokasi') || msg.contains('daerah') || msg.contains('area') ||
        msg.contains('kota') || msg.contains('domisili') || msg.contains('terdekat') ||
        msg.contains('dekat')) {
      return 'MUA di BeautyHub tersebar di berbagai kota! 📍\n\nCara cari MUA di area kamu:\n1. Buka halaman Home\n2. Lihat lokasi MUA di setiap kartu\n3. Klik "Lihat Profil" untuk detail\n\nSaat ini tersedia MUA di area:\n📍 Indramayu\n📍 Cirebon\n📍 Bandung\n📍 Jakarta\ndan kota lainnya!\n\nMau cari MUA di area tertentu?';
    }

    // ── TRIAL MAKEUP ───────────────────────────────────────────────
    if (msg.contains('trial') || msg.contains('coba') || msg.contains('test makeup') ||
        msg.contains('percobaan')) {
      return 'Tentang trial makeup:\n\n💅 Trial disarankan 2-4 minggu sebelum acara\n💅 Gunakan untuk memastikan cocok dengan kulit\n💅 Diskusikan perubahan yang diinginkan\n💅 Foto hasil trial sebagai referensi\n💅 Biasanya ada biaya tambahan Rp 100.000 - 300.000\n\nTrial sangat penting untuk acara besar seperti wedding!';
    }

    // ── KULIT ──────────────────────────────────────────────────────
    if (msg.contains('kulit') || msg.contains('skin') || msg.contains('foundation') ||
        msg.contains('kering') || msg.contains('berminyak') || msg.contains('kombinasi') ||
        msg.contains('sensitif') || msg.contains('jerawat') || msg.contains('flek')) {
      return 'Tips makeup sesuai jenis kulit:\n\n🌊 Kulit Kering:\n- Gunakan foundation berbasis minyak\n- Primer hydrating\n- Setting spray\n\n✨ Kulit Berminyak:\n- Foundation matte finish\n- Primer anti-shine\n- Bedak tabur transparan\n\n🌿 Kulit Kombinasi:\n- Foundation lightweight\n- Primer di zona T\n- Blotting paper untuk touch-up\n\n🌸 Kulit Sensitif:\n- Produk hypoallergenic\n- Mineral makeup\n- Test patch sebelum aplikasi';
    }

    // ── PRODUK MAKEUP ──────────────────────────────────────────────
    if (msg.contains('produk') || msg.contains('brand') || msg.contains('merk') ||
        msg.contains('merek') || msg.contains('kosmetik') || msg.contains('make up') ||
        msg.contains('lipstik') || msg.contains('mascara') || msg.contains('eyeshadow') ||
        msg.contains('blush') || msg.contains('highlighter') || msg.contains('contour')) {
      return 'Produk makeup yang sering digunakan MUA profesional:\n\n💄 Foundation: MAC, NARS, Maybelline, Wardah\n👁️ Eyeshadow: Urban Decay, Morphe, NYX\n💋 Lipstik: MAC, Kylie, Pixy, Emina\n✨ Highlighter: Becca, Fenty Beauty\n🎨 Blush: NARS, Too Faced, Implora\n\nMUA profesional biasanya membawa koleksi produk lengkap untuk berbagai kebutuhan!';
    }

    // ── RAMBUT ─────────────────────────────────────────────────────
    if (msg.contains('rambut') || msg.contains('hair') || msg.contains('sanggul') ||
        msg.contains('hijab') || msg.contains('styling') || msg.contains('curly') ||
        msg.contains('smoothing')) {
      return 'Layanan rambut dari MUA:\n\n💇 Beberapa MUA juga menyediakan:\n- Penataan rambut (updo, curly, dll)\n- Sanggul tradisional maupun modern\n- Styling hijab untuk acara\n- Hair accessories\n\n⚠️ Tidak semua MUA menyediakan layanan rambut. Pastikan konfirmasi langsung ke MUA saat booking!\n\nCek detail layanan di profil MUA ya.';
    }

    // ── MAKEUP KARAKTER ────────────────────────────────────────────
    if (msg.contains('karakter') || msg.contains('cosplay') || msg.contains('halloween') ||
        msg.contains('special effect') || msg.contains('sfx') || msg.contains('bodypainting') ||
        msg.contains('fantasi')) {
      return 'Makeup karakter/special:\n\n🎭 Jenis makeup karakter:\n- Cosplay character\n- Special Effect (SFX)\n- Body painting\n- Karakter fantasi/halloween\n- Makeup teater/pertunjukan\n\nHarga Rp 300.000 - 1.000.000 tergantung kerumitan desain.\n\nCari MUA dengan keahlian khusus ini di BeautyHub!';
    }

    // ── KEAMANAN ───────────────────────────────────────────────────
    if (msg.contains('aman') || msg.contains('alergi') || msg.contains('halal') ||
        msg.contains('bpom') || msg.contains('keamanan') || msg.contains('bahaya')) {
      return 'Keamanan produk makeup:\n\n🛡️ Tips memastikan keamanan:\n- Pilih produk sudah terdaftar BPOM\n- Beritahu MUA jika ada alergi produk tertentu\n- Test patch di kulit sebelum acara\n- Pilih produk berlabel halal jika dibutuhkan\n\n✅ MUA di BeautyHub profesional dan menggunakan produk berkualitas. Jangan lupa beritahu riwayat alergi kamu saat booking!';
    }

    // ── DURASI ─────────────────────────────────────────────────────
    if (msg.contains('berapa lama') || msg.contains('durasi') || msg.contains('waktu') ||
        msg.contains('jam berapa') || msg.contains('lama') || msg.contains('cepat')) {
      return 'Estimasi waktu pengerjaan makeup:\n\n⏱️ Makeup Natural: 30-45 menit\n⏱️ Makeup Wisuda: 45-60 menit\n⏱️ Makeup Party: 60-90 menit\n⏱️ Makeup Wedding: 90-180 menit\n⏱️ Makeup Karakter: 120-240 menit\n\nDisarankan MUA datang 30 menit lebih awal untuk persiapan. Pastikan booking dengan waktu yang cukup!';
    }

    // ── PEMBAYARAN ─────────────────────────────────────────────────
    if (msg.contains('transfer') || msg.contains('dp') || msg.contains('down payment') ||
        msg.contains('cicil') || msg.contains('cash') || msg.contains('tunai') ||
        msg.contains('pembayaran') || msg.contains('bayar')) {
      return 'Metode pembayaran MUA:\n\n💳 Umumnya MUA menerima:\n- Transfer bank (BCA, BNI, BRI, Mandiri)\n- GoPay, OVO, Dana\n- QRIS\n- Cash/Tunai\n\n💰 Sistem DP (Down Payment):\n- Biasanya DP 30-50% saat booking\n- Pelunasan di hari acara\n\nKonfirmasi metode pembayaran langsung dengan MUA ya!';
    }

    // ── PERSIAPAN SEBELUM MAKEUP ───────────────────────────────────
    if (msg.contains('persiapan') || msg.contains('sebelum makeup') || msg.contains('skincare') ||
        msg.contains('moisturizer') || msg.contains('primer')) {
      return 'Persiapan sebelum sesi makeup:\n\n✨ Yang harus dilakukan:\n- Cuci muka dan keringkan\n- Aplikasikan skincare rutin (serum, moisturizer)\n- Tunggu skincare meresap 15-20 menit\n- Jangan pakai makeup sendiri dulu\n- Siapkan referensi look yang diinginkan\n\n❌ Yang harus dihindari:\n- Facial/treatment wajah H-3\n- Mencukur alis sendiri\n- Eksfoliasi berlebihan\n\nKulit yang terhidrasi = hasil makeup lebih bagus!';
    }

    // ── PERAWATAN SETELAH MAKEUP ────────────────────────────────────
    if (msg.contains('setelah makeup') || msg.contains('bersihkan') || msg.contains('hapus') ||
        msg.contains('micellar') || msg.contains('cleansing') || msg.contains('remover')) {
      return 'Cara bersihkan makeup dengan benar:\n\n🧴 Langkah pembersihan:\n1. Gunakan micellar water/cleansing oil\n2. Double cleanse dengan facial wash\n3. Toner untuk menyeimbangkan pH\n4. Moisturizer untuk rehidrasi\n\n⚠️ Jangan tidur dengan makeup! Bisa menyumbat pori dan menyebabkan jerawat.\n\nRutinitas malam yang baik = kulit tetap sehat! 🌙';
    }

    // ── REVIEW / ULASAN ────────────────────────────────────────────
    if (msg.contains('review') || msg.contains('ulasan') || msg.contains('rating') ||
        msg.contains('bintang') || msg.contains('testimoni') || msg.contains('feedback')) {
      return 'Cara memberikan ulasan MUA:\n\n⭐ Setelah acara selesai, kamu bisa:\n1. Buka profil MUA\n2. Berikan rating bintang 1-5\n3. Tulis pengalaman kamu\n4. Upload foto hasil makeup (opsional)\n\nUlasan kamu sangat membantu MUA dan customer lain! Semakin banyak ulasan positif, semakin dipercaya MUA tersebut 🌟';
    }

    // ── MUA ITU APA ────────────────────────────────────────────────
    if (msg.contains('mua itu') || msg.contains('apa itu mua') || msg.contains('makeup artist') ||
        msg.contains('siapa mua') || msg.contains('apa mua')) {
      return 'MUA (Makeup Artist) adalah:\n\n💄 Profesional di bidang tata rias\n💄 Terlatih untuk berbagai jenis makeup\n💄 Menggunakan teknik dan produk profesional\n💄 Berpengalaman untuk berbagai acara\n\nMUA di BeautyHub sudah:\n✅ Terverifikasi identitasnya\n✅ Memiliki portfolio yang bisa dilihat\n✅ Bersertifikat BNSP (sebagian)\n✅ Berpengalaman melayani pelanggan\n\nTemukan MUA terbaik di BeautyHub sekarang!';
    }

    // ── BEAUTYBOT / APLIKASI ───────────────────────────────────────
    if (msg.contains('beautyhub') || msg.contains('aplikasi') || msg.contains('app') ||
        msg.contains('fitur') || msg.contains('beautybot')) {
      return 'Tentang BeautyHub:\n\n💅 BeautyHub adalah aplikasi untuk:\n- Menemukan MUA bersertifikat di sekitar kamu\n- Booking MUA langsung dari HP\n- Melihat portfolio dan ulasan MUA\n- Chatbot untuk tanya-tanya seputar makeup\n- Pencarian MUA berdasarkan foto referensi\n\n🚀 Fitur unggulan:\n✨ QR Code verifikasi kehadiran\n🔔 Notifikasi real-time\n📸 Search by image\n💬 BeautyBot 24 jam\n\nDownload dan gunakan BeautyHub sekarang!';
    }

    // ── DEFAULT ────────────────────────────────────────────────────
    return 'Maaf, saya kurang memahami pertanyaan kamu 😅\n\nCoba tanyakan seputar:\n💰 Harga makeup (wedding, wisuda, party)\n📅 Cara booking MUA\n✨ Tips memilih MUA\n🏆 Sertifikasi BNSP\n📍 MUA di kota tertentu\n⏱️ Durasi pengerjaan\n💳 Metode pembayaran\n🧴 Persiapan sebelum makeup\n\nAtau klik pertanyaan cepat di atas!';
  }

  Future<void> _sendMessage([String? quickMsg]) async {
    final text = quickMsg ?? _messageCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isBot: false));
      _isLoading = true;
    });
    _messageCtrl.clear();
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _messages.add(_ChatMessage(text: _getResponse(text), isBot: true));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.face_retouching_natural,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BeautyBot',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Online',
                    style: TextStyle(
                        fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [maroon, pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Harga makeup',
                  'Cara booking',
                  'Tips MUA',
                  'MUA wedding',
                  'Persiapan makeup',
                  'Durasi makeup',
                ].map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(s,
                            style: const TextStyle(fontSize: 12)),
                        onPressed: () => _sendMessage(s),
                        backgroundColor:
                            pink.withValues(alpha: 0.1),
                        side: const BorderSide(
                            color: pink, width: 0.5),
                        labelStyle: const TextStyle(color: pink),
                      ),
                    ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) =>
                  _ChatBubble(message: _messages[i]),
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: pink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                        Icons.face_retouching_natural,
                        color: Colors.white,
                        size: 16),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                          3,
                          (i) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 2),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration:
                                      const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding:
                const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => _sendMessage(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [maroon, pink],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send,
                          color: Colors.white, size: 20),
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
}

class _ChatMessage {
  final String text;
  final bool isBot;
  _ChatMessage({required this.text, required this.isBot});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isBot = message.isBot;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBot) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFCF4C4C),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                  Icons.face_retouching_natural,
                  color: Colors.white,
                  size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isBot
                    ? Colors.white
                    : const Color(0xFFCF4C4C),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      Radius.circular(isBot ? 4 : 18),
                  bottomRight:
                      Radius.circular(isBot ? 18 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isBot
                      ? Colors.black87
                      : Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (!isBot) const SizedBox(width: 8),
        ],
      ),
    );
  }
}