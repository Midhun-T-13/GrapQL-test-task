import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? phone;
  final String? website;
  final String? companyName;
  final String? body;
  final String? street;
  final String? suite;
  final String? city;
  final String? zipcode;

  const UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phone,
    this.website,
    this.companyName,
    this.body,
    this.street,
    this.suite,
    this.city,
    this.zipcode,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        email,
        phone,
        website,
        companyName,
        body,
        street,
        suite,
        city,
        zipcode,
      ];
}
