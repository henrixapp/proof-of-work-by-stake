// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TxOut _$TxOutFromJson(Map<String, dynamic> json) => TxOut(
      json['address'] as String,
      json['amount'] as int,
    );

Map<String, dynamic> _$TxOutToJson(TxOut instance) => <String, dynamic>{
      'address': instance.address,
      'amount': instance.amount,
    };

TxIn _$TxInFromJson(Map<String, dynamic> json) => TxIn(
      json['txOutId'] as String,
      json['txOutIndex'] as int,
      json['signature'] as String,
    );

Map<String, dynamic> _$TxInToJson(TxIn instance) => <String, dynamic>{
      'txOutId': instance.txOutId,
      'txOutIndex': instance.txOutIndex,
      'signature': instance.signature,
    };

UnspentTxOut _$UnspentTxOutFromJson(Map<String, dynamic> json) => UnspentTxOut(
      json['txOutId'] as String,
      json['txOutIdx'] as int,
      json['address'] as String,
      json['amount'] as int,
    );

Map<String, dynamic> _$UnspentTxOutToJson(UnspentTxOut instance) =>
    <String, dynamic>{
      'txOutId': instance.txOutId,
      'txOutIdx': instance.txOutIdx,
      'address': instance.address,
      'amount': instance.amount,
    };

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      json['id'] as String,
      (json['txIns'] as List<dynamic>)
          .map((e) => TxIn.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['txOuts'] as List<dynamic>)
          .map((e) => TxOut.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'txIns': instance.txIns,
      'txOuts': instance.txOuts,
    };
