part of 'stok_cubit.dart';

sealed class StokState extends Equatable {
  const StokState();

  @override
  List<Object> get props => [];
}

final class StokInitial extends StokState {}

final class StokLoading extends StokState {}

final class StokData extends StokState {
  final List<Product> barrelList;
  final List<Product> dispenserList;

  const StokData({required this.barrelList, required this.dispenserList});
}

final class StokError extends StokState {}

final class StokEmpty extends StokState {}
