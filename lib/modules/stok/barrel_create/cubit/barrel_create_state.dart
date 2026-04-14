part of 'barrel_create_cubit.dart';

sealed class BarrelCreateState extends Equatable {
  const BarrelCreateState();

  @override
  List<Object> get props => [];
}

final class BarrelCreateInitial extends BarrelCreateState {}

final class BarrelCreateLoading extends BarrelCreateState {}

final class BarrelCreateSuccess extends BarrelCreateState {}

final class BarrelCreateError extends BarrelCreateState {
  final String? message;
  const BarrelCreateError({this.message});

  @override
  List<Object> get props => [message ?? ''];
}
