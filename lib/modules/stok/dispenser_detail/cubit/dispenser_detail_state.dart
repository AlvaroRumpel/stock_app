part of 'dispenser_detail_cubit.dart';

sealed class DispenserDetailState extends Equatable {
  const DispenserDetailState();

  @override
  List<Object> get props => [];
}

final class DispenserDetailInitial extends DispenserDetailState {}

final class DispenserDetailLoading extends DispenserDetailState {}

final class DispenserDetailLoaded extends DispenserDetailState {
  final Product dispenser;

  const DispenserDetailLoaded(this.dispenser);

  @override
  List<Object> get props => [dispenser];
}

final class DispenserDetailError extends DispenserDetailState {
  final String? message;
  const DispenserDetailError({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

final class DispenserDetailDeleted extends DispenserDetailState {}

final class DispenserDetailUpdated extends DispenserDetailState {}
