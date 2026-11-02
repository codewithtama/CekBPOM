class IngredientWarning {
  final String chemicalName;
  final String category;
  final String dangerLevel; // 'BAHAYA', 'PERINGATAN', 'HINDARI BUMIL', 'FUNGAL ACNE'
  final String description;

  const IngredientWarning({
    required this.chemicalName,
    required this.category,
    required this.dangerLevel,
    required this.description,
  });
}

class SkincareConflict {
  final String itemA;
  final String itemB;
  final String severity; // 'TINGGI' or 'SEDANG'
  final String title;
  final String description;
  final String recommendation;

  const SkincareConflict({
    required this.itemA,
    required this.itemB,
    required this.severity,
    required this.title,
    required this.description,
    required this.recommendation,
  });
}

class IngredientAnalysisResult {
  final List<IngredientWarning> dangerousIngredients;
  final List<IngredientWarning> pregnancyWarnings;
  final List<IngredientWarning> fungalAcneTriggers;
  final List<IngredientWarning> allergenAndSensitivities;
  final List<SkincareConflict> internalConflicts;

  const IngredientAnalysisResult({
    required this.dangerousIngredients,
    required this.pregnancyWarnings,
    required this.fungalAcneTriggers,
    required this.allergenAndSensitivities,
    required this.internalConflicts,
  });

  bool get isSafeFromToxins => dangerousIngredients.isEmpty;
  bool get isPregnancySafe => pregnancyWarnings.isEmpty;
  bool get isFungalAcneSafe => fungalAcneTriggers.isEmpty;
  bool get isSensitiveSkinSafe => allergenAndSensitivities.isEmpty;
  bool get hasConflicts => internalConflicts.isNotEmpty;
  int get totalWarnings =>
      dangerousIngredients.length +
      pregnancyWarnings.length +
      fungalAcneTriggers.length +
      allergenAndSensitivities.length;
}

class IngredientsAnalyzer {
  IngredientsAnalyzer._();

  // 1. ZAT ILEGAL & RACUN BERBAHAYA
  static final Map<String, List<String>> _dangerousKeywords = {
    'Merkuri / Mercury': ['mercury', 'merkuri', 'calomel', 'mercurous chloride', 'mercuric'],
    'Hidrokuinon / Hydroquinone': ['hydroquinone', 'hidrokuinon', 'quinol', 'benzene-1,4-diol'],
    'Etilen Glikol / EG': ['ethylene glycol', 'etilen glikol', 'diethylene glycol', 'dietilen glikol'],
    'Bahan Kimia Obat (Steroid / Analgesik)': [
      'dexamethasone',
      'deksametason',
      'prednisone',
      'prednison',
      'paracetamol',
      'parasetamol',
      'phenylbutazone',
      'fenilbutazon'
    ],
    'Obat Kuat Ilegal (BKO)': ['sildenafil', 'tadalafil', 'vardenafil'],
    'Pewarna Berbahaya (Rhodamin / Metanil)': [
      'rhodamin b',
      'rodamin b',
      'metanil yellow',
      'pewarna merah k.3',
      'pewarna kuning k.10'
    ],
    'Pengawet Ilegal (Formalin / Boraks)': [
      'formaldehyde',
      'formalin',
      'borax',
      'boraks'
    ],
  };

  // 2. KEAMANAN IBU HAMIL & MENYUSUI (Pregnancy Risk)
  static final Map<String, List<String>> _pregnancyRiskKeywords = {
    'Retinoid / Vitamin A Derivatif': [
      'retinol',
      'retinal',
      'retinaldehyde',
      'retinoic acid',
      'tretinoin',
      'adapalene',
      'tazarotene',
      'isotretinoin',
      'retinyl palmitate',
      'retinyl acetate'
    ],
    'Salicylic Acid Dosis Tinggi (>2%)': ['salicylic acid', 'asam salisilat', 'betaine salicylate'],
    'Arbutin / Hydroquinone': ['hydroquinone', 'arbutin', 'alpha arbutin', 'alpha-arbutin'],
    'Tabir Surya Kimiawi Tertentu': ['oxybenzone', 'benzophenone-3', 'octinoxate'],
    'Benzoyl Peroxide Konsentrasi Tinggi': ['benzoyl peroxide', 'benzoil peroksida'],
  };

