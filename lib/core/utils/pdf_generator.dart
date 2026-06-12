import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/product_model.dart';
import 'ingredients_analyzer.dart';

class PdfGenerator {
  static Future<void> generateAndPrintReport(ProductModel product) async {
    final pdf = pw.Document();
    
    // Safety status color mappings
    PdfColor accentColor;
    if (product.safetyStatus == 'AMAN') {
      accentColor = PdfColors.green800;
    } else if (product.safetyStatus == 'KEDALUWARSA' || product.safetyStatus == 'PERLU DICEK') {
      accentColor = PdfColors.amber800;
    } else {
      accentColor = PdfColors.red800;
    }

    final warnings = IngredientsAnalyzer.analyze(product.ingredients);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'LAPORAN VERIFIKASI KEAMANAN PRODUK',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey900,
                      ),
                    ),
                    pw.Text(
                      'CekBPOM App',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                  ],
                ),
                pw.Divider(thickness: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 20),

                // Product Safety Badge
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: accentColor,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'STATUS: ${product.safetyStatus}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),

                // Details Table
                pw.Text(
                  'DETAIL PRODUK',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  children: [
                    _buildTableRow('Nama Produk', product.name),
                    _buildTableRow('Nomor Registrasi BPOM', product.registrationNumber),
                    _buildTableRow('Merk / Brand', product.brand.isNotEmpty ? product.brand : '-'),
                    _buildTableRow('Bentuk Sediaan', product.form.isNotEmpty ? product.form : '-'),
                    _buildTableRow('Produsen / Pendaftar', product.manufacturer.isNotEmpty ? product.manufacturer : '-'),
                    _buildTableRow('Kemasan', product.package.isNotEmpty ? product.package : '-'),
                    _buildTableRow('Tanggal Registrasi', product.registeredDate.isNotEmpty ? product.registeredDate : '-'),
                    _buildTableRow('Tanggal Kedaluwarsa', product.expiredDate.isNotEmpty ? product.expiredDate : '-'),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Ingredients / Composition
                pw.Text(
                  'KOMPOSISI / BAHAN KANDUNGAN',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                  ),
                  child: pw.Text(
                    product.ingredients.isNotEmpty ? product.ingredients : 'Tidak ada data kandungan komposisi.',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.SizedBox(height: 24),

                // Chemical Warnings if any
                if (warnings.isNotEmpty) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.red50,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: PdfColors.red300, width: 1),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PERINGATAN BAHAN KIMIA BERBAHAYA!',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red900,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        ...warnings.map((w) => pw.Bullet(
                          text: '${w.chemicalName}: ${w.description}',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.red800),
                        )),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 24),
                ],

                pw.Spacer(),

                // Signatures / Footer
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Dicetak tanggal: ${DateTime.now().toLocal().toString().split('.')[0]}',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                        ),
                        pw.Text(
                          'Hasil validasi bersifat informatif berdasarkan data publik BPOM.',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Dikembangkan Oleh:',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Dimas Alfa Pratama',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey800,
                          ),
                        ),
                        pw.Text(
                          'Lead Fullstack Developer',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save and print/preview using printing library
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'laporan_cekbpom_${product.registrationNumber}.pdf',
    );
  }

  static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
      ],
    );
  }
}
