import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/news_model.dart';
import '../providers/news_provider.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Tidak ada aplikasi browser yang terpasang.');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka tautan: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Informasi & Edukasi'),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            labelStyle: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Cara Baca'),
              Tab(text: 'Rilis BPOM'),
              Tab(text: 'Kamus Zat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCaraBacaTab(),
            _buildProdukBerbahayaTab(context, ref),
            const BannedSubstancesKamusTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCaraBacaTab() {
    final List<Map<String, String>> guides = [
      {
        'title': 'KOSMETIKA',
        'prefix': 'Kode: NA / NB / NC / ND / NE',
        'desc': 'Diikuti oleh 11 digit angka. Huruf ketiga menandakan benua asal (misal: NA = Asia/Lokal, NC = Eropa, ND = Amerika). Biasanya terletak di bagian belakang atau bawah botol/kemasan.',
      },
      {
        'title': 'PANGAN OLAHAN',
        'prefix': 'Kode: MD / ML',
        'desc': 'MD (Makanan Dalam negeri) untuk produksi lokal, ML (Makanan Luar negeri) untuk impor. Diikuti oleh 12 digit angka. Wajib tercantum jelas di bagian depan atau label pangan.',
      },
      {
        'title': 'OBAT TRADISIONAL & JAMU',
        'prefix': 'Kode: TR / TI / HT / FF',
        'desc': 'TR (Tradisional Lokal), TI (Tradisional Impor), HT (Herbal Terstandar), FF (Fitofarmaka). Diikuti oleh 9 digit angka. Harus memiliki logo khusus (Jamu ranting hijau, Fitofarmaka kristal salju).',
      },
      {
        'title': 'SUPLEMEN KESEHATAN',
        'prefix': 'Kode: SD / SI',
        'desc': 'SD (Suplemen Dalam negeri), SI (Suplemen Impor). Diikuti oleh 9 digit angka. Membantu menjaga stamina tubuh namun wajib dicek keamanannya.',
      },
      {
        'title': 'OBAT-OBATAN',
        'prefix': 'Kode: DKL / DTL / GKL / etc.',
        'desc': 'Huruf ke-1 (D=Nama Dagang, G=Generik). Huruf ke-2 (K=Obat Keras, T=Obat Bebas Terbatas, B=Obat Bebas). Huruf ke-3 (L=Lokal, I=Impor). Diikuti 15 digit kombinasi angka & huruf.',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panduan Membaca Kode BPOM',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Kenali jenis kode registrasi BPOM pada produk untuk memastikan kategori produk Anda sudah sesuai.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          ...guides.map((guide) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        guide['title']!,
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        guide['prefix']!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  guide['desc']!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProdukBerbahayaTab(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(newsProvider);
        try {
          await ref.read(newsProvider.future);
        } catch (_) {}
      },
      child: newsAsync.when(
        data: (newsList) {
          if (newsList.isEmpty) {
            return _buildEmptyState();
          }
          return _buildNewsList(newsList);
        },
        loading: () => _buildShimmerLoading(),
        error: (error, stack) {
          return _buildErrorState(error, ref);
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meta info row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(width: 80, height: 12, color: Colors.white),
                          Container(width: 60, height: 12, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Title placeholder
                      Container(width: double.infinity, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 200, height: 16, color: Colors.white),
                      const SizedBox(height: 12),
                      // Description placeholder
                      Container(width: double.infinity, height: 12, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(width: double.infinity, height: 12, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.newspaper_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada berita terbaru',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Belum ada rilis berita dari BPOM saat ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, WidgetRef ref) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: AppColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Berita',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(newsProvider),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList(List<NewsModel> newsList) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: newsList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Header info
          return Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rilis Publik / Berita Terbaru',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _launchUrl(context, ApiConstants.bpomNewsUrl),
                      child: const Text('Buka Portal'),
                    ),
                  ],
                ),
                const Text(
                  'Informasi rilis, press release, edukasi keamanan, dan penarikan produk resmi langsung dari portal berita BPOM RI.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }

        final news = newsList[index - 1];
        
        // Determine whether this news is likely a warning or recall (danger alert) or a standard news
        final isWarning = news.title.toLowerCase().contains('peringatan') ||
            news.title.toLowerCase().contains('tarik') ||
            news.title.toLowerCase().contains('bahaya') ||
            news.title.toLowerCase().contains('cemaran') ||
            news.title.toLowerCase().contains('ilegal') ||
            news.title.toLowerCase().contains('bko') ||
            news.title.toLowerCase().contains('obat sirop') ||
            news.imageUrl.isEmpty; // fallback items have no images

        final cardBorderColor = isWarning 
            ? AppColors.danger.withValues(alpha: 0.6) 
            : AppColors.border.withValues(alpha: 0.7);
            
        final cardBgColor = isWarning
            ? AppColors.dangerLight.withValues(alpha: 0.1)
            : AppColors.surface;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cardBorderColor, width: isWarning ? 1.5 : 1),
          ),
          clipBehavior: Clip.antiAlias,
          color: cardBgColor,
          child: InkWell(
            onTap: () => _launchUrl(context, news.url),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (news.imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: news.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image_rounded, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isWarning 
                                  ? AppColors.dangerLight 
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isWarning ? 'PERINGATAN / ALERT' : 'BERITA BPOM',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isWarning ? AppColors.danger : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (news.date.isNotEmpty)
                            Flexible(
                              child: Text(
                                news.date,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        news.title,
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      if (news.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          news.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Baca Selengkapnya',
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isWarning ? AppColors.danger : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: isWarning ? AppColors.danger : AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BannedSubstancesKamusTab extends StatefulWidget {
  const BannedSubstancesKamusTab({super.key});

  @override
  State<BannedSubstancesKamusTab> createState() => _BannedSubstancesKamusTabState();
}

class _BannedSubstancesKamusTabState extends State<BannedSubstancesKamusTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _substances = [
    {
      'name': 'Merkuri (Mercury / Calomel)',
      'risk': 'SANGAT TINGGI (BAHAYA)',
      'desc': 'Logam berat cair berwarna perak yang sering disalahgunakan untuk pemutih kulit instan.',
      'health': 'Memicu kanker kulit (karsinogenik), merusak saraf pusat (tremor, insomnia), merusak ginjal, serta menyebabkan cacat lahir pada janin.',
      'bpom': 'Dilarang keras (zero tolerance) untuk semua kosmetika dan makanan.'
    },
    {
      'name': 'Hidrokuinon (Hydroquinone)',
      'risk': 'TINGGI (PERINGATAN KERAS)',
      'desc': 'Bahan kimia aktif pemutih kulit yang menghambat pembentukan melanin.',
      'health': 'Menyebabkan okronosis eksogen (kulit menjadi hitam kebiruan permanen), iritasi parah, kulit terbakar jika terkena matahari, dan meningkatkan risiko kanker.',
      'bpom': 'Hanya boleh digunakan sebagai obat keras dengan resep dokter (maksimal 2% pada produk medis), dilarang dalam kosmetik bebas.'
    },
    {
      'name': 'Etilen Glikol / Dietilen Glikol (EG & DEG)',
      'risk': 'SANGAT TINGGI (BAHAYA)',
      'desc': 'Cemaran pelarut gliserin/propilen glikol yang sering ditemukan dalam obat sirup berkualitas rendah.',
      'health': 'Memicu kerusakan ginjal akut secara cepat (Gagal Ginjal Akut Progresif Atipikal), asidosis metabolik, koma, hingga kematian terutama pada anak-anak.',
      'bpom': 'Batas cemaran maksimal sangat ketat (≤ 0.1%), melebihi batas akan ditarik dari peredaran.'
    },
    {
      'name': 'Bahan Kimia Obat (Steroid / Deksametason)',
      'risk': 'TINGGI (BAHAYA)',
      'desc': 'Obat anti-inflamasi keras yang sering dicampurkan secara ilegal ke dalam jamu pegal linu atau obat tradisional.',
      'health': 'Menyebabkan Cushing Syndrome (wajah membulat/moon face), osteoporosis, kerusakan lambung (pendarahan), hipertensi, diabetes melitus, dan ketergantungan obat.',
      'bpom': 'Dilarang keras dicampurkan dalam jamu, obat tradisional, atau suplemen.'
    },
    {
      'name': 'Rhodamin B',
      'risk': 'SANGAT TINGGI (BAHAYA)',
      'desc': 'Pewarna sintetik berbentuk serbuk merah keunguan untuk industri kertas/tekstil.',
      'health': 'Bersifat karsinogenik (memicu kanker), merusak fungsi hati (hepatotoksik), dan menyebabkan iritasi parah pada saluran pencernaan.',
      'bpom': 'Dilarang keras untuk produk pangan, minuman, obat-obatan, dan kosmetika.'
    },
    {
      'name': 'Formalin (Formaldehyde)',
      'risk': 'SANGAT TINGGI (BAHAYA)',
      'desc': 'Pengawet industri untuk mayat, kayu, dan lem yang sering disalahgunakan untuk mengawetkan makanan (tahu, mi basah, ikan).',
      'health': 'Menyebabkan kanker saluran pernapasan (nasofaring), kerusakan parah pada dinding lambung, muntah darah, gagal ginjal, dan kerusakan sel akut.',
      'bpom': 'Dilarang keras digunakan sebagai pengawet pangan.'
    },
    {
      'name': 'Boraks (Asam Borat / Pijer)',
      'risk': 'SANGAT TINGGI (BAHAYA)',
      'desc': 'Bahan solder, pengawet kayu, dan antiseptik yang disalahgunakan untuk pengenyal bakso, kerupuk, atau mi.',
      'health': 'Menumpuk di otak, hati, dan ginjal. Menyebabkan demam, depresi mental, kerusakan testis (kemandulan), dan kematian jika terkonsumsi berlebih.',
      'bpom': 'Dilarang keras ditambahkan ke dalam makanan.'
    },
    {
      'name': 'Sildenafil Sitrat / Tadalafil',
      'risk': 'TINGGI (BAHAYA)',
      'desc': 'Zat aktif obat disfungsi ereksi (obat kuat) yang dicampur ilegal ke dalam kopi kejantanan atau jamu pria.',
      'health': 'Memicu serangan jantung mendadak, stroke fatal, kehilangan penglihatan/pendengaran, dan penurunan tekanan darah drastis.',
      'bpom': 'Dilarang keras dicampur ke dalam jamu atau suplemen pangan.'
    },
    {
      'name': 'Timbal (Lead / Pb)',
      'risk': 'TINGGI (PERINGATAN)',
      'desc': 'Logam berat beracun yang sering mengotori produk kosmetik lipstik atau eye shadow murah/ilegal.',
      'health': 'Menyebabkan kerusakan sistem saraf pusat, penurunan kecerdasan anak, gangguan ginjal, anemia, dan gangguan sistem reproduksi.',
      'bpom': 'Batas cemaran kosmetik maksimal 20 ppm.'
    },
    {
      'name': 'Asam Salisilat (Salicylic Acid)',
      'risk': 'PERINGATAN (BATAS KADAR)',
      'desc': 'Asam beta-hidroksi (BHA) yang umum digunakan untuk obat jerawat dan pengelupasan kulit.',
      'health': 'Penggunaan melebihi kadar aman memicu iritasi ekstrem, kulit mengelupas parah, rasa terbakar, dan keracunan salisilat jika diserap tubuh secara berlebihan.',
      'bpom': 'Batas aman kosmetik tanpa bilas maksimal 2.0%, dilarang untuk anak di bawah 3 tahun.'
    }
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _substances.where((sub) {
      final name = sub['name']!.toLowerCase();
      final desc = sub['desc']!.toLowerCase();
      final health = sub['health']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || desc.contains(query) || health.contains(query);
    }).toList();

    return Column(
      children: [
        // Search Input
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari zat berbahaya...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        // List View
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak Ditemukan',
                        style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isHighRisk = item['risk']!.contains('SANGAT TINGGI') || item['risk']!.contains('BAHAYA');
                    final riskColor = isHighRisk ? AppColors.danger : AppColors.warning;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: AppColors.primary,
                          title: Text(
                            item['name']!,
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: riskColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['risk']!,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: riskColor,
                              ),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  _buildSubstanceDetailRow('Apa itu?', item['desc']!),
                                  const SizedBox(height: 10),
                                  _buildSubstanceDetailRow('Bahaya Kesehatan:', item['health']!, isDanger: true),
                                  const SizedBox(height: 10),
                                  _buildSubstanceDetailRow('Regulasi BPOM:', item['bpom']!, isSuccess: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSubstanceDetailRow(String label, String value, {bool isDanger = false, bool isSuccess = false}) {
    Color valColor = AppColors.textPrimary;
    if (isDanger) valColor = AppColors.danger;
    if (isSuccess) valColor = AppColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            fontWeight: isDanger || isSuccess ? FontWeight.bold : FontWeight.normal,
            color: valColor,
          ),
        ),
      ],
    );
  }
}
