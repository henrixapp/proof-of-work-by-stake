import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:hex/hex.dart';
import 'package:json_annotation/json_annotation.dart';

part 'announcement.g.dart';

/**
 * Announcement is a special feature of our blockchain to allow the announcement of an transaction
 */
@JsonSerializable()
class Announcement {
  final DateTime timePoint;
  String signature;
  final String user;
  final String project;
  final String type;

  Future<bool> verifySignature() async {
    final String toSign = project + type + timePoint.toString();
    final algorithm = Ed25519();
    final pubKey = SimplePublicKey(HEX.decode(user), type: KeyPairType.ed25519);
    final signature = Signature(HEX.decode(this.signature), publicKey: pubKey);
    return await algorithm.verify(utf8.encode(toSign), signature: signature);
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
