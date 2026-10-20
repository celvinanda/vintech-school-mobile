# Vintech School Mobile (Android & iOS)

Aplikasi mobile resmi ekosistem **Vintech School** untuk platform **Android** dan **iOS** berbasis **Flutter (Clean Architecture & BLoC/Cubit)**.

---

## 📱 Fitur Utama Aplikasi Mobile

1. **Multi-Tenant Onboarding (Kode Sekolah)**
   - Masukkan Kode Sekolah (contoh: `SMAN1-JKT`, `SMK-VINTECH`, `SMP-ALHIKMAH`).
   - Tampilan tema (warna primer & logo sekolah) otomatis beradaptasi secara dinamis sesuai identitas sekolah masing-masing.

2. **Role-Based Experience**:
   - **Mode Siswa / Orang Tua**:
     - Kartu Pelajar Digital (NIS, Rombel, Nama Sekolah).
     - Ringkasan Kehadiran & Kalender Presensi.
     - Tagihan SPP & Biaya Sekolah.
     - Checkout Pembayaran Instan via **Vintech Payment Hub** (QRIS & Virtual Account Bank).
     - Feed Pengumuman Sekolah Resmi.
   - **Mode Guru / Staf**:
     - Input Presensi Cepat per Siswa (`HADIR`, `IZIN`, `SAKIT`, `ALPA`).
     - Statistik Kehadiran Siswa Real-Time.
     - Ringkasan Dashboard Sekolah (Total Siswa, Guru, Rombel).

3. **Multi-School Switcher**:
   - Khusus bagi akun orang tua yang memiliki anak di lebih dari satu sekolah di dalam jaringan Vintech School.

4. **Konfigurasi Server API Fleksibel**:
   - Pengaturan Base URL langsung dari aplikasi (`http://10.0.2.2:8001` untuk Android Emulator, `http://127.0.0.1:8001` untuk iOS Simulator/Web, atau IP LAN Wi-Fi untuk testing di HP fisik).

---

## 🚀 Cara Menjalankan

### Cara 1: Menggunakan Script Launcher (1-Klik)
Klik dua kali berkas:
👉 **[`run_app.bat`](file:///D:/Projects/vintech-school-mobile/run_app.bat)**

### Cara 2: Melalui Terminal / PowerShell
```powershell
cd D:\Projects\vintech-school-mobile

# Jalankan di Chrome untuk preview cepat
flutter run -d chrome

# Atau jalankan di Emulator Android / Device fisik
flutter run
```

---

## 🏛️ Arsitektur Kode (Clean Architecture)

```text
lib/
├── core/
│   ├── constants/       # Endpoint REST API v1 & timeout
│   ├── network/         # Dio Client, Auth Interceptor, & JSON Envelope Parser
│   ├── storage/         # SharedPreferences (Token Bearer, School Code, Profil)
│   └── theme/           # Dynamic Primary Color Theme (Material 3 + Plus Jakarta Sans)
├── features/
│   ├── auth/            # School Lookup, Login, Multi-School RBAC
│   ├── home/            # Dashboard Siswa & Guru, Pengumuman Sekolah
│   ├── academic/        # Presensi Kehadiran & Input Cepat Guru
│   ├── billing/         # Tagihan SPP & Integrasi Vintech Pay (QRIS/VA)
│   └── profile/         # Profil Akun, Switch Sekolah, Konfigurasi Server API
└── main.dart            # MultiBlocProvider & MultiRepositoryProvider App Root
```

---

## 🔑 Akun Demo Siap Pakai

| Role | Kode Sekolah | Username | Password |
| :--- | :--- | :--- | :--- |
| **Siswa** | `SMAN1-JKT` | `siswa.sman1jkt.20261001` | `siswa123` |
| **Guru** | `SMAN1-JKT` | `guru.sman1jkt.197804122005011002` | `guru123` |
| **Admin Sekolah** | `SMAN1-JKT` | `admin.sman1` | `admin123` |
| **Admin SMK** | `SMK-VINTECH` | `admin.smkvintech` | `admin123` |
| **Admin SMP** | `SMP-ALHIKMAH` | `admin.alhikmah` | `admin123` |
