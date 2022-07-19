import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:hex/hex.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staking_lib/staking_lib.dart';

import 'transaction.dart';
import 'announcement.dart';
import 'block.dart';

part 'blockchain.g.dart';

@JsonSerializable()
class Blockchain {
  List<Block> chain;
  List<UnspentTxOut> aUnspentTxOuts;
  Blockchain(this.chain, this.aUnspentTxOuts);
  Blockchain.create(
      List<Account> accounts, int initialEndowmentPerAccount, Account creator)
      : chain = [],
        aUnspentTxOuts = [] {
    chain.add(Block(
        0,
        "",
        DateTime.now(),
        [
          Transaction(
              Transaction.transactionId(
                  [],
                  accounts
                      .map(
                          (e) => TxOut(e.pubKeyHEX, initialEndowmentPerAccount))
                      .toList()),
              [],
              accounts
                  .map((e) => TxOut(e.pubKeyHEX, initialEndowmentPerAccount))
                  .toList())
        ],
        [],
        10,
        creator.pubKeyHEX,
        100));
    //chain.add(value);
  }
  factory Blockchain.fromJson(Map<String, dynamic> json) =>
      _$BlockchainFromJson(json);

  Map<String, dynamic> toJson() => _$BlockchainToJson(this);
  @override
  String toString() {
    return toJson().toString();
  }

  int getAccountBalance(String pubKey) {
    return aUnspentTxOuts
        .where((element) => element.address == pubKey)
        .map((e) => e.amount)
        .reduce((value, element) => value + element);
  }

  Block findBlock(
      int index,
      String previousHash,
      List<Transaction> transactions,
      List<Announcement> announcements,
      int difficulty,
      Account user) {
    DateTime paststamp = DateTime.now();
    while (true) {
      var timestamp = DateTime.now();
      if (paststamp != timestamp) {
        final block = Block(
            index,
            previousHash,
            timestamp,
            transactions,
            announcements,
            difficulty,
            user.pubKeyHEX,
            getAccountBalance(user.pubKeyHEX));
        if (block.isBlockStakingValid()) {
          return block;
        }
        paststamp = timestamp;
      }
    }
  }

  Future<bool> validateTxIn(Transaction transaction, TxIn txIn,
      List<UnspentTxOut> aUnspentTxOuts) async {
    final algorithm = Ed25519();
    final referencedUTxOut = aUnspentTxOuts.firstWhere((element) =>
        element.txOutId == txIn.txOutId && element.txOutIdx == txIn.txOutIndex);
    final address = referencedUTxOut.address;
    final pubKey =
        SimplePublicKey(HEX.decode(address), type: KeyPairType.ed25519);
    final signature = Signature(HEX.decode(txIn.signature), publicKey: pubKey);
    return await algorithm.verify(utf8.encode(transaction.id),
        signature: signature);
  }

  getTxInAmount(TxIn txIn, List<UnspentTxOut> aUnspend) {
    return aUnspend
        .firstWhere((element) =>
            element.txOutId == txIn.txOutId &&
            element.txOutIdx == txIn.txOutIndex)
        .amount;
  }

  Future<bool> validate(
      Transaction transaction, List<UnspentTxOut> aUnspentTxOuts) async {
    bool validateTxIns = true;
    for (var txIn in transaction.txIns) {
      validateTxIns &= await validateTxIn(transaction, txIn, aUnspentTxOuts);
    }
    return Transaction.transactionId(transaction.txIns, transaction.txOuts) ==
            transaction.id &&
        validateTxIns &&
        transaction.txIns
                .map((e) => getTxInAmount(e, aUnspentTxOuts))
                .reduce((value, element) => value + element) ==
            transaction.txOuts
                .map((e) => e.amount)
                .reduce((value, element) => value + element);
  }

  Future<bool> validateBlockTransactions(List<Transaction> transactions,
      List<UnspentTxOut> aUnspentTxOuts, int blockIndex) async {
    List<TxIn> txIns = [];
    transactions.map((e) => e.txIns).forEach((element) {
      txIns.addAll(element);
    });
    if (txIns.toSet().length < txIns.length) {
      return false; //TODO(henrik): Write test
    }
    final normalTransactions = transactions.skip(1);
    bool result = true;
    for (var tr in normalTransactions) {
      result &= await validate(tr, aUnspentTxOuts);
    }
    return result;
  }

  List<UnspentTxOut>? processTransactions(List<Transaction> transactions,
      List<UnspentTxOut> aUnspentTxOuts, int blockIndex) {
    if (validateBlockTransactions(transactions, aUnspentTxOuts, blockIndex) !=
        true) {
      return null;
    }
    return updateUnspentTxOuts(transactions, aUnspentTxOuts);
  }

  bool isValidChain() {
    List<UnspentTxOut>? aUnspentTxOuts = [];
    for (var i = 0; i < chain.length; i++) {
      Block currentBlock = chain[i];
      if (i != 0 && !currentBlock.isValidNewBlock(chain[i - 1])) {
        return false;
      }

      aUnspentTxOuts = processTransactions(
          currentBlock.transactions, aUnspentTxOuts!, currentBlock.index);
      if (aUnspentTxOuts == null) {
        print('invalid transactions in blockchain');
        return false;
      }
    }
    this.aUnspentTxOuts = aUnspentTxOuts!;
    return true;
  }

  List<UnspentTxOut> updateUnspentTxOuts(
      List<Transaction> transactions, List<UnspentTxOut> aUnspentTxOuts) {
    List<UnspentTxOut> newOnes = transactions
        .map((e2) {
          final List fixedList =
              Iterable<int>.generate(e2.txOuts.length).toList();
          return fixedList.map((i) {
            final e = e2.txOuts[i];
            return UnspentTxOut(e2.id, i, e.address, e.amount);
          }).toList();
        })
        .reduce((value, element) => value + element)
        .toList();
    List<UnspentTxOut> consumedTxOuts = transactions
        .map((e2) {
          final List fixedList =
              Iterable<int>.generate(e2.txOuts.length).toList();
          return fixedList.map((i) {
            final e = e2.txOuts[i];
            return UnspentTxOut(e2.id, i, '', 0);
          }).toList();
        })
        .reduce((value, element) => value + element)
        .toList();
    return aUnspentTxOuts
        .where((element) =>
            (consumedTxOuts.firstWhere(
                (uTxO) =>
                    uTxO.txOutId == element.txOutId &&
                    uTxO.txOutIdx == element.txOutIdx,
                orElse: () => UnspentTxOut("null", 0, "", 0))).txOutId ==
            "null")
        .toList()
      ..addAll(newOnes);
  }
}
