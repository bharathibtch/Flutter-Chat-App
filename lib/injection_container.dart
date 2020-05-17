import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'core/utils/input_validator.dart';
import 'features/login/data/datasources/login_local_data_source.dart';
import 'features/login/data/datasources/login_remote_data_source.dart';
import 'features/login/data/repositories/login_repository_impl.dart';
import 'features/login/domain/repositories/login_repository.dart';
import 'features/login/domain/usecases/get_logged_in_user_data.dart';
import 'features/login/domain/usecases/sign_in_with_google.dart';
import 'features/login/domain/usecases/sign_out_with_google.dart';
import 'features/login/presentation/bloc/login_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> init() async {
  //! Features - UserAccout(Login)

  serviceLocator.registerFactory(
    () => LoginBloc(
      signInWithGoogle: serviceLocator(),
      signOutWithGoogle: serviceLocator(),
      getLoggedInUserData: serviceLocator(),
    ),
  );

  //Use Cases
  serviceLocator.registerLazySingleton(
    () => SignInWithGoogle(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => SignOutWithGoogle(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => GetLoggedInUserData(repository: serviceLocator()),
  );

  //Repository
  serviceLocator.registerLazySingleton<LoginRepository>(
    () => LoginRepositoryImpl(
      remoteDataSource: serviceLocator(),
      localDataSource: serviceLocator(),
      networkInfo: serviceLocator(),
    ),
  );

  //Data Sources
  serviceLocator.registerLazySingleton<LoginRemoteDataSource>(
    () => LoginRemoteDataSourceImpl(
      firebaseAuth: serviceLocator(),
      firestoreInstance: serviceLocator(),
      googleSignIn: serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton<LoginLocalDataSource>(
    () => LoginLocalDataSourceImpl(preferences: serviceLocator()),
  );

  //!Core

  //NetworInfo
  serviceLocator.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(),
  );

  serviceLocator.registerLazySingleton(() => InputValidator());

  //! External
  serviceLocator.registerLazySingleton(() => http.Client());
  serviceLocator.registerLazySingleton(() => GoogleSignIn());
  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => Firestore.instance);
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);
}