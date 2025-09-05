import 'Addresses.dart';

class Authen {
  String message;
  String accessToken;
  String refreshToken;
  User user;

  Authen({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory Authen.fromJson(Map<String, dynamic> json) {
    return Authen(
      message: json["message"] ?? '',
      accessToken: json["accessToken"] ?? '',
      refreshToken: json["refreshToken"] ?? '',
      user: User.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "user": user.toJson(),
    };
  }

  @override
  String toString() {
    return 'Authen{message: $message, accessToken: $accessToken, refreshToken: $refreshToken, user: ${user.toString()}';
  }
}

class User{
  String id;
  String fullName;
  String phone;
  String email;
  Addresses addresses;

  User({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.addresses,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] ?? '',
      fullName: json["fullName"] ?? '',
      phone: json["phone"] ?? '',
      email: json["email"] ?? '',
      addresses: Addresses.fromJson(json["address"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "phone": phone,
      "email": email,
      "address": addresses.toJson(),
    };
  }

  @override
  String toString() {
    return 'User{id: $id, fullName: $fullName, phone: $phone}';
  }
}