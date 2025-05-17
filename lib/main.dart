import 'package:drawing/draw/cubit/draw_cubit.dart';
import 'package:drawing/draw/draw_screen.dart';
import 'package:drawing/home/cubit/home_cubit.dart';
import 'package:drawing/model/offset.dart';
import 'package:drawing/model/stroke.dart';
import 'package:drawing/home/home_screen.dart';
import 'package:drawing/splash/cubit/splash_cubit.dart';
import 'package:drawing/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Hive và đăng ký adapter
  await Hive.initFlutter();
  Hive.registerAdapter(OffsetCustomAdapter());
  Hive.registerAdapter(StrokeAdapter());

  // Kiểm tra và mở box chỉ khi cần
  if (!Hive.isBoxOpen('drawingBox')) {
    await Hive.openBox<Map<dynamic, dynamic>>('drawingBox');
  }

  runApp(const MyApp());
}

// ThemeData được tách ra để tái sử dụng
var kAppTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  fontFamily: 'Roboto',
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
    ),
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 22,
      color: Colors.white,
    ),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    backgroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.deepPurple,
    ),
    contentTextStyle: TextStyle(
      fontSize: 16,
      color: Colors.black87,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepPurple, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    prefixIconColor: Colors.deepPurple,
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: Colors.deepPurple,
    thumbColor: Colors.deepPurple,
    overlayColor: Colors.deepPurple.withOpacity(0.2),
  ),
  iconTheme: IconThemeData(color: Colors.deepPurple, size: 26),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.deepPurple,
      textStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => BlocProvider(
              create: (_) => SplashCubit()..startSplashAnimation(),
              child: const SplashScreen(),
            ),
        '/home': (context) => BlocProvider(
              create: (_) => HomeCubit()..loadDrawings(),
              child: const HomeScreen(),
            ),
        '/draw': (context) => BlocProvider(
              create: (_) {
                final drawingName =
                    ModalRoute.of(context)?.settings.arguments as String?;
                return DrawCubit()..initialize(drawingName);
              },
              child: const DrawScreen(),
            ),
      },
      debugShowCheckedModeBanner: false,
      title: 'Drawing App',
      theme: kAppTheme,
    );
  }
}
