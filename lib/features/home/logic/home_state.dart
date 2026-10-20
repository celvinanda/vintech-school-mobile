import '../data/models/school_dashboard_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final SchoolDashboardModel dashboard;
  HomeLoaded(this.dashboard);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
