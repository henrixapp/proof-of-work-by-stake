import 'dart:convert';
import 'dart:io';

import 'package:staking_lib/staking_lib.dart';

void main(List<String> args) async {
  if (args.isEmpty || args.length > 2) {
    print("--- client.dart usage ---");
    print("Please supply two arguments");
    print("dart client.dart <username> <chain.file>");
    print(
        "Loads the chain at <chain.file>. If File does not exists, a new chain will be generated");
    print("Uses the priv/pubKey out of <username>.json for identification.");
    return;
  }
  final fileUser = File("${args[0]}.json");
  final user = Account.fromJson(jsonDecode(fileUser.readAsStringSync()));
  final fileChain = File("${args[1]}.json");
  Blockchain? chain;
  if (await fileChain.exists()) {
    chain = Blockchain.fromJson(jsonDecode(fileChain.readAsStringSync()));
  } else {
    chain = Blockchain.create([user], 4 * 5 * 8 * 3600, user);
    fileChain.writeAsStringSync(json.encode(chain));
  }
  print("Validate:");
  print(await chain.isValidChain());
  while (true) {
    print("Command(quit,send,balance):");
    String command = stdin.readLineSync()!;
    if (command == "quit") {
      break;
    }
    if (command == "balance") {
      print("Your balance is ${chain.getAccountBalance(user.pubKeyHEX)}");
    }
    if (command == "send") {
      print("Please specify the address:");
      String adress = stdin.readLineSync()!;
      print("Please enter the amount:");
      int amount = int.parse(stdin.readLineSync()!);
      await chain.submitTransaction(user, adress, amount);
    }
  }
  fileChain.writeAsStringSync(json.encode(chain));
  //print(chain.findBlock(index, previousHash, transactions, announcements, difficulty, user))
}
