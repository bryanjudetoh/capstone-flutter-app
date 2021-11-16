import 'package:json_annotation/json_annotation.dart';
part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  @JsonKey(required: true, disallowNullValue: true, name: '_id')
  String transactionId;

  Map<String, dynamic>? details;
  Map<String, dynamic>? amount;

  String? status;
  String? paymentChannel;
  DateTime? transactedDate;

  Map<String, dynamic>? payFrom;
  Map<String, dynamic>? payTo;
  Map<String, dynamic>? discount;

  Transaction({required this.transactionId, this.details, this.amount,
    this.status, this.paymentChannel, this.transactedDate,
    this.payFrom, this.payTo, this.discount,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}