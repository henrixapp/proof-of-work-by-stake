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
  print("Account 1:");
  print(chain.getAccountBalance(user.pubKeyHEX));
  print("Account 2:");
  print(chain.getAccountBalance(
      "242cbc2e76bde51005255560dc67b74a97ae8a0dac4402026114ecb1ad0da970"));

  await chain.submitTransaction(user,
      "242cbc2e76bde51005255560dc67b74a97ae8a0dac4402026114ecb1ad0da970", 1200);
  print(await chain.isValidChain());
  print("Account 1:");
  print(chain.getAccountBalance(user.pubKeyHEX));
  print("Account 2:");
  print(chain.getAccountBalance(
      "242cbc2e76bde51005255560dc67b74a97ae8a0dac4402026114ecb1ad0da970"));
  await chain.submitTransaction(user,
      "242cbc2e76bde51005255560dc67b74a97ae8a0dac4402026114ecb1ad0da970", 1230);
  print("Account 1:");
  print(chain.getAccountBalance(user.pubKeyHEX));
  print("Account 2:");
  print(chain.getAccountBalance(
      "242cbc2e76bde51005255560dc67b74a97ae8a0dac4402026114ecb1ad0da970"));
  fileChain.writeAsStringSync(json.encode(chain));
  //print(chain.findBlock(index, previousHash, transactions, announcements, difficulty, user))
}
