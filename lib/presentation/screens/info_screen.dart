import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _buildProdukBerbahayaTab(),
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
                    Text(
                      guide['title']!,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
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

  Widget _buildProdukBerbahayaTab() {
    // Top warnings from BPOM database
    final List<Map<String, String>> alerts = [
      {
        'title': 'Peringatan Kosmetik Mengandung Merkuri & Hidrokuinon',
        'date': 'Mei 2026',
        'source': 'Public Warning BPOM RI',
        'desc': 'BPOM merilis daftar kosmetik pemutih wajah ilegal yang terbukti mengandung bahan berbahaya Merkuri (Mercury) dan Hidrokuinon tingkat tinggi yang memicu kanker kulit.',
      },
      {
        'title': 'Penarikan Obat Sirop Tercemar Etilen Glikol (EG)',
        'date': 'Februari 2026',
        'source': 'Klarifikasi BPOM',
        'desc': 'Pengawasan ketat terhadap obat sirop anak. Beberapa bets produk ditarik karena ditemukan cemaran EG/DEG melebihi ambang batas aman yang memicu gagal ginjal akut.',
      },
      {
        'title': 'Suplemen Tradisional Mengandung Bahan Kimia Obat (BKO)',
        'date': 'Desember 2025',
        'source': 'Siaran Pers BPOM',
        'desc': 'Hasil sampling menemukan jamu pegal linu dan penambah stamina ilegal dicampuri Bahan Kimia Obat parasetamol, sildenafil, dan dexamethasone tanpa izin edar.',
      },
      {
        'title': 'Kopi Kemasan Mengandung Sildenafil & Tadalafil',
        'date': 'Oktober 2025',
        'source': 'Klarifikasi BPOM',
        'desc': 'BPOM menyita produk kopi serbuk tradisional yang dicampuri obat kuat sildenafil secara ilegal. Dapat memicu serangan jantung fatal.',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rilis Publik / Recall Terbaru',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => _launchUrl(ApiConstants.bpomNewsUrl),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const Text(
            'Daftar rilis peringatan publik resmi BPOM terkait temuan produk obat, kosmetika, dan pangan berbahaya.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          
          ...alerts.map((alert) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.dangerLight, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Container(
              color: AppColors.dangerLight.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        alert['source']!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                        ),
                      ),
                      Text(
                        alert['date']!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    alert['title']!,
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alert['desc']!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
