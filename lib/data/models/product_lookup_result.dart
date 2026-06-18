import 'product_model.dart';

class ProductLookupResult {
  final ProductModel product;
  final String sourceLabel;

  const ProductLookupResult({
    required this.product,
    required this.sourceLabel,
  });
}