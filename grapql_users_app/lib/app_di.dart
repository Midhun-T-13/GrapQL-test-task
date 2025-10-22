import 'package:get_it/get_it.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'core/network/graphql_client.dart';
import 'features/users/data/datasources/user_remote_data_source.dart';
import 'features/users/data/repositories/user_repository_impl.dart';
import 'features/users/domain/repositories/user_repository.dart';
import 'features/users/domain/usecases/create_user.dart';
import 'features/users/domain/usecases/get_user_by_id.dart';
import 'features/users/domain/usecases/get_users.dart';
import 'features/users/presentation/cubit/add_user/add_user_cubit.dart';
import 'features/users/presentation/cubit/user_detail/user_detail_cubit.dart';
import 'features/users/presentation/cubit/user_list/user_list_cubit.dart';

final getIt = GetIt.instance;
class AppDi {

  static Future<void> init() async {
    // Register Cubits as Factory - new instance each time to avoid "close" issues
    getIt.registerFactory<UserListCubit>(
          () => UserListCubit(getUsersUseCase: getIt()),
    );
    getIt.registerFactory<AddUserCubit>(
          () => AddUserCubit(createUserUseCase: getIt()),
    );
    getIt.registerFactory<UserDetailCubit>(
          () => UserDetailCubit(getUserById: getIt()),
    );

    // Use cases can remain as singletons - they don't have state
    getIt.registerLazySingleton<GetUsers>(() => GetUsers(getIt()));
    getIt.registerLazySingleton<GetUserById>(() => GetUserById(getIt()));
    getIt.registerLazySingleton<CreateUser>(() => CreateUser(getIt()));

    // Repository and data sources can remain as singletons
    getIt.registerLazySingleton<UserRepository>(
          () => UserRepositoryImpl(remoteDataSource: getIt()),
    );

    getIt.registerLazySingleton<UserRemoteDataSource>(
          () => UserRemoteDataSourceImpl(client: getIt()),
    );

    getIt.registerLazySingleton<GraphQLClient>(() =>
        GraphQLClientConfig.getClient());

  }
  static Future<void> dispose() async{
    getIt.reset();
  }

  static UserListCubit  get userListCubit => getIt<UserListCubit>();
  static AddUserCubit  get addUserCubit => getIt<AddUserCubit>();
  static UserDetailCubit  get userDetailCubit => getIt<UserDetailCubit>();
  static GetUsers  get getUsers => getIt<GetUsers>();
  static GetUserById  get getUserById => getIt<GetUserById>();
  static CreateUser  get createUser => getIt<CreateUser>();
  static UserRepository  get userRepository => getIt<UserRepository>();
  static UserRemoteDataSource  get userRemoteDataSource => getIt<UserRemoteDataSource>();
  static GraphQLClient  get graphQLClient => getIt<GraphQLClient>();




}