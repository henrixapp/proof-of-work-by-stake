import 'package:staking_lib/src/announcement.dart';
import 'package:json_annotation/json_annotation.dart';
import 'transaction.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for the utf8.encode method
part 'block.g.dart';

@JsonSerializable()
class Block {
  final int index;
  final String hash;
  final String previousHash;
  final DateTime timestamp;
  final List<Transaction> transactions;
  final List<Announcement> announcements;
  final int difficulty;
  final String minterAdress;
  final int minterBalance;
  final int nonce;
  static String calculateHash(
      int index,
      String previousHash,
      DateTime timestamp,
      List<Transaction> transactions,
      List<Announcement> announcements,
      int difficulty,
      String minterAdress,
      int minterBalance,
      int nonce) {
    var tobeHashed =
        '$index$previousHash${timestamp.toIso8601String()},$transactions,$announcements,$difficulty,$minterAdress,$minterBalance,$nonce';
    //print(tobeHashed);
    var input = utf8.encode(tobeHashed);
    return sha256.convert(input).toString();
  }

  Block(
      this.index,
      this.previousHash,
      this.timestamp,
      this.transactions,
      this.announcements,
      this.difficulty,
      this.minterAdress,
      this.minterBalance,
      this.nonce)
      : hash = calculateHash(index, previousHash, timestamp, transactions,
            announcements, difficulty, minterAdress, minterBalance, nonce);
  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);

  Map<String, dynamic> toJson() => _$BlockToJson(this);
  @override
  String toString() {
    return toJson().toString();
  }

  bool isBlockStakingValid() {
    final comp =
        BigInt.from(2).pow(256) * BigInt.from(minterBalance / difficulty);
    final stakingHashInt = BigInt.parse("0x$hash");
    return stakingHashInt <= comp;
  }

  bool isValidNewBlock(Block oldblock) {
    return oldblock.index == (index - 1) &&
        oldblock.hash == previousHash &&
        oldblock.timestamp.isBefore(timestamp) &&
        calculateHash(
                index,
                previousHash,
                timestamp,
                transactions,
                announcements,
                difficulty,
                minterAdress,
                minterBalance,
                nonce) ==
            hash &&
        isBlockStakingValid();
  }
}
