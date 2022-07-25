part of 'chain_bloc.dart';

@immutable
abstract class ChainEvent {}

class ChainLoad extends ChainEvent {}

class ChainRequest extends ChainEvent {}

class ChainChanged extends ChainEvent {}

class ChainSend extends ChainEvent {
  final int amount;
  final String to;
  ChainSend(this.amount, this.to);
}

class ChainAnnounced extends ChainEvent {
  final String to;
  final DateTime timestamp;
  ChainAnnounced(this.timestamp, this.to);
}

class ChainAbort extends ChainEvent {}
