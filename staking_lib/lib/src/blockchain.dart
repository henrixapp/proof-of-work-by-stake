import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:hex/hex.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staking_lib/staking_lib.dart';
import 'package:tuple/tuple.dart';

import 'transaction.dart';
import 'announcement.dart';
import 'block.dart';

part 'blockchain.g.dart';

@JsonSerializable()
class Blockchain {
  List<Block> chain;
  List<UnspentTxOut> unspentTxOuts({bool verbose = false}) {
    List<UnspentTxOut> unspent = chain
        .map((e) => e.transactions
            .map((e2) {
              final List fixedList =
                  Iterable<int>.generate(e2.txOuts.length).toList();
              return fixedList
                  .map((id) => UnspentTxOut(
                      e2.id, id, e2.txOuts[id].address, e2.txOuts[id].amount))
                  .toList();
            })
            .reduce((value, element) => value + element)
            .toList())
        .reduce((value, element) => element + value)
        .toList();
    List<UnspentTxOut> consumedTxOuts = chain
        .map((e) => e.transactions
            .map((e2) {
              final List fixedList =
                  Iterable<int>.generate(e2.txIns.length).toList();
              return fixedList.map((i) {
                final e3 = e2.txIns[i];
                return UnspentTxOut(e3.txOutId, e3.txOutIndex, '', 0);
              }).toList();
            })
            .reduce((value, element) => value + element)
            .toList())
        .reduce((value, element) => value + element)
        .toList();
    return unspent
        .where((element) =>
            (consumedTxOuts.firstWhere(
                (uTxO) =>
                    uTxO.txOutId == element.txOutId &&
                    uTxO.txOutIdx == element.txOutIdx,
                orElse: () => UnspentTxOut("null", 0, "", 0))).txOutId ==
            "null")
        .toList();
  }

