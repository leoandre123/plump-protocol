import 'package:flutter/material.dart';
import 'package:plumpen_app/framework/game_theme.dart';
import 'package:plumpen_app/screens/game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<StatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final ValueNotifier<ThemeMode> _themeModeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  @override
  Widget build(BuildContext context) {
    var darkTheme = ThemeData.dark().copyWith(
      //textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Inter'),
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: Color.fromARGB(255, 76, 97, 75),
      ),
      scaffoldBackgroundColor: const Color.fromARGB(255, 43, 38, 34),
      brightness: Brightness.dark,
      extensions: [
        GameTheme(
          tableHeaderBackground: Color(0xff384234),
          tableHeaderForeground: Color(0xffdddddd),
          tableBackground: Color(0xff2e2e35),
          tableForeground: Color(0xffdddddd),
          tableActiveBackground: Color.fromARGB(255, 43, 65, 35),
          tableActiveForeground: Colors.black,
          tableHeaderBorder: Color.fromARGB(255, 47, 55, 44),
          tableBorder: Color(0xff282828),
        ),
      ],
    );

    var lightTheme = ThemeData.light().copyWith(
      //textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Inter'),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF8B8C6F),
      ).copyWith(surface: Color(0xFF3A3B3C)),
      scaffoldBackgroundColor: const Color(0xff6A5A4E),
      brightness: Brightness.light,
      extensions: [
        GameTheme(
          tableHeaderBackground: Color(0xFF8B8C6F),
          tableHeaderForeground: Color(0xFFF3E6D2),
          tableBackground: Colors.white,
          tableForeground: Colors.black,
          tableActiveBackground: Colors.green.shade100,
          tableActiveForeground: Colors.black,
          tableHeaderBorder: Color.fromARGB(255, 124, 125, 98),
          tableBorder: Color(0xffdddddd),
        ),
      ],
    );

    return ValueListenableBuilder(
      valueListenable: _themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          //debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: _themeModeNotifier.value,
          home: GamePage(
            onThemeChanged: (newMode) {
              _themeModeNotifier.value = newMode;
            },
          ),
        );
      },
    );
  }
}
