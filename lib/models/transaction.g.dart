// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['_id'],
    disallowNullValues: const ['_id'],
  );
  return Transaction(
    transactionId: json['_id'] as String,
    details: json['details'] as Map<String, dynamic>?,
    amount: json['amount'] as Map<String, dynamic>?,
    status: json['status'] as String?,
    paymentChannel: json['paymentChannel'] as String?,
    transactedDate: json['transactedDate'] == null
        ? null
        : DateTime.parse(json['transactedDate'] as String),
    payFrom: json['payFrom'] as Map<String, dynamic>?,
    payTo: json['payTo'] as Map<String, dynamic>?,
    discount: json['discount'] as Map<String, dynamic>?,
  );
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      '_id': instance.transactionId,
      'details': instance.details,
      'amount': instance.amount,
      'status': instance.status,
      'paymentChannel': instance.paymentChannel,
      'transactedDate': instance.transactedDate?.toIso8601String(),
      'payFrom': instance.payFrom,
      'payTo': instance.payTo,
      'discount': instance.discount,
    };
