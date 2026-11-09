import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_jam/controllers/notification_controller.dart';
import 'package:lets_jam/controllers/push_notification_controller.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/firebase_options.dart';
import 'package:lets_jam/screens/default_navigation.dart';
import 'package:lets_jam/screens/post_detail_screen/post_detail_screen.dart';
import 'package:lets_jam/screens/profile_screen/profile_screen.dart';
import 'package:lets_jam/screens/splash_screen.dart';
import 'package:lets_jam/utils/analytics.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: navigatorKey,
  observers: [routeObserver, Analytics.observer],
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DefaultNavigation(),
    ),
    GoRoute(
      path: '/profiles/:profileId',
      builder: (context, state) {
        final profileId = state.pathParameters['profileId'];
        return ProfileScreen(profileId: profileId!);
      },
    ),
    // 푸쉬 알림 탭 → 게시글 상세. userId(작성자)는 쿼리 파라미터 uid로 전달.
    GoRoute(
      path: '/posts/:postId',
      builder: (context, state) {
        final postId = state.pathParameters['postId']!;
        final userId = state.uri.queryParameters['uid'] ?? '';
        return PostDetailScreen(postId: postId, userId: userId);
      },
    ),
  ],
);

/// 백그라운드/종료 상태에서 푸쉬 수신 시 호출되는 top-level 핸들러.
/// notification 페이로드는 OS가 자동으로 표시하므로 별도 작업은 없다.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await dotenv.load(fileName: ".env");

  KakaoSdk.init(
    nativeAppKey: dotenv.get("KAKAO_NATIVE_APP_KEY"),
    javaScriptAppKey: dotenv.get("KAKAO_JAVASCRIPT_APP_KEY"),
  );

  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ));

  /** ExploreFilterController도 이곳에서 initialize하기 */
  Get.put(SessionController());
  Get.put(NotificationController());
  Get.put(PushNotificationController());

  runApp(const GetMaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  bool _splashDone = false;

  /// 스플래시 도중 들어온 딥링크를 보관했다가 라우터 준비 후 이동
  String? _pendingLocation;

  /// 스플래시 도중 탭한 푸쉬의 이동 경로를 보관했다가 라우터 준비 후 이동
  String? _pendingPushLocation;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _splashDone = true);
      final pending = _pendingLocation;
      if (pending != null) {
        _pendingLocation = null;
        appRouter.go(pending);
      }
      final pendingPush = _pendingPushLocation;
      if (pendingPush != null) {
        _pendingPushLocation = null;
        appRouter.push(pendingPush);
      }
    });

    // 앱이 실행 중일 때 들어오는 링크
    _appLinks.uriLinkStream.listen(_handleUri);
    // 앱이 꺼진 상태에서 링크로 실행된 경우(콜드 스타트)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleUri(uri);
    });

    _initPushHandlers();
  }

  /// 푸쉬 알림 수신/탭 처리
  void _initPushHandlers() {
    // 포그라운드 수신: 인앱 알림 벨을 갱신한다. (배너는 OS가 표시)
    FirebaseMessaging.onMessage.listen((_) {
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().fetchNotifications();
      }
    });
    // 백그라운드 상태에서 푸쉬를 탭해 돌아온 경우
    FirebaseMessaging.onMessageOpenedApp.listen(_handlePushTap);
    // 종료 상태에서 푸쉬 탭으로 앱이 실행된 경우(콜드 스타트)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _handlePushTap(message);
    });
  }

  /// 푸쉬 탭 → 해당 게시글 상세로 이동
  void _handlePushTap(RemoteMessage message) {
    final postId = message.data['post_id'];
    if (postId == null || postId.isEmpty) return;
    final userId = message.data['post_user_id'] ?? '';
    final location = '/posts/$postId?uid=$userId';
    if (_splashDone) {
      appRouter.push(location);
    } else {
      // 라우터가 아직 안 떴으면 스플래시 종료 후 이동하도록 보관
      _pendingPushLocation = location;
    }
  }

  Future<void> _handleUri(Uri uri) async {
    // 카카오/Supabase 로그인 콜백
    if (uri.host == 'login-callback') {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      return;
    }

    // 프로필 딥링크 → 프로필 화면
    // - Universal Link: https://letsjam.work/profiles/{id}
    //     scheme=https, host=letsjam.work, pathSegments=[profiles, {id}]
    // - Custom Scheme: letsjam://profiles/{id} (카톡 등 인앱 브라우저 대응)
    //     scheme=letsjam, host=profiles, pathSegments=[{id}]
    String? profileId;
    if (uri.host == 'letsjam.work' &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'profiles') {
      profileId = uri.pathSegments[1];
    } else if (uri.scheme == 'letsjam' &&
        uri.host == 'profiles' &&
        uri.pathSegments.isNotEmpty) {
      profileId = uri.pathSegments[0];
    }

    if (profileId != null) {
      final location = '/profiles/$profileId';
      if (_splashDone) {
        appRouter.go(location);
      } else {
        // 라우터가 아직 안 떴으면 스플래시 종료 후 이동하도록 보관
        _pendingLocation = location;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return const MaterialApp(home: SplashScreen());
    }

    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'JAM',

      // NOTE: 디바이스의 설정과 무관하게 폰트 사이즈를 고정시킴
      builder: (context, child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
      theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Pretendard',
          colorScheme:
              ColorScheme.fromSeed(seedColor: ColorSeed.boldOrangeMedium.color)
                  .copyWith(
            surface: Colors.white,
            surfaceTint: Colors.transparent,
          ),
          // MARK: 버튼 높이 맞추기
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )),
    );
  }
}
