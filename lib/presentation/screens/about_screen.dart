import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo / Icon representation
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 3),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.primary,
                size: 56,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'CekBPOM',
              style: GoogleFonts.lexend(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'Versi 1.0.0',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            
            // Description Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deskripsi Projek',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'CekBPOM adalah aplikasi independen yang dirancang untuk mempermudah masyarakat Indonesia melakukan pengecekan keaslian dan status keamanan produk obat, kosmetik, obat tradisional, suplemen kesehatan, dan pangan olahan langsung dari database Badan Pengawas Obat dan Makanan (BPOM) Republik Indonesia.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Dengan memindai barcode produk atau memasukkan nomor registrasi secara manual, Anda dapat memastikan apakah produk tersebut sudah terdaftar secara resmi, aman digunakan, atau berpotensi palsu/berbahaya.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // CTA Button for complaint
            ElevatedButton.icon(
              onPressed: () => _launchUrl(ApiConstants.bpomComplaintUrl),
              icon: const Icon(Icons.support_agent_rounded),
              label: const Text('Hubungi Pengaduan BPOM (ULPK)'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Disclaimer
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Disclaimer / Sanggahan',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aplikasi ini merupakan aplikasi pihak ketiga (independen) dan tidak memiliki afiliasi resmi dengan Badan Pengawas Obat dan Makanan (BPOM) Republik Indonesia. Data produk yang ditampilkan diperoleh secara real-time dari portal pencarian cekbpom publik.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