  // 3. PEMICU FUNGAL ACNE (Malassezia folliculitis)
  static final Map<String, List<String>> _fungalAcneKeywords = {
    'Polysorbate': ['polysorbate 20', 'polysorbate 40', 'polysorbate 60', 'polysorbate 80'],
    'Asam Lemak Pemicu Jamur (Fatty Acids)': [
      'lauric acid',
      'myristic acid',
      'palmitic acid',
      'stearic acid',
      'oleic acid'
    ],
    'Esters Lemak': [
      'isopropyl myristate',
      'isopropyl palmitate',
      'ethylhexyl palmitate',
      'glyceryl stearate',
      'peg-100 stearate'
    ],
    'Minyak Alami Kaya Asam Lemak': [
      'coconut oil',
      'olive oil',
      'avocado oil',
      'shea butter',
      'cocoa butter'
    ],
  };

  // 4. KULIT SENSITIF & ALERGEN
  static final Map<String, List<String>> _sensitivityKeywords = {
    'Pewangi Buatan (Fragrance / Parfum)': ['fragrance', 'parfum', 'perfume', 'aroma'],
    'Minyak Atsiri Alergenik (Essential Oils)': [
      'limonene',
      'linalool',
      'citronellol',
      'eugenol',
      'geraniol',
      'citral',
      'lavender oil',
      'tea tree oil'
    ],
    'Drying Alcohol (Alkohol Mengeringkan)': [
      'alcohol denat',
      'denatured alcohol',
      'sd alcohol',
      'isopropyl alcohol',
      'ethanol'
    ],
    'Harsh Sulfates (Surfaktan Keras)': ['sodium lauryl sulfate', 'sls', 'ammonium lauryl sulfate'],
  };

  /// Backward-compatible quick check for lethal poisons
  static List<IngredientWarning> analyze(String ingredients) {
    return analyzeDetailed(ingredients).dangerousIngredients;
  }

  /// Comprehensive multi-factor analysis
  static IngredientAnalysisResult analyzeDetailed(String ingredients) {
    if (ingredients.isEmpty || ingredients == '-') {
      return const IngredientAnalysisResult(
        dangerousIngredients: [],
        pregnancyWarnings: [],
        fungalAcneTriggers: [],
        allergenAndSensitivities: [],
        internalConflicts: [],
      );
    }

    final lower = ingredients.toLowerCase();

    // 1. Toxin check
    final dangerous = _matchKeywords(
      lower,
      _dangerousKeywords,
      category: 'Zat Berbahaya',
      dangerLevel: 'BAHAYA',
      descProvider: _getDangerDescription,
    );

    // 2. Pregnancy check
    final pregnancy = _matchKeywords(
      lower,
      _pregnancyRiskKeywords,
      category: 'Keamanan Kehamilan',
      dangerLevel: 'HINDARI BUMIL',
      descProvider: _getPregnancyDescription,
    );

    // 3. Fungal acne check
    final fungalAcne = _matchKeywords(
      lower,
      _fungalAcneKeywords,
      category: 'Fungal Acne',
      dangerLevel: 'PICU FUNGAL ACNE',
      descProvider: _getFungalAcneDescription,
    );

    // 4. Sensitivity & Allergens
    final sensitivity = _matchKeywords(
      lower,
      _sensitivityKeywords,
      category: 'Kulit Sensitif',
      dangerLevel: 'PERINGATAN ALERGEN',
      descProvider: _getSensitivityDescription,
    );

    // 5. Check conflicts within this single formulation
    final internalConflicts = _detectConflicts(lower, lower);

    return IngredientAnalysisResult(
      dangerousIngredients: dangerous,
      pregnancyWarnings: pregnancy,
      fungalAcneTriggers: fungalAcne,
      allergenAndSensitivities: sensitivity,
      internalConflicts: internalConflicts,
    );
  }

