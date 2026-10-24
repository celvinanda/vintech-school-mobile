class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String periodLabel;
  final int amount;
  final String amountDisplay;
  final String status; // UNPAID, PENDING, PAID, OVERDUE, CANCELLED
  final String statusDisplay;
  final String? dueDate;
  final String? paidAt;
  final String? paymentChannel;
  final String? checkoutUrl;
  final String feeCategoryName;
  final String studentNis;
  final String studentName;
  final String? classroomName;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.periodLabel,
    required this.amount,
    required this.amountDisplay,
    required this.status,
    required this.statusDisplay,
    this.dueDate,
    this.paidAt,
    this.paymentChannel,
    this.checkoutUrl,
    required this.feeCategoryName,
    required this.studentNis,
    required this.studentName,
    this.classroomName,
  });

  bool get isPaid => status == 'PAID';
  bool get isUnpaid => status == 'UNPAID' || status == 'OVERDUE' || status == 'PENDING';

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final vintechPay = json['vintech_payment'] as Map<String, dynamic>? ?? {};
    final feeCat = json['fee_category'] as Map<String, dynamic>? ?? {};
    final student = json['student'] as Map<String, dynamic>? ?? {};

    String? classroomName;
    final rawClassroom = student['classroom'] ?? json['classroom'];
    if (rawClassroom is Map) {
      classroomName = rawClassroom['name'] as String?;
    } else if (rawClassroom is String) {
      classroomName = rawClassroom;
    }

    return InvoiceModel(
      id: json['id'] as String? ?? '',
      invoiceNumber: json['invoice_number'] as String? ?? '',
      periodLabel: json['period_label'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      amountDisplay: json['amount_display'] as String? ?? 'Rp ${json['amount'] ?? 0}',
      status: json['status'] as String? ?? 'UNPAID',
      statusDisplay: json['status_display'] as String? ?? json['status'] as String? ?? 'Belum Lunas',
      dueDate: json['due_date'] as String?,
      paidAt: json['paid_at'] as String?,
      paymentChannel: json['payment_channel'] as String?,
      checkoutUrl: vintechPay['checkout_url'] as String?,
      feeCategoryName: feeCat['name'] as String? ?? 'SPP',
      studentNis: student['nis'] as String? ?? '',
      studentName: student['full_name'] as String? ?? '',
      classroomName: classroomName,
    );
  }
}
