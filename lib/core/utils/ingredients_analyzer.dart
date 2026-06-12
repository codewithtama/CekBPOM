class IngredientWarning {
  final String chemicalName;
  final String category;
  final String dangerLevel; // 'BAHAYA' or 'PERINGATAN'
  final String description;

  IngredientWarning({
    required this.chemicalName,
    required this.category,
    required this.dangerLevel,
    required this.description,
  });
}

class IngredientsAnalyzer {
  static final Map<String, List<String>> _dangerousKeywords = {
    'Merkuri / Mercury': ['mercury', 'merkuri', 'calomel', 'mercurous chloride', 'mercuric'],
    'Hidrokuinon / Hydroquinone': ['hydroquinone', 'hidrokuinon', 'quinol', 'benzene-1,4-diol'],
    'Etilen Glikol / EG': ['ethylene glycol', 'etilen glikol', 'diethylene glycol', 'dietilen glikol'],
    'Bahan Kimia Obat (Steroid / Analgesik)': ['dexamethasone', 'deksametason', 'prednisone', 'prednison', 'paracetamol', 'parasetamol', 'phenylbutazone', 'fenilbutazon'],
    'Obat Kuat Ilegal (BKO)': ['sildenafil', 'tadalafil', 'vardenafil'],
    'Pewarna Berbahaya (Rhodamin / Metanil)': ['rhodamin b', 'rodamin b', 'metanil yellow', 'pewarna merah k.3', 'pewarna kuning k.10'],
    'Pengawet Ilegal (Formalin / Boraks)': ['formaldehyde', 'formalin', 'borax', 'boraks', 'asam salisilat', 'salicylic acid']
  };

  /// Analyzes the raw ingredients text for high-risk chemical warnings
  static List<IngredientWarning> analyze(String ingredients) {
    if (ingredients.isEmpty || ingredients == '-') return [];
    
    final List<IngredientWarning> warnings = [];
    final lowerIng = ingredients.toLowerCase();

    _dangerousKeywords.forEach((chemical, keywords) {
      for (final keyword in keywords) {
        if (lowerIng.contains(keyword)) {
          warnings.add(
            IngredientWarning(
              chemicalName: chemical,
              category: 'Zat Berbahaya',
              dangerLevel: 'BAHAYA',
              description: _getDangerDescription(chemical),
            ),
          );
          break; // Avoid duplicates for the same chemical family
        }
      }
    });

    return warnings;
  }

  static String _getDangerDescription(String chemical) {
    switch (chemical) {
      case 'Merkuri / Mercury':
        return 'Memicu kanker kulit (karsinogenik), merusak fungsi ginjal, dan memicu gangguan saraf.';
      case 'Hidrokuinon / Hydroquinone':
        return 'Penyebab utama okronosis (kulit menghitam permanen), iritasi parah, dan dermatitis akut.';
      case 'Etilen Glikol / EG':
        return 'Bahan cemaran berbahaya pada sirop yang dapat merusak fungsi ginjal secara akut.';
      case 'Bahan Kimia Obat (Steroid / Analgesik)':
        return 'Pencampuran obat keras ilegal tanpa resep dapat merusak lambung, ginjal, dan fungsi hati.';
      case 'Obat Kuat Ilegal (BKO)':
        return 'Dapat memicu gagal jantung mendadak, stroke fatal, dan penurunan drastis tekanan darah.';
      case 'Pewarna Berbahaya (Rhodamin / Metanil)':
        return 'Pewarna tekstil industri non-pangan yang merusak organ hati dan memicu tumor ganas.';
      case 'Pengawet Ilegal (Formalin / Boraks)':
        return 'Pengawet mayat/industri yang merusak saluran cerna, hati, ginjal, dan merusak imunitas.';
      default:
        return 'Bahan kimia berbahaya yang dilarang ditambahkan ke dalam produk konsumen.';
    }
  }
}
