import 'package:flutter/material.dart';
import 'package:kasir/pages/PrinterSettingPage.dart'; 
import 'package:kasir/pages/barang_page.dart';
import 'package:kasir/pages/home_page.dart';
import 'package:kasir/pages/login_page.dart';
import 'package:kasir/pages/riwayat_transaksi.dart';
import 'package:kasir/pages/splash_page.dart';
import 'package:kasir/provider/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kasir/provider/PrinterProvider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('dataBox');

  // Inisialisasi locale Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrinterProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    )
  );
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashPage(),
      routes: {
        '/login': (context) => LoginWidget(),
        '/home': (context) => Homepage(),
        '/data-barang': (context) => BarangPage(),
        '/riwayat': (context) => RiwayatTransaksi(),
        '/printer': (_) => const PrinterSettingPage(),
      },
    );
  }
}

