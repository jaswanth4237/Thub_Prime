import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screens/course/course_detail_page.dart';
import 'package:frontend/providers/course_detail_provider.dart';

export 'package:frontend/screens/mentorScreen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thub Prime',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,  
      ),
      home: const CourseDetailPage(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    DevicePreview(
      enabled: kIsWeb ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<CourseDetailProvider>(
            create: (_) => CourseDetailProvider(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}