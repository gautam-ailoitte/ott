import 'package:get_it/get_it.dart';
import 'package:ott/src/data/datasources/mock_video_datasource.dart';
import 'package:ott/src/data/datasources/user_datasource.dart';
import 'package:ott/src/data/repositories/video_repository_impl.dart';
import 'package:ott/src/domain/repositories/video_repository.dart';
import 'package:ott/src/presentation/cubits/home_cubit/home_cubit.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies for OTT app
Future<void> init() async {
  //===== Core Dependencies =====
  // Data Sources
  sl.registerLazySingleton<MockVideoDataSource>(() => MockVideoDataSource());
  sl.registerLazySingleton<UserDataSource>(() => UserDataSource());

  //===== Repositories =====
  sl.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(sl<MockVideoDataSource>(), sl<UserDataSource>()),
  );

  //===== Cubits (Factory registration for multiple instances) =====
  sl.registerFactory(() => HomeCubit(sl<VideoRepository>()));

  //===== Future: Services (when needed) =====
  // sl.registerLazySingleton<VideoLifecycleService>(() => VideoLifecycleService());
  // sl.registerLazySingleton<AppLifecycleService>(() => AppLifecycleService());
}

/// Clear all dependencies
Future<void> resetDependencies() async {
  await sl.reset();
}
