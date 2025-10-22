import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class UserDetailState extends Equatable {
  const UserDetailState();

  @override
  List<Object> get props => [];
}

class UserDetailInitial extends UserDetailState {
  const UserDetailInitial();
}

class UserDetailLoading extends UserDetailState {
  const UserDetailLoading();
}

class UserDetailError extends UserDetailState {
  final String message;

  const UserDetailError({required this.message});

  @override
  List<Object> get props => [message];
}

class UserDetailDisplay extends UserDetailState {
  final UserEntity user;

  const UserDetailDisplay({required this.user});

  @override
  List<Object> get props => [user];
}

class UserDetailEditing extends UserDetailState {
  final UserEntity user;

  const UserDetailEditing({required this.user});

  @override
  List<Object> get props => [user];
}

class UserDetailUpdating extends UserDetailState {
  final UserEntity user;

  const UserDetailUpdating({required this.user});

  @override
  List<Object> get props => [user];
}

class UserDetailUpdateSuccess extends UserDetailState {
  final UserEntity user;

  const UserDetailUpdateSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class UserDetailUpdateError extends UserDetailState {
  final UserEntity user;
  final String message;

  const UserDetailUpdateError({required this.user, required this.message});

  @override
  List<Object> get props => [user, message];
}
