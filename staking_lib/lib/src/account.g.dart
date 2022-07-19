// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      json['username'] as String,
      json['pubKeyHEX'] as String,
      json['privateKeyHEX'] as String,
      json['type'] as String,
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'username': instance.username,
      'pubKeyHEX': instance.pubKeyHEX,
      'privateKeyHEX': instance.privateKeyHEX,
      'type': instance.type,
    };
