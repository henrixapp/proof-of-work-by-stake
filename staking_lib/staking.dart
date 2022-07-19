import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:hex/hex.dart';
import 'package:staking_lib/src/account.dart';
import 'package:staking_lib/staking_lib.dart';

Future<void> main(List<String> args) async {
  print(await Account.fromRandom("henrik"));
  final algorithm = Ed25519();
  final secretKey = await algorithm.newKeyPair();
  final publicKey = await secretKey.extractPublicKey();
  print(HEX.encode(
      (await algorithm.sign(utf8.encode("Goes Crypto"), keyPair: secretKey))
          .bytes));
  print(HEX.encode(publicKey.bytes));
  print(HEX.encode(await secretKey.extractPrivateKeyBytes()));

  final secretKey2 = SimplePublicKey(
      HEX.decode(
          "5c81e24b57c2d951a1c662eaa7fc91c6a5b4f45c15139954118541642e9afefc"),
      type: KeyPairType.ed25519);
  final signature = Signature(
      HEX.decode(
          "c7cda7390eefe8e3b930377ca580974865d457cce19f341680d5e400ce3fe71f85601519b6df07358ce6a367440524fe656575e43574d2b3db50a5281da9bd08"),
      publicKey: secretKey2);
  print(
      await algorithm.verify(utf8.encode("Goes Crypto"), signature: signature));
  calculate();
}
