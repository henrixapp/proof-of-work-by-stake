// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communication.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      json['request'] as String,
      json['senderIdent'] as String,
    )
      ..chain = json['chain'] == null
          ? null
          : Blockchain.fromJson(json['chain'] as Map<String, dynamic>)
      ..latestBlock = json['latestBlock'] == null
          ? null
          : Block.fromJson(json['latestBlock'] as Map<String, dynamic>)
      ..transactionPool = (json['transactionPool'] as List<dynamic>?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'chain': instance.chain,
      'latestBlock': instance.latestBlock,
      'transactionPool': instance.transactionPool,
      'request': instance.request,
      'senderIdent': instance.senderIdent,
    };
