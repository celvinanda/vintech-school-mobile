import '../data/models/invoice_model.dart';

abstract class BillingState {}

class BillingInitial extends BillingState {}

class BillingLoading extends BillingState {}

class BillingLoaded extends BillingState {
  final List<InvoiceModel> invoices;
  final String currentFilter; // 'ALL', 'UNPAID', 'PAID'

  BillingLoaded({
    required this.invoices,
    this.currentFilter = 'ALL',
  });

  BillingLoaded copyWith({
    List<InvoiceModel>? invoices,
    String? currentFilter,
  }) {
    return BillingLoaded(
      invoices: invoices ?? this.invoices,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class CheckoutInitiated extends BillingState {
  final InvoiceModel invoice;
  CheckoutInitiated(this.invoice);
}

class BillingError extends BillingState {
  final String message;
  BillingError(this.message);
}
