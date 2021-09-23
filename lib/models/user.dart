import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(required: true, disallowNullValue: true)
  String userId;

  @JsonKey(required: true)
  String email;

  String? mobile;

  @JsonKey(required: true)
  String firstName;

  @JsonKey(required: true)
  String lastName;

  String? gender;

  int? age;

  DateTime? dob;

  String? address1;
  String? address2;
  String? address3;
  String? postalCode;
  String? countryCode;
  String? city;

  String? school;

  String? roleId;
  String? role;
  String? userType;
  String? loginType;

  bool? enabled;
  bool? verified;

  DateTime? createdAt;
  DateTime? lastLogin;

  String? profilePicUrl;

  User({required this.userId, required this.email, this.mobile, required this.firstName, required this.lastName,
    this.gender, this.age, this.dob,
    this.address1, this.address2, this.address3,
    this.postalCode, this.countryCode, this.city, this.school,
    this.roleId, this.role, this.userType, this.loginType,
    this.enabled, this.verified, this.createdAt, this.lastLogin, this.profilePicUrl});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

}