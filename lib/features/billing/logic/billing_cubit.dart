import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/billing_repository.dart';
import 'billing_state.dart';

class BillingCubit extends Cubit<BillingState> {
  final BillingRepository _repository;

  BillingCubit(this._repository) : super(BillingInitial());

  Future<void> loadInvoices({
    String filter = 'ALL',
    String? studentNis,
    bool silent = false,
  }) async {
    // 1. Baca instan dari Hive Database Lokal (0 ms Latency)
    final cached = _repository.getCachedInvoices(
      status: filter == 'ALL' ? null : filter,
      studentNis: studentNis,
    );
    if (cached != null) {
      emit(BillingLoaded(invoices: cached, currentFilter: filter));
    } else if (state is! BillingLoaded && !silent) {
      emit(BillingLoading());
    }

    // 2. Sinkronisasi dengan Cloud Server di latar belakang
    try {
      final invoices = await _repository.getInvoices(
        status: filter == 'ALL' ? null : filter,
        studentNis: studentNis,
      );
      emit(BillingLoaded(invoices: invoices, currentFilter: filter));
    } catch (e) {
      if (state is! BillingLoaded && cached == null) {
        emit(BillingError(e.toString()));
      }
    }
  }

  Future<void> initiateCheckout(String invoiceNumber) async {
    try {
      final updatedInvoice = await _repository.initiateCheckout(invoiceNumber);
      emit(CheckoutInitiated(updatedInvoice));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }
}
