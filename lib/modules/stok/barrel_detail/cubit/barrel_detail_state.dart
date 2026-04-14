part of 'barrel_detail_cubit.dart';

sealed class BarrelDetailState extends Equatable {
  const BarrelDetailState();

  @override
  List<Object> get props => [];
}

final class BarrelDetailInitial extends BarrelDetailState {}

final class BarrelDetailLoading extends BarrelDetailState {}

final class BarrelDetailLoaded extends BarrelDetailState {
  final Product barrel;

  const BarrelDetailLoaded(this.barrel);

  @override
  List<Object> get props => [barrel];
}

final class BarrelDetailError extends BarrelDetailState {
  final String? message;
  const BarrelDetailError({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

final class BarrelDetailDeleted extends BarrelDetailState {}

final class BarrelDetailUpdated extends BarrelDetailState {}
