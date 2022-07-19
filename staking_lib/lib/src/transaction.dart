import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

/**
 * TxOut stores, where the time goes
 */
@JsonSerializable()
class TxOut {
  final String address;
  final int amount;

  TxOut(this.address, this.amount);
  factory TxOut.fromJson(Map<String, dynamic> json) => _$TxOutFromJson(json);
  Map<String, dynamic> toJson() => _$TxOutToJson(this);
  @override
  String toString() {
    return toJson().toString();
  }
}

/**
 * TxIn stores, where the time comes from
 */
@JsonSerializable()
class TxIn {
  final String txOutId;
  final int txOutIndex;
  String signature;
  factory TxIn.fromJson(Map<String, dynamic> json) => _$TxInFromJson(json);

  TxIn(this.txOutId, this.txOutIndex, this.signature);
  Map<String, dynamic> toJson() => _$TxInToJson(this);
}

@JsonSerializable()
class UnspentTxOut {
  final String txOutId;
  final int txOutIdx;
  final String address;
  final int amount;

  UnspentTxOut(this.txOutId, this.txOutIdx, this.address, this.amount);
  factory UnspentTxOut.fromJson(Map<String, dynamic> json) =>
      _$UnspentTxOutFromJson(json);

  Map<String, dynamic> toJson() => _$UnspentTxOutToJson(this);
  @override
  String toString() {
    return toJson().toString();
  }
}

@JsonSerializable()
class Transaction {
  String id;
  List<TxIn> txIns;
  final List<TxOut> txOuts;
  Transaction(this.id, this.txIns, this.txOuts);
  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
  static String transactionId(List<TxIn> txIns, List<TxOut> txOuts) {
    String tobeHashed =
        txIns.map((e) => "${e.txOutId},${e.txOutIndex}").join() +
            txOuts.map((e) => "${e.address},${e.amount}").join();
    var input = utf8.encode(tobeHashed);
    return sha256.convert(input).toString();
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
