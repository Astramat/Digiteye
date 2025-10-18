import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';

/// Service locator global pour l'injection de dépendances
final GetIt sl = GetIt.instance;

/// Configuration des services et dépendances
Future<void> setupServiceLocator() async {
  // Services externes
  sl.registerLazySingleton<http.Client>(() => http.Client());
  
  // Services réseau
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(
    baseUrl: 'https://api.example.com', // À remplacer par votre URL
  ));
  
  // Services de stockage
  sl.registerLazySingleton<LocalStorage>(() => LocalStorage());
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage.instance);
  
  // Initialisation des services asynchrones
  await LocalStorage.getInstance();
  
  // Services métier - Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
    apiClient: sl(),
  ));
  
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(
    localStorage: sl(),
    secureStorage: sl(),
  ));
  
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
    networkInfo: sl(),
  ));
  
  // Use cases - Auth
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl()));
}

/// Nettoyage des services (utile pour les tests)
Future<void> resetServiceLocator() async {
  await sl.reset();
}
