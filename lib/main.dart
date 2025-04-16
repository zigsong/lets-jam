import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

Future<void> main() async {
  /** splash screen 시간 */
  await Future.delayed(const Duration(milliseconds: 1000));

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  KakaoSdk.init(
    nativeAppKey: dotenv.get("KAKAO_NATIVE_APP_KEY"),
    javaScriptAppKey: dotenv.get("KAKAO_JAVASCRIPT_APP_KEY"),
  );

  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      authOptions:
          const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce));

  /** ExploreFilterController도 이곳에서 initialize하기 */
  Get.put(SessionController());

  runApp(const GetMaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // NOTE: 디바이스의 설정과 무관하게 폰트 사이즈를 고정시킴
      builder: (context, child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Pretendard',
          colorScheme:
              ColorScheme.fromSeed(seedColor: const Color(0xffFC784F))),
      initialRoute: '/',
      routes: {
        '/': (context) => const DefaultNavigation(),
        // '/second': (context) => SecondScreen(),
        // '/third': (context) => ThirdScreen(),
      },
    );
  }
}
