// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['activityId', 'name'],
    disallowNullValues: const ['activityId'],
  );
  return Activity(
    activityId: json['activityId'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    type: json['type'] as String?,
    activityStartTime: json['activityStartTime'] == null
        ? null
        : DateTime.parse(json['activityStartTime'] as String),
    activityEndTime: json['activityEndTime'] == null
        ? null
        : DateTime.parse(json['activityEndTime'] as String),
    registrationEndTime: json['registrationEndTime'] == null
        ? null
        : DateTime.parse(json['registrationEndTime'] as String),
    registrationPrice: (json['registrationPrice'] as num?)?.toDouble(),
    applicantPax: json['applicantPax'] as int?,
    attendanceReqPercent: (json['attendanceReqPercent'] as num?)?.toDouble(),
    potions: json['potions'] as int?,
    mediaContentUrls: (json['mediaContentUrls'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    enabled: json['enabled'] as bool?,
    approved: json['approved'] as bool?,
    status: json['status'] as String?,
    activitySessionList: (json['activitySessionList'] as List<dynamic>?)
        ?.map((e) => Session.fromJson(e as Map<String, dynamic>))
        .toList(),
    participantCount: json['participantCount'] as int?,
    approvedDate: json['approvedDate'] == null
        ? null
        : DateTime.parse(json['approvedDate'] as String),
    organisation: json['organisation'] == null
        ? null
        : Organisation.fromJson(json['organisation'] as Map<String, dynamic>),
    isBump: json['isBump'] as bool?,
    isFeatured: json['isFeatured'] as bool?,
    isRegistered: json['isRegistered'] as bool?,
  );
}

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'activityId': instance.activityId,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'activityStartTime': instance.activityStartTime?.toIso8601String(),
      'activityEndTime': instance.activityEndTime?.toIso8601String(),
      'registrationEndTime': instance.registrationEndTime?.toIso8601String(),
      'registrationPrice': instance.registrationPrice,
      'applicantPax': instance.applicantPax,
      'attendanceReqPercent': instance.attendanceReqPercent,
      'potions': instance.potions,
      'mediaContentUrls': instance.mediaContentUrls,
      'enabled': instance.enabled,
      'approved': instance.approved,
      'status': instance.status,
      'activitySessionList':
          instance.activitySessionList?.map((e) => e.toJson()).toList(),
      'participantCount': instance.participantCount,
      'approvedDate': instance.approvedDate?.toIso8601String(),
      'organisation': instance.organisation?.toJson(),
      'isBump': instance.isBump,
      'isFeatured': instance.isFeatured,
      'isRegistered': instance.isRegistered,
    };
