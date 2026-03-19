part of 'dispenser_create_cubit.dart';

sealed class DispenserCreateState extends Equatable {
  const DispenserCreateState();

  @override
  List<Object> get props => [];
}

final class BarrelCreateInitial extends DispenserCreateState {}

final class BarrelCreateLoading extends DispenserCreateState {}

final class BarrelCreateSuccess extends DispenserCreateState {}

final class BarrelCreateError extends DispenserCreateState {}
