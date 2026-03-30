import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String email;
  String phoneNumber;
  String password;
  String lastName;
  String firstName;
  DateTime? dateOfBirth;
  String? gender;
  String? timeZone;
  String? city;
  DateTime createdAt;
  String role;

  UserModel(
      {this.id,
      required this.email,
      required this.phoneNumber,
      required this.password,
      required this.lastName,
      required this.firstName,
      this.dateOfBirth,
      this.gender,
      this.timeZone,
      this.city,
      required this.role,
      required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'timeZone': timeZone,
      'city': city,
      'createdAt': createdAt,
      'role': role,
    };
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      password: map['password'] ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: map['gender'],
      timeZone: map['timeZone'],
      city: map['city'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      role: map['role'] ?? 'participant',
    );
  }
}
