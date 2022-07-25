part of 'chain_bloc.dart';

@immutable
abstract class ChainState extends Equatable {
  final int amount;

  ChainState(this.amount);
  @override
  List<Object> get props => [amount];
}

class ChainInitial extends ChainState {
  ChainInitial(super.amount);
}

class ChainLoaded extends ChainState {
  ChainLoaded(super.amount);
}

class ChainTimeRunning extends ChainState {
  final DateTime since;
  final String to;
  ChainTimeRunning(super.amount, this.since, this.to);
  @override
  List<Object> get props => [amount, since, to];
}
