// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Block _$BlockFromJson(Map<String, dynamic> json) => Block(
      json['index'] as int,
      json['previousHash'] as String,
      DateTime.parse(json['timestamp'] as String),
      (json['transactions'] as List<dynamic>)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['announcements'] as List<dynamic>)
          .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['difficulty'] as int,
      json['minterAdress'] as String,
      json['minterBalance'] as int,
    );

Map<String, dynamic> _$BlockToJson(Block instance) => <String, dynamic>{
      'index': instance.index,
      'previousHash': instance.previousHash,
      'timestamp': instance.timestamp.toIso8601String(),
      'transactions': instance.transactions,
      'announcements': instance.announcements,
      'difficulty': instance.difficulty,
      'minterAdress': instance.minterAdress,
      'minterBalance': instance.minterBalance,
    };
