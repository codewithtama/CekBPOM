class ApiConstants {
  ApiConstants._();

  static const String primaryApiUrl = 'https://api-cekbpom.pom.go.id/api/produk/nomor_notif/';
  static const String fallbackBaseUrl = 'https://cekbpom.pom.go.id';
  static const String fallbackAllProdukUrl = 'https://cekbpom.pom.go.id/all-produk';
  static const String fallbackApiUrl = 'https://cekbpom.pom.go.id/produk-dt/all';
  static const String fallbackDetailUrl = 'https://cekbpom.pom.go.id/produk/{productId}/{applicationId}/detail';
  
  // BPOM Official Complaint link
  static const String bpomComplaintUrl = 'https://ulpk.pom.go.id/';
  
  // BPOM news RSS fallback/static source URL
  static const String bpomNewsUrl = 'https://www.pom.go.id/berita';

  // BPJPH Kemenag RI Halal Portal
  static const String bpjphHalalSearchUrl = 'https://bpjph.halal.go.id/cari/sertifikat';
  static const String kemenagHalalPortalUrl = 'https://bpjph.halal.go.id/';

  // HKI / DJKI Trademark Portal (haki.id)
  static const String hakiApiUrl = 'https://haki.id/api/trademarks';
  static const String hakiBaseUrl = 'https://haki.id';
}
