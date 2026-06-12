import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/news_model.dart';
import 'scan_provider.dart';

final newsProvider = FutureProvider<List<NewsModel>>((ref) async {
  final repository = ref.watch(bpomRepositoryProvider);
  return repository.fetchNews();
});
