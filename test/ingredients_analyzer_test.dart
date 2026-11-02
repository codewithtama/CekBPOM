import 'package:flutter_test/flutter_test.dart';
import 'package:cekbpom/core/utils/ingredients_analyzer.dart';

void main() {
  group('IngredientsAnalyzer Detailed & Skin Safety', () {
    test('detects lethal toxic banned chemicals', () {
      const toxic = 'Aqua, Stearic Acid, Mercury, Parfum';
      final result = IngredientsAnalyzer.analyzeDetailed(toxic);

      expect(result.isSafeFromToxins, isFalse);
      expect(result.dangerousIngredients.any((w) => w.chemicalName.contains('Merkuri')), isTrue);
    });

    test('detects pregnancy and nursing risk ingredients', () {
      const pregnancyRisk = 'Aqua, Niacinamide, Retinol 1%, Glycerin';
      final result = IngredientsAnalyzer.analyzeDetailed(pregnancyRisk);

      expect(result.isPregnancySafe, isFalse);
      expect(result.pregnancyWarnings.any((w) => w.chemicalName.contains('Retinoid')), isTrue);
    });

    test('detects fungal acne (Malassezia) triggers', () {
      const fungalTrigger = 'Aqua, Polysorbate 20, Lauric Acid, Dimethicone';
      final result = IngredientsAnalyzer.analyzeDetailed(fungalTrigger);

      expect(result.isFungalAcneSafe, isFalse);
      expect(result.fungalAcneTriggers.length, greaterThanOrEqualTo(2));
    });

    test('detects fragrance allergens and drying alcohol', () {
      const sensitizer = 'Alcohol Denat, Fragrance, Limonene, Aqua';
      final result = IngredientsAnalyzer.analyzeDetailed(sensitizer);

      expect(result.isSensitiveSkinSafe, isFalse);
      expect(result.allergenAndSensitivities.any((w) => w.chemicalName.contains('Pewangi')), isTrue);
      expect(result.allergenAndSensitivities.any((w) => w.chemicalName.contains('Alcohol')), isTrue);
    });

    test('detects cross-product conflicts between Retinol and AHA/BHA', () {
      const prodA = 'Aqua, Retinol 0.5%, Squalane';
      const prodB = 'Aqua, Glycolic Acid 7%, Centella Asiatica';

      final conflicts = IngredientsAnalyzer.checkCrossProductConflicts(prodA, prodB);

      expect(conflicts.isNotEmpty, isTrue);
      expect(conflicts.any((c) => c.title.contains('Eksfoliasi Berlebih')), isTrue);
      expect(conflicts.first.severity, 'TINGGI');
    });

    test('detects cross-product conflicts between Retinol and Pure Vitamin C', () {
      const prodA = 'Aqua, Tretinoin 0.05%';
      const prodB = 'Aqua, L-Ascorbic Acid 15%, Ferulic Acid';

      final conflicts = IngredientsAnalyzer.checkCrossProductConflicts(prodA, prodB);

      expect(conflicts.isNotEmpty, isTrue);
      expect(conflicts.any((c) => c.title.contains('Ketidakcocokan pH')), isTrue);
    });

    test('returns empty conflicts when products are safe together', () {
      const prodA = 'Aqua, Hyaluronic Acid, Ceramide NP';
      const prodB = 'Aqua, Centella Asiatica, Panthenol';

      final conflicts = IngredientsAnalyzer.checkCrossProductConflicts(prodA, prodB);

      expect(conflicts.isEmpty, isTrue);
    });
  });
}

