import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vintech_school_mobile/features/academic/data/models/attendance_model.dart';
import 'package:vintech_school_mobile/features/academic/presentation/attendance_entry_sheet.dart';
import 'package:vintech_school_mobile/features/academic/presentation/widgets/teacher_attendance/models/class_attendance_info.dart';
import 'package:vintech_school_mobile/features/auth/data/models/user_model.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vintech_school_mobile/features/academic/logic/attendance_cubit.dart';
import 'package:vintech_school_mobile/features/academic/logic/attendance_state.dart';

import 'dialogs/add_class_note_dialog.dart';
import 'dialogs/class_batch_attendance_sheet.dart';
import 'dialogs/class_switcher_sheet.dart';
import 'dialogs/manage_officers_sheet.dart';
import 'dialogs/manage_schedule_piket_sheet.dart';
import 'models/class_student_item.dart';
import 'widgets/class_management_hero_card.dart';
import 'widgets/class_management_tab_bar.dart';
import 'widgets/tabs/class_notes_tab_view.dart';
import 'widgets/tabs/class_officers_tab_view.dart';
import 'widgets/tabs/class_schedule_tab_view.dart';
import 'widgets/tabs/class_student_tab_view.dart';

/// Screen: Manajemen Kelas - Vintech School
/// Berdasarkan Canvas Stitch ID: a8059983028846eba091b26887c8ff82
class ClassManagementScreen extends StatefulWidget {
  final ClassAttendanceInfo classInfo;
  final List<ClassAttendanceInfo> allClasses;
  final UserProfileResponse profile;
  final List<AttendanceModel> allRecords;
  final Color schoolColor;

  const ClassManagementScreen({
    super.key,
    required this.classInfo,
    required this.allClasses,
    required this.profile,
    required this.allRecords,
    required this.schoolColor,
  });

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  late ClassAttendanceInfo _currentClass;
  late PageController _pageController;
  int _activeTabIndex =
      0; // 0: Siswa, 1: Pengurus, 2: Jadwal & Piket, 3: Catatan

  late List<ClassStudentItem> _students;
  late List<ClassOfficerItem> _officers;
  late List<ClassNoteItem> _notes;

