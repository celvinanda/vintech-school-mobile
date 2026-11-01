import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/update/ota_update_service.dart';
import 'features/academic/data/academic_repository.dart';
import 'features/academic/logic/attendance_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/billing/data/billing_repository.dart';
import 'features/billing/logic/billing_cubit.dart';
import 'features/home/data/home_repository.dart';
import 'features/home/logic/home_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Global Crash & Telemetry Error Handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[GLOBAL ERROR] FlutterError: ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[GLOBAL ERROR] PlatformDispatcher uncaught: $error');
    return true;
  };

  // 2. Sinkronisasi warna Bar Notifikasi (Status Bar) dengan Top Bar Aplikasi
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Color(0xFFECEEF0),
    ),
  );

  // 3. Initialize Local Storage (Hive Multi-Box & SharedPreferences)
  final storage = await LocalStorage.init();

  // 4. Initialize Shorebird OTA Code Push Engine di latar belakang (Non-Blocking Startup)
  final otaUpdateService = OtaUpdateService();
  unawaited(
    otaUpdateService.initialize().catchError((e) {
      debugPrint('[OTA] Error initializing Shorebird: $e');
    }),
  );

  // 5. Initialize Network & Repositories (Offline-First with Hive + Cloud API)
  final apiClient = ApiClient(storage);
  final authRepository = AuthRepository(apiClient, storage);
  final homeRepository = HomeRepository(apiClient, storage);
  final academicRepository = AcademicRepository(apiClient, storage);
  final billingRepository = BillingRepository(apiClient, storage);

  runApp(
    VintechSchoolApp(
      storage: storage,
      otaUpdateService: otaUpdateService,
      authRepository: authRepository,
      homeRepository: homeRepository,
      academicRepository: academicRepository,
      billingRepository: billingRepository,
    ),
  );
}

class VintechSchoolApp extends StatelessWidget {
  final LocalStorage storage;
  final OtaUpdateService otaUpdateService;
  final AuthRepository authRepository;
  final HomeRepository homeRepository;
  final AcademicRepository academicRepository;
  final BillingRepository billingRepository;

  const VintechSchoolApp({
    super.key,
    required this.storage,
    required this.otaUpdateService,
    required this.authRepository,
    required this.homeRepository,
    required this.academicRepository,
    required this.billingRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalStorage>.value(value: storage),
        RepositoryProvider<OtaUpdateService>.value(value: otaUpdateService),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<HomeRepository>.value(value: homeRepository),
        RepositoryProvider<AcademicRepository>.value(value: academicRepository),
        RepositoryProvider<BillingRepository>.value(value: billingRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(authRepository, storage),
          ),
          BlocProvider<HomeCubit>(
            create: (context) => HomeCubit(homeRepository),
          ),
          BlocProvider<AttendanceCubit>(
            create: (context) => AttendanceCubit(academicRepository),
          ),
          BlocProvider<BillingCubit>(
            create: (context) => BillingCubit(billingRepository),
          ),
        ],
        child: MaterialApp(
          title: 'Vintech School',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(),
          scrollBehavior: const AppScrollBehavior(),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

/// ScrollBehavior yang dioptimalkan untuk performa tinggi di Safari, iOS, dan Web:
/// 1. Mengaktifkan drag gesture untuk semua input device (touch, mouse, trackpad, stylus)
/// 2. Menggunakan BouncingScrollPhysics yang responsif tanpa lag
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}
