import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../academic/data/models/student_model.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/logic/auth_cubit.dart';
import '../../../core/theme/app_theme.dart';

/// Halaman Edit Profil Khusus Orang Tua / Wali Murid
/// Dirancang khusus agar orang tua dapat memperbarui data kontak, NIK, dan domisili
/// secara mandiri sehingga pihak Tata Usaha (TU) sekolah tidak kesulitan mencari informasi.
class ParentEditProfileScreen extends StatefulWidget {
  final UserProfileResponse profile;
  final StudentModel? student;
  const ParentEditProfileScreen({
    super.key,
    required this.profile,
    this.student,
  });
  @override
  State<ParentEditProfileScreen> createState() =>
      _ParentEditProfileScreenState();
}

class _ParentEditProfileScreenState extends State<ParentEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _nikController;
  late TextEditingController _occupationController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _addressController;
  late String _relationship;
  bool _isLoading = false;
  Color get _schoolColor =>
      AppTheme.parseHexColor(widget.profile.activeSchool?.primaryColor);
  StudentModel? get _effectiveStudent =>
      widget.student ?? widget.profile.primaryChild;
  @override
  void initState() {
    super.initState();
    final user = widget.profile.user;
    final child = _effectiveStudent;
    _nameController = TextEditingController(text: user.fullName);
    _phoneController = TextEditingController(
      text: user.phone.isNotEmpty && user.phone != '+62 812-3456-7890'
          ? user.phone
          : (child?.parentPhone ?? ''),
    );
    _emailController = TextEditingController(text: user.email);
    _nikController = TextEditingController(text: user.nik);
    _occupationController = TextEditingController(text: user.occupation);
    _emergencyPhoneController = TextEditingController(
      text: user.emergencyPhone,
    );
    _addressController = TextEditingController(text: user.address);
    _relationship = user.parentRelationship.isNotEmpty
        ? user.parentRelationship
        : 'Ayah Kandung';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nikController.dispose();
    _occupationController.dispose();
    _emergencyPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      final authCubit = context.read<AuthCubit>();
      await authCubit.updateProfile(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        parentRelationship: _relationship,
        nik: _nikController.text.trim(),
        occupation: _occupationController.text.trim(),
        emergencyPhone: _emergencyPhoneController.text.trim(),
        address: _addressController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '✓ Data profil orang tua berhasil diperbarui & disinkronkan ke Tata Usaha (TU)!',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF007D55),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _effectiveStudent;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Data Orang Tua / Wali',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Sinkronisasi Langsung ke Tata Usaha (TU)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFECEEF0)),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            physics: const BouncingScrollPhysics(),
            children: [
              // Banner Penjelasan TU
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pembaruan Mandiri untuk Tata Usaha (TU)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Data kontak, NIK, dan domisili yang Anda simpan di sini akan langsung tercatat di Buku Induk TU sekolah untuk keperluan pendataan Dapodik, komunikasi darurat, surat dispensasi, dan penagihan SPP.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFF1E40AF),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // BENTO 1: Data Identitas Orang Tua
              _buildSectionCard(
                title: 'Data Identitas Orang Tua / Wali',
                icon: Icons.person_rounded,
                iconColor: const Color(0xFF004AC6),
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nama Lengkap Orang Tua / Wali *',
                    hintText: 'Contoh: Bpk. Pratama Hendrawan',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama orang tua tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Hubungan dengan Siswa',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Ayah Kandung', 'Ibu Kandung', 'Wali Murid'].map(
                      (rel) {
                        final isSelected = _relationship == rel;
                        return ChoiceChip(
                          label: Text(rel),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _relationship = rel);
                          },
                          selectedColor: _schoolColor.withValues(alpha: 0.15),
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? _schoolColor
                                : const Color(0xFF475569),
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? _schoolColor
                                : const Color(0xFFCBD5E1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _nikController,
                    label: 'NIK (Nomor Induk Kependudukan)',
                    hintText: '16 digit NIK KTP',
                    keyboardType: TextInputType.number,
                    helperText: 'Dibutuhkan oleh TU untuk sinkronisasi resmi Dapodik Kemdikbud',
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _occupationController,
                    label: 'Pekerjaan / Instansi',
                    hintText: 'Contoh: Wiraswasta / Karyawan Swasta / PNS',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // BENTO 2: Kontak Komunikasi Aktif (Prioritas TU)
              _buildSectionCard(
                title: 'Kontak Komunikasi Aktif & Darurat',
                icon: Icons.contact_phone_rounded,
                iconColor: const Color(0xFF007D55),
                children: [
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Nomor WhatsApp / HP Utama *',
                    hintText: 'Contoh: 0811992201 atau 08123456789',
                    keyboardType: TextInputType.phone,
                    helperText: 'Nomor utama untuk notifikasi absensi, darurat & tagihan SPP',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nomor HP tidak boleh kosong';
                      }
                      if (val.trim().length < 9) {
                        return 'Nomor HP minimal 9 digit angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Alamat Email Aktif',
                    hintText: 'nama@email.com',
                    keyboardType: TextInputType.emailAddress,
                    helperText:
                        'Untuk pengiriman E-Rapor digital & kwitansi resmi SPP',
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _emergencyPhoneController,
                    label: 'Kontak Darurat Alternatif (Kerabat / Saudara)',
                    hintText: 'Contoh: 0812-9988-7711 (Ibu / Paman)',
                    keyboardType: TextInputType.phone,
                    helperText: 'Dihubungi jika nomor utama orang tua tidak dapat dihubungi saat darurat',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // BENTO 3: Alamat Domisili Keluarga
              _buildSectionCard(
                title: 'Alamat Domisili Tempat Tinggal',
                icon: Icons.location_on_rounded,
                iconColor: const Color(0xFFD97706),
                children: [
                  _buildTextField(
                    controller: _addressController,
                    label: 'Alamat Lengkap Rumah',
                    hintText:
                        'Nama Jalan, RT/RW, No. Rumah, Kelurahan, Kecamatan',
                    maxLines: 2,
                    helperText: 'Memudahkan TU jika memerlukan surat dinas atau kunjungan rumah',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // BENTO 4: Data Siswa Terikat (Terverifikasi TU - Read Only)
              if (child != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFECEEF0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              size: 18,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Siswa Terikat yang Diampu',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Tercatat di Buku Induk Siswa TU',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFA7F3D0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 12,
                                  color: Color(0xFF007D55),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Dapodik Valid',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF007D55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama Siswa',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                child.fullName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Kelas & Rombel',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                child.classroomName ?? 'Kelas X-IPA-1',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: _schoolColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'NIS: ${child.nis}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              color: const Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'NISN: ${child.nisn ?? "-"}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              color: const Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFECEEF0))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleSave,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_rounded, size: 18),
            label: Text(
              _isLoading
                  ? 'Menyinkronkan ke TU...'
                  : 'Simpan & Sinkronkan ke TU',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AC6),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECEEF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 17),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF94A3B8),
            ),
            helperText: helperText,
            helperMaxLines: 2,
            helperStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF004AC6),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
