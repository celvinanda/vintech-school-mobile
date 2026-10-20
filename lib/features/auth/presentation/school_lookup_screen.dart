import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';
import 'login_screen.dart';

class SchoolLookupScreen extends StatefulWidget {
  const SchoolLookupScreen({super.key});

  @override
  State<SchoolLookupScreen> createState() => _SchoolLookupScreenState();
}

class _SchoolLookupScreenState extends State<SchoolLookupScreen> {
  final TextEditingController _codeController = TextEditingController(text: 'SMAN1-JKT');
  final _formKey = GlobalKey<FormState>();

  void _onLookup() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().lookupSchool(_codeController.text.trim());
    }
  }

  void _showServerSettingsModal() {
    final storage = context.read<LocalStorage>();
    final serverController = TextEditingController(text: storage.getBaseUrl());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengaturan Server Backend',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gunakan 10.0.2.2:8001 untuk Emulator Android atau IP Wi-Fi laptop untuk Device Fisik.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: serverController,
              decoration: const InputDecoration(
                labelText: 'Backend Base URL',
                hintText: 'http://10.0.2.2:8001',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      serverController.text = 'http://10.0.2.2:8001';
                    },
                    child: const Text('Emulator'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      serverController.text = 'http://127.0.0.1:8001';
                    },
                    child: const Text('Localhost'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await storage.saveBaseUrl(serverController.text.trim());
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Base URL disimpan: ${serverController.text.trim()}'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  }
                },
                child: const Text('Simpan URL'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SchoolLookupSuccess) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LoginScreen(school: state.school),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Konfigurasi Server API',
              onPressed: _showServerSettingsModal,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.defaultPrimary.withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.domain_rounded,
                      color: AppTheme.defaultPrimary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Selamat Datang di\nVintech School',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMain,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masukkan Kode Sekolah resmi yang diberikan oleh pihak sekolah Anda untuk mulai terhubung.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Kode Sekolah',
                      hintText: 'Contoh: SMAN1-JKT',
                      prefixIcon: Icon(Icons.key_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Kode Sekolah wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _onLookup,
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Lanjutkan'),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'PILIH SEKOLAH DEMO (1-KLIK):',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDemoSchoolCard(
                    code: 'SMAN1-JKT',
                    name: 'SMA Negeri 1 Nusantara Jakarta',
                    tag: 'SMA • Enterprise',
                    color: const Color(0xFF1E3A8A),
                  ),
                  const SizedBox(height: 8),
                  _buildDemoSchoolCard(
                    code: 'SMK-VINTECH',
                    name: 'SMK Teknologi Vintech Bandung',
                    tag: 'SMK • Pro',
                    color: const Color(0xFF0F766E),
                  ),
                  const SizedBox(height: 8),
                  _buildDemoSchoolCard(
                    code: 'SMP-ALHIKMAH',
                    name: 'SMP IT Al-Hikmah',
                    tag: 'SMP • Starter',
                    color: const Color(0xFF047857),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoSchoolCard({
    required String code,
    required String name,
    required String tag,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _codeController.text = code;
        });
        context.read<AuthCubit>().lookupSchool(code);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$code • $tag',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
