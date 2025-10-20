// Repositories
import 'package:clean_architecture/data/repositories/auth_repository_impl.dart';
import 'package:clean_architecture/domain/repositories/auth_repository.dart';
import 'package:clean_architecture/domain/usecases/get_current_user.dart';
import 'package:clean_architecture/domain/usecases/reset_password.dart';
// Use cases
import 'package:clean_architecture/domain/usecases/sign_in.dart';
import 'package:clean_architecture/domain/usecases/sign_out.dart';
import 'package:clean_architecture/domain/usecases/sign_up.dart';
// Bloc
import 'package:clean_architecture/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> initInjection() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // Register Supabase client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  
  // Use cases
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      resetPassword: sl(),
    ),
  );
}


