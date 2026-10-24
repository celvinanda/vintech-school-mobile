import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_or_error_view.dart';
import '../../auth/data/models/user_model.dart';
import '../data/models/invoice_model.dart';
import '../logic/billing_cubit.dart';
import '../logic/billing_state.dart';

class BillingScreen extends StatefulWidget {
  final UserProfileResponse profile;

  const BillingScreen({super.key, required this.profile});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  String _selectedFilter = 'ALL'; // ALL, UNPAID, PAID

  bool get _isStudent => widget.profile.activeSchool?.isStudent == true;
  Color get _schoolColor => AppTheme.parseHexColor(widget.profile.activeSchool?.primaryColor);

  /// Menggunakan NIS bersih (contoh: "20261001") agar cocok dengan query backend
  String? get _studentNisFilter =>
      _isStudent ? widget.profile.user.cleanIdentifier : null;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  void _fetchInvoices() {
    context.read<BillingCubit>().loadInvoices(
          filter: _selectedFilter,
          studentNis: _studentNisFilter,
        );
  }

  void _onSelectFilter(String filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
    });
    _fetchInvoices();
  }

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp $buffer';
  }

  void _showCheckoutSheet(InvoiceModel invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E).withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Color(0xFF0F766E),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Vintech Pay Checkout',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Nomor Invoice', invoice.invoiceNumber, isMono: true),
                  const SizedBox(height: 10),
                  _buildDetailRow('Nama Siswa', '${invoice.studentName} (${invoice.studentNis})'),
                  const SizedBox(height: 10),
                  _buildDetailRow('Kategori & Periode', '${invoice.feeCategoryName} • ${invoice.periodLabel}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        invoice.amountDisplay,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF0F766E)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mendukung QRIS (GoPay, OVO, Dana, M-Banking) & Virtual Account.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (invoice.checkoutUrl != null && invoice.checkoutUrl!.isNotEmpty) {
                    final uri = Uri.parse(invoice.checkoutUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  } else {
                    context.read<BillingCubit>().initiateCheckout(invoice.invoiceNumber);
                  }
                },
                icon: const Icon(Icons.lock_open_rounded, size: 18),
                label: const Text('Lanjutkan ke Pembayaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMono = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            color: const Color(0xFF64748B),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: isMono
                ? GoogleFonts.jetBrainsMono(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  )
                : GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillingCubit, BillingState>(
      listener: (context, state) {
        if (state is CheckoutInitiated) {
          if (state.invoice.checkoutUrl != null && state.invoice.checkoutUrl!.isNotEmpty) {
            final uri = Uri.parse(state.invoice.checkoutUrl!);
            launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesi pembayaran Vintech Pay siap digunakan.'),
                backgroundColor: AppTheme.success,
              ),
            );
          }
          _fetchInvoices();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Tagihan SPP & Biaya'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Muat Ulang',
              onPressed: _fetchInvoices,
            ),
          ],
        ),
        body: Column(
          children: [
            // Modern Segmented Filter Pills
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Row(
                children: [
                  _buildFilterTab('ALL', 'Semua'),
                  const SizedBox(width: 8),
                  _buildFilterTab('UNPAID', 'Belum Bayar'),
                  const SizedBox(width: 8),
                  _buildFilterTab('PAID', 'Lunas'),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Main Content
            Expanded(
              child: BlocBuilder<BillingCubit, BillingState>(
                builder: (context, state) {
                  if (state is BillingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is BillingError) {
                    return EmptyOrErrorView(
                      icon: Icons.receipt_long_outlined,
                      iconColor: AppTheme.danger,
                      title: 'Gagal Memuat Tagihan',
                      subtitle: state.message,
                      actionLabel: 'Coba Lagi',
                      onAction: _fetchInvoices,
                    );
                  }
                  if (state is BillingLoaded) {
                    final invoices = state.invoices;

                    if (invoices.isEmpty) {
                      return EmptyOrErrorView(
                        icon: Icons.verified_rounded,
                        iconColor: AppTheme.success,
                        title: 'Tidak Ada Tagihan',
                        subtitle: _selectedFilter == 'UNPAID'
                            ? 'Selamat! Seluruh tagihan SPP Anda telah lunas.'
                            : 'Belum ada data tagihan pada kategori filter ini.',
                        actionLabel: 'Segarkan',
                        onAction: _fetchInvoices,
                      );
                    }

                    final unpaidList = invoices.where((i) => !i.isPaid).toList();
                    final paidList = invoices.where((i) => i.isPaid).toList();
                    final totalUnpaidAmount =
                        unpaidList.fold<int>(0, (sum, item) => sum + item.amount);

                    return RefreshIndicator(
                      color: _schoolColor,
                      onRefresh: () async => _fetchInvoices(),
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          // Top Financial Summary Banner
                          _buildSummaryBanner(
                            totalCount: invoices.length,
                            unpaidCount: unpaidList.length,
                            paidCount: paidList.length,
                            totalUnpaidAmount: totalUnpaidAmount,
                          ),
                          const SizedBox(height: 18),

                          // Invoice List
                          ...invoices.map((inv) => _buildInvoiceCard(inv)),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: Material(
        color: isSelected ? _schoolColor : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _onSelectFilter(value),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBanner({
    required int totalCount,
    required int unpaidCount,
    required int paidCount,
    required int totalUnpaidAmount,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A),
            Color.lerp(const Color(0xFF0F172A), _schoolColor, 0.4)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                unpaidCount > 0 ? 'TAGIHAN BELUM DIBAYAR' : 'STATUS PEMBAYARAN SPP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withAlpha(170),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                unpaidCount > 0 ? _formatRupiah(totalUnpaidAmount) : 'Semua Lunas ✓',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$paidCount Lunas • $unpaidCount Menunggu Pembayaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: Colors.white.withAlpha(190),
                ),
              ),
            ],
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel inv) {
    final isPaid = inv.isPaid;
    final statusColor = isPaid ? const Color(0xFF16A34A) : const Color(0xFFEA580C);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: InkWell(
          onTap: isPaid ? null : () => _showCheckoutSheet(inv),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category + Period & Status Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${inv.feeCategoryName} • ${inv.periodLabel}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        inv.statusDisplay,
                        style: GoogleFonts.plusJakartaSans(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                if (!_isStudent && inv.studentName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${inv.studentName} (NIS: ${inv.studentNis})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Amount & Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      inv.amountDisplay,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (!isPaid)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _showCheckoutSheet(inv),
                        icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                        label: const Text(
                          'Bayar QRIS',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // Footer: Invoice Number & Due/Paid Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      inv.invoiceNumber,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      isPaid && inv.paidAt != null && inv.paidAt!.length >= 10
                          ? 'Lunas: ${inv.paidAt!.substring(0, 10)}'
                          : 'Jatuh Tempo: ${inv.dueDate ?? '-'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: isPaid ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
