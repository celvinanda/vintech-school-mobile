import 'package:flutter/material.dart';
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

  // Initialize Local Storage (Hive Multi-Box & SharedPreferences)
  final storage = await LocalStorage.init();

  // Initialize Shorebird OTA Code Push Engine
  final otaUpdateService = OtaUpdateService();
  await otaUpdateService.initialize();

  // Initialize Network & Repositories (Offline-First with Hive + Cloud API)
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
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
