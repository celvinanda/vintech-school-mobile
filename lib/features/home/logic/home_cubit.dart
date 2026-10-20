import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit(this._repository) : super(HomeInitial());

  Future<void> loadDashboard() async {
    emit(HomeLoading());
    try {
      final dashboard = await _repository.getCurrentSchoolDashboard();
      emit(HomeLoaded(dashboard));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
