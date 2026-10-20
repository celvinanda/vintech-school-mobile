import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
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

class _BillingScreenState extends State<BillingScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Initial load
    final studentNis = widget.profile.activeSchool?.isStudent == true
        ? widget.profile.user.username
        : null;
    context.read<BillingCubit>().loadInvoices(filter: 'ALL', studentNis: studentNis);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    String filter = 'ALL';
    if (_tabController.index == 1) filter = 'UNPAID';
    if (_tabController.index == 2) filter = 'PAID';

    final studentNis = widget.profile.activeSchool?.isStudent == true
        ? widget.profile.user.username
        : null;
    context.read<BillingCubit>().loadInvoices(filter: filter, studentNis: studentNis);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCheckoutSheet(InvoiceModel invoice) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pembayaran Vintech Pay',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nomor Tagihan'),
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Periode'),
                      Text(
                        invoice.periodLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Bayar',
                        style: TextStyle(fontWeight: FontWeight.w700),
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
            const SizedBox(height: 16),
            Text(
              'Metode Pembayaran: QRIS (Semua Bank / E-Wallet) & Virtual Account Otomatis.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (invoice.checkoutUrl != null && invoice.checkoutUrl!.isNotEmpty) {
                    final uri = Uri.parse(invoice.checkoutUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  } else {
                    // Trigger checkout API
                    context.read<BillingCubit>().initiateCheckout(invoice.invoiceNumber);
                  }
                },
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Buka Gateway Pembayaran'),
              ),
            ),
          ],
        ),
      ),
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
                content: Text('Sesi pembayaran siap digunakan.'),
                backgroundColor: AppTheme.success,
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tagihan SPP & Biaya'),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppTheme.textMain,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.defaultPrimary,
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Belum Bayar'),
              Tab(text: 'Lunas'),
            ],
          ),
        ),
        body: BlocBuilder<BillingCubit, BillingState>(
          builder: (context, state) {
            if (state is BillingLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BillingError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long_outlined, color: AppTheme.danger, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _onTabChanged(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is BillingLoaded) {
              final invoices = state.invoices;

              if (invoices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 56,
                        color: AppTheme.success.withAlpha(150),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada tagihan pada filter ini.',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _onTabChanged(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final inv = invoices[index];
                    final isPaid = inv.isPaid;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? AppTheme.success.withAlpha(20)
                                      : AppTheme.danger.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  inv.statusDisplay,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: isPaid ? AppTheme.success : AppTheme.danger,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                inv.periodLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppTheme.textMain,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inv.feeCategoryName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    inv.amountDisplay,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textMain,
                                    ),
                                  ),
                                ],
                              ),
                              if (!isPaid)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F766E),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                  ),
                                  onPressed: () => _showCheckoutSheet(inv),
                                  icon: const Icon(Icons.payment_rounded, size: 16),
                                  label: const Text('Bayar', style: TextStyle(fontSize: 13)),
                                ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'No: ${inv.invoiceNumber}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              Text(
                                isPaid && inv.paidAt != null
                                    ? 'Lunas: ${inv.paidAt!.substring(0, 10)}'
                                    : 'Jatuh Tempo: ${inv.dueDate ?? '-'}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: isPaid ? AppTheme.success : AppTheme.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
