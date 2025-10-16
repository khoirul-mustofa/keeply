import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:keeply/models/note.dart';
import 'package:keeply/pages/editor_page.dart';
import 'package:keeply/pages/home_page.dart';
import 'package:keeply/pages/keep_search_page.dart';
import 'package:keeply/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Init Hive
  await Hive.initFlutter();

  // Register adapter
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(NoteContentAdapter());

  // Buka box sebelum app dijalankan
  await HiveService().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Keep',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          contentTextStyle: TextStyle(color: Colors.black87, fontSize: 15),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/editor': (context) => const EditorPage(),
        '/search': (context) => const KeepSearchPage(),
      },
    );
  }
}
