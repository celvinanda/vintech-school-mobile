---
name: blueprint
description: >-
  Generate exhaustive, enterprise-grade architecture blueprints, lifecycle flowcharts,
  and technical specifications for any screen, module, or feature in Flutter and mobile
  codebases. Activate when the user asks for a blueprint, architecture breakdown,
  component hierarchy, lifecycle flowchart, or types /blueprint. Outputs a permanent
  markdown artifact with Mermaid flowcharts, visual component trees, state/BLoC handshakes,
  motion physics, and reliability metrics.
---

# Blueprint Generator for Mobile & Flutter Applications

Prosedur standar untuk mengaudit, membedah, dan menyusun **Cetak Biru Teknis Standar Enterprise** (*Executive Architectural Blueprint*) untuk setiap layar, fitur, widget, maupun subsistem dalam aplikasi.

---

## 1. Kapan Menggunakan Skill Ini

Gunakan skill ini setiap kali:
* Pengguna mengetik perintah slash command: `/blueprint` atau `/blueprint [nama_layar/fitur]`.
* Pengguna meminta: *"Beri saya alur dan blueprintnya"*, *"Jelaskan komponen dan kerangka kerja di dalamnya"*, atau *"Buatkan dokumen arsitektur teknis lengkap"*.
* Sebelum melakukan refactoring besar pada modul kompleks untuk memetakan arsitektur yang ada dan mencegah regresi.

---

## 2. Struktur Dokumen Blueprint Wajib (The 6 Pillars)

Setiap dokumen blueprint yang dihasilkan **WAJIB** disimpan sebagai file artifak markdown (`.md`) permanen di direktori artifak percakapan (`<artifactDir>/[nama_modul]_architecture_blueprint.md`) dengan 6 pilar berikut:

### Pilar 1: Lifecycle & Data Flowchart (Mermaid)
Gunakan diagram Mermaid `flowchart TD` untuk memvisualisasikan alur hidup layar:
* Titik awal: *Mounting / Widget Lifecycle* (`initState()`).
* Jalur paralel: Pipeline UI/Motion vs Pipeline Data/Autentikasi (Hive/API).
* Titik temu (*Handshake Point*): Evaluasi state BLoC/Cubit + Dwell timing.
* Handoff navigasi & transisi halaman tujuan.
* Sistem pengaman (*Fail-Safe Watchdog Timer*).

### Pilar 2: Visual Component Hierarchy & Coordinate Architecture
Gambarkan pohon dekonstruksi komponen menggunakan diagram box ASCII atau Mermaid:
* Koordinat Root (`StackFit.expand`, `Positioned.fill`, `SafeArea`, `SizedBox(width: double.infinity)`).
* Isolasi layer GPU: Identifikasi widget yang dibungkus `RepaintBoundary` untuk mencegah alokasi ulang GPU.
* Komponen kustom: CustomPainter (*zero-heap allocation*), Badge Pill, Icon Button, Typography.
* Tipografi: Verifikasi penggunaan 100% Plus Jakarta Sans atau font desain sistem yang disepakati.

### Pilar 3: State Management & Offline-First Handshake
Petakan aliran data dan state machine:
* BLoC / Cubit yang terlibat (misal `AuthCubit`, `HomeCubit`, `AttendanceCubit`).
* Sumber data lokal (Hive multi-box storage, SharedPreferences, SQLite) vs Cloud API.
* Siklus *Synchronous State Read* (`initState` / `addPostFrameCallback`) vs *Stream Subscription* (`BlocListener`).
* Penanganan race conditions (menghindari state yang terlewat sebelum listener mount).

### Pilar 4: Motion Physics & Animation Specifications
Rincikan setiap animasi yang berjalan di modul tersebut dalam bentuk tabel spesifikasi:
* Controller durasi & kurva (misal `CurvedAnimation(curve: Cubic(0.05, 0.70, 0.10, 1.00))`).
* Magnitudo gerakan: Pergeseran piksel nyata (`Offset(0.0, 0.08)` / ~90px) dan skala mekar (`0.925 -> 1.000`).
* Pacing & Dwell Time: Waktu jeda visual yang memberikan sensasi *warm & welcoming*.
* Sentuhan Haptik: Penggunaan `HapticFeedback.lightImpact()` atau `selectionClick()`.

### Pilar 5: Reliability & Fail-Safe Mechanisms
* Watchdog timer anti-stuck (durasi fallback aman, misal 2200ms - 2500ms).
* Penanganan error jaringan (timeout, 401 unauthenticated, offline mode).
* Algoritma tombol kembali pintar (*Smart Back Button* / *Double-Tap to Exit*).

### Pilar 6: Performance & Memory Footprint Metrics
Tabel verifikasi performa teknis:
* Target FPS (misal: 120 FPS solid pada Impeller Vulkan / OpenGLES).
* Heap allocation per frame (0 bytes untuk CustomPainter).
* Hasil pengujian statis Dart (`flutter analyze --no-fatal-infos`: 0 issues).
* Hasil unit test suite (`flutter test`).

---

## 3. Langkah Kerja Eksekusi Agen (Step-by-Step Execution)

1. **Identifikasi Target**:
   * Temukan file representasi utama (misal: `lib/features/.../presentation/..._screen.dart`).
   * Temukan BLoC/Cubit terkait (`logic/..._cubit.dart` dan `data/models/...`).
2. **Deep Code Audit**:
   * Baca file target untuk memeriksa layout constraints, animation controllers, listener timing, dan storage access.
3. **Generate Artifact Markdown**:
   * Gunakan tool `write_file` dengan `ArtifactMetadata` (`UserFacing: true`, `RequestFeedback: false`).
   * Tulis blueprint lengkap sesuai struktur 6 pilar di atas.
4. **Validasi & Lapor**:
   * Informasikan kepada pengguna bahwa blueprint telah selesai dibuat dan tautkan langsung ke artifak file `file:///...` yang dihasilkan.
