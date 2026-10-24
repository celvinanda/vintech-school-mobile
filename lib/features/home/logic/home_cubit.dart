import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit(this._repository) : super(HomeInitial());

  Future<void> loadDashboard() async {
    // 1. Baca instan dari Hive Database Lokal (0 ms Latency)
    final cached = _repository.getCachedDashboard();
    if (cached != null && state is! HomeLoaded) {
      emit(HomeLoaded(cached));
    } else if (state is! HomeLoaded) {
      emit(HomeLoading());
    }

    // 2. Sinkronisasi dengan Cloud Server di latar belakang
    try {
      final dashboard = await _repository.getCurrentSchoolDashboard();
      emit(HomeLoaded(dashboard));
    } catch (e) {
      if (state is! HomeLoaded) {
        emit(HomeError(e.toString()));
      }
    }
  }
}