  /// Cross-product interaction & conflict checker (for comparing 2 products)
  static List<SkincareConflict> checkCrossProductConflicts(String ingA, String ingB) {
    if (ingA.isEmpty || ingB.isEmpty || ingA == '-' || ingB == '-') return [];
    return _detectConflicts(ingA.toLowerCase(), ingB.toLowerCase());
  }

  static List<SkincareConflict> _detectConflicts(String textA, String textB) {
    final List<SkincareConflict> conflicts = [];

    final hasRetinoidA = _containsAny(textA, ['retinol', 'retinal', 'tretinoin', 'adapalene', 'retinoid']);
    final hasRetinoidB = _containsAny(textB, ['retinol', 'retinal', 'tretinoin', 'adapalene', 'retinoid']);

    final hasAhaBhaA = _containsAny(textA, ['glycolic acid', 'lactic acid', 'salicylic acid', 'mandelic acid', 'aha', 'bha']);
    final hasAhaBhaB = _containsAny(textB, ['glycolic acid', 'lactic acid', 'salicylic acid', 'mandelic acid', 'aha', 'bha']);

    final hasVitCA = _containsAny(textA, ['ascorbic acid', 'l-ascorbic acid', 'vitamin c']);
    final hasVitCB = _containsAny(textB, ['ascorbic acid', 'l-ascorbic acid', 'vitamin c']);

    final hasBenzoylA = _containsAny(textA, ['benzoyl peroxide', 'benzoil peroksida']);
    final hasBenzoylB = _containsAny(textB, ['benzoyl peroxide', 'benzoil peroksida']);

    final hasPeptideA = _containsAny(textA, ['copper peptide', 'palmitoyl tripeptide', 'matrixyl', 'oligopeptide']);
    final hasPeptideB = _containsAny(textB, ['copper peptide', 'palmitoyl tripeptide', 'matrixyl', 'oligopeptide']);

    // Conflict 1: Retinoid + AHA/BHA
    if ((hasRetinoidA && hasAhaBhaB) || (hasRetinoidB && hasAhaBhaA) || (textA == textB && hasRetinoidA && hasAhaBhaA)) {
      conflicts.add(
        const SkincareConflict(
          itemA: 'Retinol / Retinoid',
          itemB: 'AHA / BHA (Exfoliating Acids)',
          severity: 'TINGGI',
          title: 'Eksfoliasi Berlebih & Rusak Skin Barrier',
          description:
              'Menggabungkan Retinoid dengan asam eksfoliasi (AHA/BHA) dapat mengikis lapisan pelindung kulit, memicu iritasi berat, sensasi terbakar, dan kemerahan parah.',
          recommendation:
              'Gunakan di waktu berbeda: gunakan metode Skin Cycling (berselang hari), atau aplikasikan AHA/BHA di pagi hari dan Retinol di malam hari.',
        ),
      );
    }

    // Conflict 2: Retinoid + Pure Vitamin C
    if ((hasRetinoidA && hasVitCB) || (hasRetinoidB && hasVitCA) || (textA == textB && hasRetinoidA && hasVitCA)) {
      conflicts.add(
        const SkincareConflict(
          itemA: 'Retinol',
          itemB: 'Pure Vitamin C (L-Ascorbic Acid)',
          severity: 'TINGGI',
          title: 'Ketidakcocokan pH & Risiko Iritasi',
          description:
              'Vitamin C murni membutuhkan lingkungan asam (pH <3.5) agar stabil, sedangkan Retinol bekerja optimal pada pH 5.5–6.0. Penggunaan bersamaan dapat menonaktifkan manfaatnya dan memicu dermatitis.',
          recommendation:
              'Gunakan Vitamin C di pagi hari bersama sunscreen untuk menangkal radikal bebas, dan aplikasikan Retinol hanya pada malam hari.',
        ),
      );
    }

    // Conflict 3: Benzoyl Peroxide + Retinoid
    if ((hasBenzoylA && hasRetinoidB) || (hasBenzoylB && hasRetinoidA) || (textA == textB && hasBenzoylA && hasRetinoidA)) {
      conflicts.add(
        const SkincareConflict(
          itemA: 'Benzoyl Peroxide',
          itemB: 'Retinoid',
          severity: 'TINGGI',
          title: 'Netralisasi Formulasi & Dehidrasi Akut',
          description:
              'Benzoyl Peroxide adalah zat pengoksidasi kuat yang dapat mendegradasi molekul Retinol, membuatnya tidak aktif sekaligus mengeringkan kulit secara berlebihan.',
          recommendation:
              'Gunakan Benzoyl Peroxide di pagi hari untuk obat totol jerawat, dan Retinol di malam hari.',
        ),
      );
    }

    // Conflict 4: Copper Peptides + Direct Acids / Vitamin C
    if ((hasPeptideA && (hasAhaBhaB || hasVitCB)) || (hasPeptideB && (hasAhaBhaA || hasVitCA)) ||
        (textA == textB && hasPeptideA && (hasAhaBhaA || hasVitCA))) {
      conflicts.add(
        const SkincareConflict(
          itemA: 'Copper Peptides',
          itemB: 'Direct Acids / Vitamin C',
          severity: 'SEDANG',
          title: 'Degradasi Rantai Peptida',
          description:
              'Asam dengan konsentrasi tinggi dapat memutus ikatan peptida tembaga sehingga kehilangan kemampuan regenerasi kolagen dan anti-aging.',
          recommendation:
              'Gunakan serum peptida pada rutinitas malam pemulihan barrier, terpisah dari hari pemakaian eksfoliasi atau serum asam.',
        ),
      );
    }

    return conflicts;
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (final kw in keywords) {
      if (text.contains(kw)) return true;
    }
    return false;
  }

