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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Informasi & Edukasi'),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            labelStyle: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Cara Baca Kemasan'),
              Tab(text: 'Produk Berbahaya'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCaraBacaTab(),
            _buildProdukBerbahayaTab(context, ref),
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
