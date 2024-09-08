abstract class HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Map<String, dynamic>> results;
  HomeLoaded(this.results);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
