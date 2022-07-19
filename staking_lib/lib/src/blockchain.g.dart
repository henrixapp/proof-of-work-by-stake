// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blockchain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Blockchain _$BlockchainFromJson(Map<String, dynamic> json) => Blockchain(
      (json['chain'] as List<dynamic>)
          .map((e) => Block.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['aUnspentTxOuts'] as List<dynamic>)
          .map((e) => UnspentTxOut.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BlockchainToJson(Blockchain instance) =>
    <String, dynamic>{
      'chain': instance.chain,
      'aUnspentTxOuts': instance.aUnspentTxOuts,
    };
