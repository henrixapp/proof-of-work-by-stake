import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:staking_lib/staking_lib.dart';
import 'package:udp/udp.dart';
import 'blockchain.dart';

part 'communication.g.dart';

@JsonSerializable()
class Message {
  Blockchain? chain;
  Block? latestBlock;
  List<Transaction>? transactionPool;
  final String request;
  final String senderIdent;
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Message(this.request, this.senderIdent);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
  @override
  String toString() {
    return toJson().toString();
  }
}

class UDPChainHolder {
  Blockchain chain;
  Account account;
  UDP? udp;
  int port;
  Function callback;
  bool requested_new_chain = false;
  UDPChainHolder(this.chain, this.account, this.callback, this.port);
  Future<void> send(Message m) async {
    if (udp != null) {
      print(m);
      // send a simple string to a broadcast endpoint on port 65001.
      var dataLength = await udp!
          .send(jsonEncode(m).codeUnits, Endpoint.broadcast(port: Port(port)));
    }
  }

  void handle(Message m) async {
    print(m);
    if (m.senderIdent != account.pubKeyHEX) {
      if (m.request == "request_whole_chain") {
        var response = Message("send_whole_chain", account.pubKeyHEX);
        response.chain = chain;
        send(response);
      }
      if (m.request == "send_whole_chain") {
        if (m.chain != null &&
            chain.chain.length < m.chain!.chain.length &&
            await m.chain!.isValidChain() &&
            (chain.chain.length <= 1 || requested_new_chain)) {
          chain = m.chain!;
          requested_new_chain = false;
          print("Updated chain. From ${m.senderIdent}.");
        }
      }
      if (m.request == "send_transaction_pool") {
        if (m.transactionPool != null) {
          print("Received Pool. Trying to mint now.");
          handleTransactions(m.transactionPool!);
        }
      }
      if (m.request == "send_latest_block") {
        if (m.latestBlock != null) {
          handleSingleBlock(m.latestBlock!);
        }
      }
    }
  }

  Future<void> start() async {
    udp = await UDP.bind(Endpoint.any(port: Port(port)));
    udp!.asStream().listen((datagram) async {
      var str = String.fromCharCodes(datagram!.data);
      Message m = Message.fromJson(jsonDecode(str));
      print(str);
      handle(m);
    }, onError: (err) {
      print("Error: $err");
    });
  }

  void transaction(String receiver, int amount) {}
  void close() async {
    if (udp != null) udp!.close();
  }

  void handleSingleBlock(Block latestBlock) {
    chain.appendBlock(latestBlock);
  }

  int getAccountBalance() {
    return chain.getAccountBalance(account.pubKeyHEX);
  }

  void handleTransactions(List<Transaction> transactionPool) {
    Block bl = chain.submitTransactions(transactionPool, account);

    Message m = Message("send_latest_block", account.pubKeyHEX);
    m.latestBlock = bl;
    send(m);
  }

  void sendAmmountTo(String to, int amount) async {
    List<Transaction> txs = [
      await chain.generateTransaction(account, to, amount)
    ];
    Message m = Message("send_transaction_pool", account.pubKeyHEX);
    m.transactionPool = txs;
    send(m);
  }

  Future<void> request() async {
    Message m = Message("request_whole_chain", account.pubKeyHEX);
    await send(m);
  }
}
