part of 'chain_bloc.dart';

@immutable
abstract class ChainState extends Equatable {
  final int amount;
  final String pubkey;
  ChainState(this.amount, this.pubkey);
  @override
  List<Object> get props => [amount];
}

class ChainInitial extends ChainState {
  ChainInitial(super.amount, super.pubkey);
}

class ChainLoaded extends ChainState {
  ChainLoaded(super.amount, super.pubkey);
}

class ChainTimeRunning extends ChainState {
  final DateTime since;
  final String to;
  ChainTimeRunning(super.amount, this.since, this.to, super.pubkey);
  @override
  List<Object> get props => [amount, since, to];
}
