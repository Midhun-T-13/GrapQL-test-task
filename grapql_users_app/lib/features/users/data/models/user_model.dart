import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.username,
    required super.email,
    super.phone,
    super.website,
    super.companyName,
    super.body,
    super.street,
    super.suite,
    super.city,
    super.zipcode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      companyName: json['company']?['name'] as String?,
      body: json['body'] as String?,
      street: json['address']?['street'] as String?,
      suite: json['address']?['suite'] as String?,
      city: json['address']?['city'] as String?,
      zipcode: json['address']?['zipcode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      if (companyName != null) 'company': {'name': companyName},
      if (body != null) 'body': body,
      if (street != null || suite != null || city != null || zipcode != null)
        'address': {
          if (street != null) 'street': street,
          if (suite != null) 'suite': suite,
          if (city != null) 'city': city,
          if (zipcode != null) 'zipcode': zipcode,
        },
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      username: username,
      email: email,
      phone: phone,
      website: website,
      companyName: companyName,
      body: body,
      street: street,
      suite: suite,
      city: city,
      zipcode: zipcode,
    );
  }
}
