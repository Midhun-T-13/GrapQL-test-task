import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class AddUserState extends Equatable {
  const AddUserState();

  @override
  List<Object> get props => [];
}

class AddUserInitial extends AddUserState {}

class AddUserLoading extends AddUserState {}

class AddUserSuccess extends AddUserState {
  final UserEntity user;

  const AddUserSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class AddUserError extends AddUserState {
  final String message;

  const AddUserError({required this.message});

  @override
  List<Object> get props => [message];
}
