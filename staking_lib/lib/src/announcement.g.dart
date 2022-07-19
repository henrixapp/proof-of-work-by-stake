// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) => Announcement(
      DateTime.parse(json['timePoint'] as String),
      json['signature'] as String,
      json['user'] as String,
      json['project'] as String,
      json['type'] as String,
    );

Map<String, dynamic> _$AnnouncementToJson(Announcement instance) =>
    <String, dynamic>{
      'timePoint': instance.timePoint.toIso8601String(),
      'signature': instance.signature,
      'user': instance.user,
      'project': instance.project,
      'type': instance.type,
    };
