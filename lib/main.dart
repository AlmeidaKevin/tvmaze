import 'package:flutter/material.dart';
import 'services/mongo_service.dart';
import 'screens/home_page.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoService.connect();
  runApp(const SeriesVaultApp());
}

class SeriesVaultApp extends StatelessWidget {
  const SeriesVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeriesVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomePage(),
    );
  }
}