  @override
  void initState() {
    super.initState();
    _currentClass = widget.classInfo;
    _pageController = PageController(initialPage: _activeTabIndex);
    _loadDataForCurrentClass();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isSameClass(String? a, String? b) {
    if (a == null || b == null) return false;
    final cleanA = a
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .toLowerCase()
        .trim();
    final cleanB = b
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .toLowerCase()
        .trim();
    return cleanA == cleanB;
  }

  void _loadDataForCurrentClass({List<AttendanceModel>? freshAttendances}) {
    final cubit = context.read<AttendanceCubit>();
    final allStudents = cubit.cachedStudents;
    final matchingStudents = allStudents.where((s) {
      if (s.classroomName == null || s.classroomName!.isEmpty) return true;
      return _isSameClass(s.classroomName, _currentClass.className);
    }).toList();

    final List<AttendanceModel> attendances;
    if (freshAttendances != null && freshAttendances.isNotEmpty) {
      attendances = freshAttendances;
    } else if (cubit.cachedAttendances.isNotEmpty) {
      attendances = cubit.cachedAttendances;
    } else if (cubit.state is AttendanceLoaded) {
      attendances = (cubit.state as AttendanceLoaded).attendances;
    } else {
      attendances = widget.allRecords;
    }

    _students = ClassStudentItem.fromRealData(
      students: matchingStudents,
      attendances: attendances,
      info: _currentClass,
    );

    // Hitung ulang KPI riil agar banner atas langsung tersinkron seketika
    int hadir = 0, sakit = 0, izin = 0, alpa = 0;
    for (final s in _students) {
      switch (s.status.toUpperCase()) {
        case 'HADIR':
        case 'DISPENSASI':
          hadir++;
          break;
        case 'SAKIT':
          sakit++;
          break;
        case 'IZIN':
          izin++;
          break;
        case 'ALPA':
          alpa++;
          break;
      }
    }

    _currentClass = _currentClass.copyWith(
      hadirCount: hadir,
      sakitCount: sakit,
      izinCount: izin,
      alpaCount: alpa,
      totalStudents: _students.length,
      progressText: 'Progress: ${_students.length} / ${_students.length} Siswa',
    );

    final teacherName = widget.profile.user.fullName.isNotEmpty
        ? widget.profile.user.fullName
        : 'Dani Hermawan, S.Kom';
    _officers = ClassOfficerItem.generateDefaultOfficers(teacherName);
    _notes = ClassNoteItem.generateDefaultNotes();
  }

  void _switchClass(ClassAttendanceInfo newClass) {
    setState(() {
      _currentClass = newClass;
      _loadDataForCurrentClass();
    });
  }

  void _openAddNoteDialog() {
    AddClassNoteDialog.show(
      context,
      students: _students,
      onNoteAdded: (newNote) {
        setState(() {
          _notes.insert(0, newNote);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Catatan untuk ${newNote.studentName} berhasil ditambahkan!',
              style: GoogleFonts.plusJakartaSans(fontSize: 12),
            ),
            backgroundColor: const Color(0xFF007D55),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _showStudentDetail(ClassStudentItem student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      student.number,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF004AC6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'NISN: ${student.nisn} • ${student.gender}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Status Kehadiran',
                student.status,
                color: student.status == 'HADIR'
                    ? const Color(0xFF059669)
                    : (student.status == 'ALPA'
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFD97706)),
              ),
              _buildDetailRow(
                'Tingkat Kehadiran',
                '${student.attendancePercent.toInt()}%',
              ),
              if (student.roleBadge != null)
                _buildDetailRow('Jabatan Kelas', student.roleBadge!),
              if (student.attentionNote != null)
                _buildDetailRow(
                  'Catatan Khusus',
                  student.attentionNote!,
                  color: const Color(0xFFDC2626),
                ),
              _buildDetailRow(
                'Kontak Wali Siswa',
                student.parentPhone ?? '0812-9876-5432',
              ),
              const SizedBox(height: 20),
              // Aksi Cepat Input Presensi Siswa Terpilih
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit_square, size: 18),
                  label: Text(
                    'Input Presensi ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007D55),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (_) => AttendanceEntrySheet(
                        initialStudentNis: student.effectiveNis,
                      ),
                    );
                    if (mounted) {
                      setState(() {
                        _loadDataForCurrentClass();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chat_outlined, size: 18),
                      label: const Text('Chat Wali'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Color(0xFF004AC6)),
                        foregroundColor: const Color(0xFF004AC6),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleChatStudent(student);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: const Text('Telepon'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF004AC6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleCallStudent(student);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  void _handleChatStudent(ClassStudentItem student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Membuka pesan langsung untuk ${student.name}...',
          style: GoogleFonts.plusJakartaSans(fontSize: 12),
        ),
        backgroundColor: const Color(0xFF004AC6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleCallStudent(ClassStudentItem student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hubungi Orang Tua/Wali',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Panggilan telepon ke wali dari ${student.name} (${student.parentPhone ?? "0812-9876-5432"})?\n\nAlasan: ${student.attentionNote ?? "Koordinasi Kehadiran"}',
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Menghubungkan telepon ke wali ${student.name}...',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  ),
                  backgroundColor: const Color(0xFF007D55),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AC6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Panggil Sekarang'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teacherName = widget.profile.user.fullName.isNotEmpty
        ? widget.profile.user.fullName
        : 'Dani Hermawan, S.Kom';

    return BlocConsumer<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceLoaded) {
          setState(() {
            _loadDataForCurrentClass(freshAttendances: state.attendances);
          });
        } else if (state is AttendanceActionSuccess) {
          setState(() {
            _loadDataForCurrentClass();
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC), // surface
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF0F172A),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Manajemen Kelas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            actions: [
              // Class Switcher Pill
              Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ClassSwitcherSheet.show(
                      context,
                      allClasses: widget.allClasses,
                      selectedClass: _currentClass,
                      onSelectClass: _switchClass,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentClass.className,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF004AC6),
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Color(0xFF004AC6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Filter Rombel',
                icon: const Icon(Icons.tune_rounded, color: Color(0xFF64748B)),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ClassSwitcherSheet.show(
                    context,
                    allClasses: widget.allClasses,
                    selectedClass: _currentClass,
                    onSelectClass: _switchClass,
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: ClassManagementHeroCard(
                    classInfo: _currentClass,
                    homeroomTeacher: teacherName,
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedTabBarDelegate(
                  height: 52,
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ClassManagementTabBar(
                      selectedIndex: _activeTabIndex,
                      onTabChanged: (index) {
                        setState(() => _activeTabIndex = index);
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
            body: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                HapticFeedback.selectionClick();
                setState(() => _activeTabIndex = index);
              },
              children: [
                RefreshIndicator(
                  color: const Color(0xFF007D55),
                  onRefresh: () async {
                    await context.read<AttendanceCubit>().loadAttendances(
                      isStaff: true,
                      forceRefreshMeta: true,
                    );
                    if (mounted) {
                      setState(() {
                        _loadDataForCurrentClass();
                      });
                    }
                  },
                  child: SingleChildScrollView(
                    primary: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    child: ClassStudentTabView(
                      students: _students,
                      onStudentTap: _showStudentDetail,
                      onChatTap: _handleChatStudent,
                      onCallTap: _handleCallStudent,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  primary: false,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  child: ClassOfficersTabView(
                    officers: _officers,
                    onContactTap: (ClassOfficerItem officer) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Menghubungi ${officer.role} (${officer.name})...',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12),
                          ),
                          backgroundColor: const Color(0xFF004AC6),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                const SingleChildScrollView(
                  primary: false,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 80),
                  child: ClassScheduleTabView(),
                ),
                SingleChildScrollView(
                  primary: false,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  child: ClassNotesTabView(notes: _notes),
                ),
              ],
            ),
          ),
          floatingActionButton: _buildContextualFab(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  /// FAB Cerdas Kontekstual yang otomatis menyesuaikan fungsinya dengan tab aktif
  Widget _buildContextualFab() {
    IconData icon;
    String label;
    VoidCallback onTap;

    switch (_activeTabIndex) {
      case 0:
        icon = Icons.playlist_add_check_rounded;
        label = 'Mulai Presensi';
        onTap = () {
          HapticFeedback.lightImpact();
          ClassBatchAttendanceSheet.show(
            context,
            classInfo: _currentClass,
            students: _students,
            onSaved: () async {
              // 1. Segarkan tampilan seketika (0 ms)
              if (mounted) {
                setState(() {
                  _loadDataForCurrentClass();
                });
              }
              // 2. Sinkronkan dengan data server di latar belakang
              await context.read<AttendanceCubit>().loadAttendances(
                isStaff: true,
              );
              if (mounted) {
                setState(() {
                  _loadDataForCurrentClass();
                });
              }
            },
          );
        };
        break;
      case 1:
        icon = Icons.manage_accounts_rounded;
        label = 'Kelola Pengurus';
        onTap = () {
          HapticFeedback.lightImpact();
          ManageOfficersSheet.show(
            context,
            currentOfficers: _officers,
            students: _students,
            onOfficersUpdated: (updated) {
              setState(() => _officers = updated);
            },
          );
        };
        break;
      case 2:
        icon = Icons.edit_calendar_rounded;
        label = 'Atur Jadwal & Piket';
        onTap = () {
          HapticFeedback.lightImpact();
          ManageSchedulePiketSheet.show(context, students: _students);
        };
        break;
      case 3:
      default:
        icon = Icons.edit_note_rounded;
        label = 'Tambah Catatan';
        onTap = () {
          HapticFeedback.lightImpact();
          _openAddNoteDialog();
        };
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: FloatingActionButton.extended(
        key: ValueKey<int>(_activeTabIndex),
        onPressed: onTap,
        backgroundColor: const Color(0xFF004AC6),
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 6,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }
}

/// Delegate untuk menyematkan Tab Bar di posisi teratas saat discroll
class _PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _PinnedTabBarDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedTabBarDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
