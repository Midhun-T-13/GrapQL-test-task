import 'package:get_it/get_it.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'core/network/graphql_client.dart';
import 'features/users/data/datasources/user_remote_data_source.dart';
import 'features/users/data/repositories/user_repository_impl.dart';
import 'features/users/domain/repositories/user_repository.dart';
import 'features/users/domain/usecases/get_users.dart';
import 'features/users/presentation/cubit/user_list/user_list_cubit.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerFactory(
    () => UserListCubit(getUsersUseCase: getIt()),
  );

  getIt.registerLazySingleton(() => GetUsers(getIt()));


  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: getIt()),
  );

  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(client: getIt()),
  );

  getIt.registerLazySingleton<GraphQLClient>(() => GraphQLClientConfig.getClient());

  await initHiveForFlutter();
}
