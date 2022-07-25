import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:staking_lib/staking_lib.dart';

part 'chain_event.dart';
part 'chain_state.dart';

class ChainBloc extends Bloc<ChainEvent, ChainState> {
  UDPChainHolder? chainHolder;
  Account? user;
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/user.json');
  }

  ChainBloc() : super(ChainInitial(0)) {
    on<ChainEvent>((event, emit) async {
      // TODO: implement event handler
      if (event is ChainLoad) {
        print("test");
        if (chainHolder == null) {
          var fi = await _localFile;
          user = await Account.fromRandom("henrik");
          if (fi.existsSync()) {
            user = Account.fromJson(jsonDecode((fi.readAsStringSync())));
          } else {
            fi.writeAsStringSync(jsonEncode(user!.toJson()));
          }
          final path = await _localPath;

          var fi2 = File('$path/chain.json');
          const initialEndowmentPerAccount = 3600 * 8 * 5;
          var chain =
              Blockchain.create([user!], initialEndowmentPerAccount, user!);
          if (fi2.existsSync()) {
            chain = Blockchain.fromJson(jsonDecode((fi2.readAsStringSync())));
          } else {
            fi2.writeAsStringSync(jsonEncode(chain.toJson()));
          }
          chainHolder = UDPChainHolder(chain, user!, () {
            print("chain changed");
            add(ChainChanged());
          }, 65000);
          await chainHolder!.bind();
          chainHolder!.start();
          print("Fertig!");
          print(chainHolder!.account.pubKeyHEX);
        }
      }
      if (event is ChainRequest) {
        if (chainHolder != null) {
          chainHolder!.chain.chain = [];
          await chainHolder!.request();
          emit(ChainLoaded(chainHolder!.getAccountBalance()));
        }
      }
      if (event is ChainChanged) {
        print("Reloadings");
        if (state is ChainTimeRunning) {
          emit(ChainTimeRunning(
              chainHolder!.getAccountBalance(),
              (state as ChainTimeRunning).since,
              (state as ChainTimeRunning).to));
        } else {
          emit(ChainLoaded(chainHolder!.getAccountBalance()));
        }
      }
      if (event is ChainAnnounced) {
        final res = await chainHolder!.announceTo(event.to);
        emit(ChainTimeRunning(
            chainHolder!.getAccountBalance(), res.timePoint, res.project));
      }
      if (event is ChainSend) {
        chainHolder!.sendAmmountTo(event.to, event.amount);
        emit(ChainLoaded(chainHolder!.getAccountBalance()));
      }
    });
  }
}
