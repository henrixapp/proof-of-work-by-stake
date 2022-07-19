import 'dart:convert';
import 'dart:io';

import 'package:staking_lib/staking_lib.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print("create-accounts.dart usage");
    print("create-accounts.dart <name1> <name2> ...");
    print("Creates a json file to the usernames");
  }
  for (var e in args) {
    final file = File("$e.json");
    if (await file.exists()) {
      print("$e.json exists. Please remove. Will not override.");
    } else {
      await file.writeAsString(json.encode(await Account.fromRandom(e)));
    }
  }
}
