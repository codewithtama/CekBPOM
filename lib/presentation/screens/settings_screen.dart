import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../providers/settings_provider.dart';
import '../providers/history_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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
            content: Text('Gagal membuka halaman: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showDisclaimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Disclaimer & Ketentuan',
            style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aplikasi CekBPOM merupakan aplikasi pihak ketiga (independen) yang dikembangkan untuk mempermudah masyarakat mengakses data registrasi produk.',
                  style: TextStyle(height: 1.4),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sanggahan Resmi:',
                  style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                const Text(
                  '1. Aplikasi ini tidak memiliki afiliasi resmi dengan Badan Pengawas Obat dan Makanan (BPOM) Republik Indonesia.\n'
                  '2. Semua data produk ditarik secara langsung dan real-time dari portal pencarian publik BPOM.\n'
                  '3. Pengembang tidak bertanggung jawab atas ketidaksesuaian data yang diakibatkan oleh perubahan sistem atau database internal BPOM.',
                  style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Saya Mengerti',
                style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'CekBPOM',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Versi 1.0.0 (Release)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aplikasi pemindai barcode produk & nomor registrasi BPOM. Dirancang dengan mengedepankan performa tinggi, kemudahan navigasi, dan visual premium.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                '© 2026 CekBPOM App. All rights reserved.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tutup',
                style: GoogleFonts.lexend(color: AppColors.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Hapus Semua Data?',
            style: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: AppColors.danger),
          ),
          content: const Text(
            'Tindakan ini akan menghapus seluruh riwayat pemindaian dan cache produk lokal Anda. Anda harus terhubung ke internet saat memeriksa produk baru lagi.',
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.lexend(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(historyProvider.notifier).clearAll();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Seluruh data riwayat & cache berhasil dihapus.'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Ya, Hapus Semua',
                style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // SCANNER SETTINGS SECTION
          _buildSectionTitle('Preferensi Pindai'),
          _buildSettingsCard(
            children: [
              SwitchListTile(
                value: settings.enableVibration,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).toggleVibration(val);
                  if (val) {
                    HapticFeedback.mediumImpact();
                  }
                },
                title: Text(
                  'Getaran Saat Berhasil',
                  style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Getarkan perangkat saat barcode berhasil dipindai',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                secondary: const Icon(Icons.vibration_rounded, color: AppColors.primary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                value: settings.enableSound,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).toggleSound(val);
                  if (val) {
                    SystemSound.play(SystemSoundType.click);
                  }
                },
                title: Text(
                  'Efek Suara',
                  style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Mainkan efek suara klik saat scan terdeteksi',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                secondary: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // DATA STORAGE SETTINGS SECTION
          _buildSectionTitle('Penyimpanan & Cache'),
          _buildSettingsCard(
            children: [
              ListTile(
                onTap: () => _confirmClearData(context, ref),
                leading: const Icon(Icons.delete_forever_rounded, color: AppColors.danger),
                title: Text(
                  'Bersihkan Cache & Riwayat',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
                subtitle: const Text(
                  'Hapus semua daftar produk yang tersimpan di memori offline',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // LINKS AND INFO SECTION
          _buildSectionTitle('Dukungan & Kebijakan'),
          _buildSettingsCard(
            children: [
              ListTile(
                onTap: () => _launchUrl(context, ApiConstants.bpomComplaintUrl),
                leading: const Icon(Icons.support_agent_rounded, color: AppColors.primary),
                title: Text(
                  'Hubungi Pengaduan ULPK BPOM',
                  style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Laporkan kosmetik berbahaya / efek samping langsung ke BPOM',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                onTap: () => _launchUrl(context, 'https://www.pom.go.id'),
                leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                title: Text(
                  'Kunjungi Portal Resmi BPOM',
                  style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Akses portal pom.go.id untuk info regulasi terbaru',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                onTap: () => _showDisclaimerDialog(context),
                leading: const Icon(Icons.gavel_rounded, color: AppColors.primary),
                title: Text(
                  'Ketentuan Layanan & Disclaimer',
                  style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Sanggahan hukum terkait data produk independen',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // APP VERSION & ABOUT SECTION
          _buildSectionTitle('Info Aplikasi'),
          _buildSettingsCard(
            children: [
              ListTile(
                onTap: () => _showAboutDialog(context),
                leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                title: Text(
                  'Tentang CekBPOM',
                  style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Informasi versi, lisensi, dan pembuat aplikasi',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.lexend(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }
}
