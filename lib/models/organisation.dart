import 'package:json_annotation/json_annotation.dart';
part 'organisation.g.dart';


@JsonSerializable()
class Organisation {
  @JsonKey(required: true, disallowNullValue: true)
  String organisationId;

  @JsonKey(required: true)
  String name;

  @JsonKey(required: true)
  String email;

  String? countryCode;

  String? website;

  List<String>? orgTags;

  String? roleId;
  String? role;
  String? userType;
  String? loginType;

  bool? enabled;
  bool? verified;

  DateTime? createdAt;
  DateTime? lastLogin;

  String? profilePicUrl;

  Organisation({required this.organisationId, required this.name, required this.email,
    this.countryCode, this.website,
    this.roleId, this.role, this.userType, this.loginType,
    this.enabled, this.verified, this.createdAt, this.lastLogin, this.profilePicUrl});

  factory Organisation.fromJson(Map<String, dynamic> json) => _$OrganisationFromJson(json);

  Map<String, dynamic> toJson() => _$OrganisationToJson(this);

}