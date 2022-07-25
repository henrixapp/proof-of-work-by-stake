import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart';

import 'package:staking_lib/staking_lib.dart';
import 'package:qr/qr.dart';

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
      final acc = await Account.fromRandom(e);
      await file.writeAsString(json.encode(acc));
      final qrImage =
          QrImage(QrCode(4, QrErrorCorrectLevel.L)..addData(acc.pubKeyHEX));
      Image image = Image.rgb(qrImage.moduleCount, qrImage.moduleCount);
      for (var x = 0; x < qrImage.moduleCount; x++) {
        for (var y = 0; y < qrImage.moduleCount; y++) {
          if (qrImage.isDark(y, x)) {
            // render a dark square on the canvas
            image.setPixelRgba(x, y, 0, 0, 0);
          } else {
            image.setPixelRgba(x, y, 255, 255, 255);
          }
        }
      }
      var f = File("$e-pub.png");
      await f.writeAsBytes(encodePng(image));
    }
  }
}
