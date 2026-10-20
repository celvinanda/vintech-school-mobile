import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/billing_repository.dart';
import 'billing_state.dart';

class BillingCubit extends Cubit<BillingState> {
  final BillingRepository _repository;

  BillingCubit(this._repository) : super(BillingInitial());

  Future<void> loadInvoices({String filter = 'ALL', String? studentNis}) async {
    emit(BillingLoading());
    try {
      final invoices = await _repository.getInvoices(
        status: filter == 'ALL' ? null : filter,
        studentNis: studentNis,
      );
      emit(BillingLoaded(invoices: invoices, currentFilter: filter));
    } catch (e) {
      emit(BillingError(e.toString()));
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
