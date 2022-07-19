import 'package:cryptography/cryptography.dart';
import 'package:json_annotation/json_annotation.dart';

part 'announcement.g.dart';

/**
 * Announcement is a special feature of our blockchain to allow the announcement of an transaction
 */
@JsonSerializable()
class Announcement {
  final DateTime timePoint;
  final String signature;
  final String user;
  final String project;
  final String type;

  bool verifySignature() {
    return true;
  }

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);

  Announcement(
      this.timePoint, this.signature, this.user, this.project, this.type);

  Map<String, dynamic> toJson() => _$AnnouncementToJson(this);
  @override
  String toString() {
    return toJson().toString();
  }
}