  static List<IngredientWarning> _matchKeywords(
    String lowerText,
    Map<String, List<String>> dict, {
    required String category,
    required String dangerLevel,
    required String Function(String key) descProvider,
  }) {
    final List<IngredientWarning> list = [];
    dict.forEach((title, keywords) {
      for (final kw in keywords) {
        if (lowerText.contains(kw)) {
          list.add(
            IngredientWarning(
              chemicalName: title,
              category: category,
              dangerLevel: dangerLevel,
              description: descProvider(title),
            ),
          );
          break;
        }
      }
    });
    return list;
  }

  static String _getDangerDescription(String chemical) {
    switch (chemical) {
      case 'Merkuri / Mercury':
        return 'Memicu kanker kulit (karsinogenik), merusak fungsi ginjal, dan memicu gangguan saraf permanen.';
      case 'Hidrokuinon / Hydroquinone':
        return 'Penyebab okronosis (kulit menghitam lebam permanen), iritasi parah, dan dermatitis akut.';
      case 'Etilen Glikol / EG':
        return 'Cemaran pelarut berbahaya yang dapat memicu gagal ginjal akut pada anak dan dewasa.';
      case 'Bahan Kimia Obat (Steroid / Analgesik)':
        return 'Pencampuran steroid/analgesik ilegal tanpa resep dapat merusak lambung, osteoporosis, dan kelainan organ.';
      case 'Obat Kuat Ilegal (BKO)':
        return 'Memicu serangan jantung mendadak, stroke fatal, dan hipotensi drastis.';
      case 'Pewarna Berbahaya (Rhodamin / Metanil)':
        return 'Pewarna tekstil industri non-pangan yang bersifat karsinogenik dan merusak fungsi hati.';
      case 'Pengawet Ilegal (Formalin / Boraks)':
        return 'Pengawet industri/mayat yang merusak saluran cerna, hati, ginjal, dan mematikan jaringan sel.';
      default:
        return 'Zat berbahaya yang dilarang keras oleh regulasi BPOM RI.';
    }
  }

