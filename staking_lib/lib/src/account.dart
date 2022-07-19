import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:hex/hex.dart';
import 'package:json_annotation/json_annotation.dart';

import 'Transaction.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final String username;
  final String pubKeyHEX;
  final String privateKeyHEX;
  final String type;

  Account(this.username, this.pubKeyHEX, this.privateKeyHEX, this.type);
  static Future<Account> fromRandom(String username,
      {String type = "user"}) async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final pubKeyHEX = HEX.encode((await keyPair.extractPublicKey()).bytes);
    final privateKeyHEX = HEX.encode(await keyPair.extractPrivateKeyBytes());
    return Account(username, pubKeyHEX, privateKeyHEX, type);
  }

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
  Map<String, dynamic> toJson() => _$AccountToJson(this);
  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }

  Future<String> signTxIn(Transaction transaction, int txInIndex,
      List<UnspentTxOut> aUnspentTxOuts) async {
    final txI = transaction.txIns[txInIndex];
    final toSign =
        Transaction.transactionId(transaction.txIns, transaction.txOuts);

    final referencedUnspentTxOut =
        findUnspentTxOut(txI.txOutId, txI.txOutIndex, aUnspentTxOuts);
    final referencedAddress = referencedUnspentTxOut.address;
    final algorithm = Ed25519();
    final pubKey =
        SimplePublicKey(HEX.decode(pubKeyHEX), type: KeyPairType.ed25519);
    final privKey = SimpleKeyPairData(HEX.decode(privateKeyHEX),
        type: KeyPairType.ed25519, publicKey: pubKey);
    return HEX.encode(
        (await algorithm.sign(utf8.encode(toSign), keyPair: privKey))
            .bytes); //TODO(henrik): signing the hex value?
  }

  static UnspentTxOut findUnspentTxOut(
      String txOutId, int txOutIndex, List<UnspentTxOut> aUnspentTxOuts) {
    return aUnspentTxOuts.firstWhere(
        (uTxO) => uTxO.txOutId == txOutId && uTxO.txOutIdx == txOutIndex);
  }
}
