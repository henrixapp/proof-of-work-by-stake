import 'dart:convert';
import 'dart:io';

import 'package:staking_lib/staking_lib.dart';

void main(List<String> args) async {
  if (args.isEmpty || args.length > 3) {
    print("--- client.dart usage ---");
    print("Please supply two arguments");
    print("dart client.dart <username> port <optional:chain.file>");
    print(
        "Loads the chain at <chain.file>. If File does not exists, a new chain will be generated");
    print("Port will be used");
    print("Uses the priv/pubKey out of <username>.json for identification.");
    return;
  }
  final fileUser = File("${args[0]}.json");
  final user = Account.fromJson(jsonDecode(fileUser.readAsStringSync()));
  String filename = "";
  if (args.length > 2) {
    filename = args[2];
  }
  final fileChain = File("${filename}.json");
  final fileChain2 = File("${DateTime.now()}-new.json");

  Blockchain? chain;
  if (await fileChain.exists()) {
    chain = Blockchain.fromJson(jsonDecode(fileChain.readAsStringSync()));
  } else {
    chain = Blockchain.create([user], 4 * 5 * 8 * 3600, user);
    fileChain.writeAsStringSync(json.encode(chain));
  }
  UDPChainHolder chainHolder = UDPChainHolder(chain, user, (String m) {
    print(m);
  }, int.parse(args[1]));
  await chainHolder.start();
  if (chain.chain.length <= 1) {
    print("Request");
    await chainHolder.request();
  }
  print("Validate:");
  while (true) {
    print("Command(quit,send,balance):");
    String command = stdin.readLineSync()!;
    if (command == "quit") {
      break;
    }
    if (command == "balance") {
      print("Your balance is ${chainHolder.getAccountBalance()}");
    }
    if (command == "send") {
      print("Please specify the address:");
      String adress = stdin.readLineSync()!;
      print("Please enter the amount:");
      int amount = int.parse(stdin.readLineSync()!);
      chainHolder.sendAmmountTo(adress, amount);
    }
  }
  fileChain2.writeAsStringSync(json.encode(chainHolder.chain));
  //print(chain.findBlock(index, previousHash, transactions, announcements, difficulty, user))
}