  static String _getPregnancyDescription(String chemical) {
    switch (chemical) {
      case 'Retinoid / Vitamin A Derivatif':
        return 'Tinggi risiko teratogenik (cacat janin bawaan). Sangat disarankan dihindari oleh ibu hamil dan menyusui.';
      case 'Salicylic Acid Dosis Tinggi (>2%)':
        return 'Penggunaan asam salisilat konsentrasi tinggi dapat diserap ke sirkulasi darah sistemik dan berisiko bagi janin.';
      case 'Arbutin / Hydroquinone':
        return 'Tingkat penyerapan dermal yang tinggi dan risiko sitotoksik membuatnya tidak dianjurkan selama masa kehamilan.';
      case 'Tabir Surya Kimiawi Tertentu':
        return 'Bahan seperti Oxybenzone berpotensi mengganggu sistem hormon endokrin janin. Lebih disarankan menggunakan Mineral Sunscreen (Zinc Oxide/Titanium Dioxide).';
      case 'Benzoyl Peroxide Konsentrasi Tinggi':
        return 'Dapat diserap secara sistemik dalam jumlah kecil. Dianjurkan konsultasi ke dokter kandungan sebelum penggunaan.';
      default:
        return 'Sebaiknya dihindari atau dikonsultasikan terlebih dahulu dengan dokter spesialis obstetri & ginekologi.';
    }
  }

  static String _getFungalAcneDescription(String chemical) {
    switch (chemical) {
      case 'Polysorbate':
        return 'Mengandung rantai asam lemak yang merupakan sumber nutrisi utama bagi perkembangbiakan ragi Malassezia di pori-pori.';
      case 'Asam Lemak Pemicu Jamur (Fatty Acids)':
        return 'Asam lemak rantai C11-C24 memberi makan koloni jamur Malassezia, memicu bruntusan gatal pada dahi dan pipi.';
      case 'Esters Lemak':
        return 'Kombinasi asam lemak dan alkohol ester yang mudah dipecah oleh enzim lipase jamur Malassezia.';
      case 'Minyak Alami Kaya Asam Lemak':
        return 'Minyak alami kaya trigliserida memperparah infeksi ragi Malassezia pada tipe kulit berjerawat jamur.';
      default:
        return 'Bahan pemicu yang memperparah kondisi Fungal Acne (Malassezia Folliculitis).';
    }
  }

  static String _getSensitivityDescription(String chemical) {
    switch (chemical) {
      case 'Pewangi Buatan (Fragrance / Parfum)':
        return 'Penyebab nomor satu dermatitis kontak alergi, rasa perih, dan kemerahan pada skin barrier sensitif.';
      case 'Minyak Atsiri Alergenik (Essential Oils)':
        return 'Meskipun alami, senyawa aromatik seperti Limonene dan Linalool sangat mudah teroksidasi dan memicu iritasi kulit.';
      case 'Drying Alcohol (Alkohol Mengeringkan)':
        return 'Dapat melarutkan lipid pelindung alami kulit, menyebabkan dehidrasi, sensasi kulit tertarik, dan kerusakan barrier.';
      case 'Harsh Sulfates (Surfaktan Keras)':
        return 'Membersihkan secara terlalu agresif, menghilangkan minyak alami, dan membuat kulit kering mengelupas.';
      default:
        return 'Bahan yang berpotensi memicu sensitisasi atau iritasi pada kulit sensitif.';
    }
  }
}
