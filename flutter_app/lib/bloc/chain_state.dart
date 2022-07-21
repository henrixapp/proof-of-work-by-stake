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
