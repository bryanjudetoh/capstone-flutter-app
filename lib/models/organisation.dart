import 'package:json_annotation/json_annotation.dart';
part 'organisation.g.dart';


@JsonSerializable()
class Organisation {
  @JsonKey(required: true, disallowNullValue: true)
  String organisationId;

  @JsonKey(required: true)
  String name;

  String? email;

  String? countryCode;

  String? website;

  List<String>? orgTags;

  String? orgDisplayPicUrl;

  Organisation({required this.organisationId, required this.name, this.email,
    this.countryCode, this.website, this.orgDisplayPicUrl});

  factory Organisation.fromJson(Map<String, dynamic> json) => _$OrganisationFromJson(json);

  Map<String, dynamic> toJson() => _$OrganisationToJson(this);

}