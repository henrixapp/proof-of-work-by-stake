import 'package:staking_lib/src/announcement.dart';
export 'src/block.dart' show Block;
export 'src/account.dart' show Account;
export 'src/announcement.dart' show Announcement;
export 'src/transaction.dart' show Transaction;
export 'src/blockchain.dart' show Blockchain;

int calculate() {
  print(Announcement(DateTime.now(), "abc", "test", "bla", "test").toJson());
  return 0;
}