  Blockchain(this.chain);
  Blockchain.create(
      List<Account> accounts, int initialEndowmentPerAccount, Account creator)
      : chain = [] {
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
        100,
        0));
    isValidChain();
    //chain.add(value);
  }
  factory Blockchain.fromJson(Map<String, dynamic> json) =>
      _$BlockchainFromJson(json)..isValidChain();

  Map<String, dynamic> toJson() => _$BlockchainToJson(this);
  @override
  String toString() {
    return toJson().toString();
  }

  int getAccountBalance(String pubKey) {
    int res = 0;
    try {
      res = unspentTxOuts(verbose: true)
          .where((element) => element.address == pubKey)
          .map((e) => e.amount)
          .reduce((value, element) => value + element);
    } catch (e) {}
    return res;
  }

  Tuple2<List<UnspentTxOut>, int> findTxOutsForAmount(
      int amount, List<UnspentTxOut> myUnspentTxOuts, String address) {
    int currentAmount = 0;
    List<UnspentTxOut> includedUnspentTxOuts = [];
    for (var myUnspentTxOut in myUnspentTxOuts) {
      if (myUnspentTxOut.address == address) {
        includedUnspentTxOuts.add(myUnspentTxOut);
        currentAmount = currentAmount + myUnspentTxOut.amount;
        if (currentAmount >= amount) {
          final leftOverAmount = currentAmount - amount;
          return Tuple2<List<UnspentTxOut>, int>(
              includedUnspentTxOuts, leftOverAmount);
        }
      }
    }
    throw ('not enough coins to send transaction');
  }

  List<TxOut> createTxOuts(String receiverAddress, String myAddress, int amount,
      int leftOverAmount) {
    final txOut1 = TxOut(receiverAddress, amount);
    if (leftOverAmount == 0) {
      return [txOut1];
    } else {
      final leftOverTx = TxOut(myAddress, leftOverAmount);
      return [txOut1, leftOverTx];
    }
  }

  Future<void> submitTransaction(Account from, String to, int amount) async {
    var res = findTxOutsForAmount(amount, unspentTxOuts(), from.pubKeyHEX);
    final leftOverAmount = res.item2;
    final includedUnspentTx = res.item1;
    final unsignedTxIns =
        includedUnspentTx.map((e) => TxIn(e.txOutId, e.txOutIdx, "")).toList();
    var tx = Transaction("", unsignedTxIns,
        createTxOuts(to, from.pubKeyHEX, amount, leftOverAmount));
    tx.id = Transaction.transactionId(tx.txIns, tx.txOuts);
    final List fixedList = Iterable<int>.generate(tx.txIns.length).toList();
    for (var i = 0; i < tx.txIns.length; i++) {
      tx.txIns[i].signature = await from.signTxIn(tx, i, unspentTxOuts());
    }
    final difficulty = 10000;
    chain.add(
        findBlock(chain.length, chain.last.hash, [tx], [], difficulty, from));
    isValidChain();
  }

  Future<Transaction> generateTransaction(
      Account from, String to, int amount) async {
    var res = findTxOutsForAmount(amount, unspentTxOuts(), from.pubKeyHEX);
    final leftOverAmount = res.item2;
    final includedUnspentTx = res.item1;
    final unsignedTxIns =
        includedUnspentTx.map((e) => TxIn(e.txOutId, e.txOutIdx, "")).toList();
    var tx = Transaction("", unsignedTxIns,
        createTxOuts(to, from.pubKeyHEX, amount, leftOverAmount));
    tx.id = Transaction.transactionId(tx.txIns, tx.txOuts);
    final List fixedList = Iterable<int>.generate(tx.txIns.length).toList();
    for (var i = 0; i < tx.txIns.length; i++) {
      tx.txIns[i].signature = await from.signTxIn(tx, i, unspentTxOuts());
    }
    return tx;
  }

  Block findBlock(
      int index,
      String previousHash,
      List<Transaction> transactions,
      List<Announcement> announcements,
      int difficulty,
      Account user) {
    DateTime paststamp = DateTime.now();
    var rnd = Random();
    int iters = 0;
    while (true) {
      iters++;
      var timestamp = DateTime.now();
      final nonce = rnd.nextInt(10000);

      final block = Block(
          index,
          previousHash,
          timestamp,
          transactions,
          announcements,
          difficulty,
          user.pubKeyHEX,
          getAccountBalance(user.pubKeyHEX),
          nonce);
      if (block.isBlockStakingValid()) {
        print("Iters: $iters");
        return block;
      }
      paststamp = timestamp;
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
      print("set is smaller");
      return false; //TODO(henrik): Write test
    }
    final normalTransactions = transactions.skip(1);
    bool result = true;
    for (var tr in normalTransactions) {
      result &= await validate(tr, aUnspentTxOuts);
      if (!result) {
        print("test");
        print(tr);
      }
    }
    return result;
  }

  Future<List<UnspentTxOut>?> processTransactions(
      List<Transaction> transactions,
      List<UnspentTxOut> aUnspentTxOuts,
      int blockIndex) async {
    if (blockIndex != 0 &&
        !(await validateBlockTransactions(
            transactions, aUnspentTxOuts, blockIndex))) {
      return null;
    }
    return updateUnspentTxOuts(transactions, aUnspentTxOuts);
  }

  Future<bool> isValidChain() async {
    List<UnspentTxOut>? aUnspentTxOuts = [];
    for (var i = 0; i < chain.length; i++) {
      Block currentBlock = chain[i];
      if (i != 0 && !currentBlock.isValidNewBlock(chain[i - 1])) {
        return false;
      }

      aUnspentTxOuts = await processTransactions(
          currentBlock.transactions, aUnspentTxOuts!, currentBlock.index);
      if (aUnspentTxOuts == null) {
        print('invalid transactions in blockchain');
        return false;
      }
    }
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
              Iterable<int>.generate(e2.txIns.length).toList();
          return fixedList.map((i) {
            final e = e2.txIns[i];
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

  void appendBlock(Block latestBlock) {
    if (latestBlock.isValidNewBlock(chain.last)) {
      print("Appending block");
      chain.add(latestBlock);
    }
  }

  Block submitTransactions(List<Transaction> transactionPool, Account from) {
    final difficulty = 10000;
    Block bl = findBlock(
        chain.length, chain.last.hash, transactionPool, [], difficulty, from);
    chain.add(bl);
    return bl;
  }
}
