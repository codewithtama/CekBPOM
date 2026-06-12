import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'presentation/providers/history_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Create ProviderContainer to initialize services before UI launch
  final container = ProviderContainer();
  await container.read(historyServiceProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CekBpomApp(),
    ),
  );
}
