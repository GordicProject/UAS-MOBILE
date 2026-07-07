# 08 — Panduan Deploy & Instalasi

Panduan ini untuk menjalankan aplikasi dari nol di komputer baru. Cocok untuk dosen penguji yang ingin mereplikasi demo.

## 8.1 Prasyarat

| Software | Versi Minimum | Download |
|---|---|---|
| **Flutter SDK** | 3.16+ | https://docs.flutter.dev/get-started/install |
| **Dart SDK** | 3.2+ | (included in Flutter) |
| **Android Studio** | 2023+ | https://developer.android.com/studio |
| **Android Emulator** | API 30+ (Android 11+) | included in Android Studio |
| **VS Code** (opsional) | latest | https://code.visualstudio.com |
| **Git** | 2.30+ | https://git-scm.com |
| **Akun Supabase** | free | https://supabase.com |

Cek instalasi:
```bash
flutter --version
flutter doctor
```

## 8.2 Clone atau Copy Proyek

```bash
# Jika ada di GitHub:
git clone https://github.com/<username>/eTicketing.git
cd eTicketing

# Atau copy folder langsung
```

## 8.3 Install Dependencies

```bash
flutter pub get
```

Pubspec.yaml mendeklarasikan:
- `go_router ^13.0.0`
- `provider ^6.1.1`
- `fl_chart ^0.68.0`
- `intl ^0.19.0`
- `timeago ^3.6.0`
- `image_picker ^1.1.2`
- `file_picker ^8.1.2`
- `google_fonts ^6.2.1`
- `supabase_flutter ^2.3.0`
- `cupertino_icons ^1.0.6`

## 8.4 Setup Supabase

### Opsi A — Pakai Project Saya (Paling Cepat)

Project ref: `eblilamcydtnafqhzcxa`

URL & anon key sudah hardcoded di `lib/core/supabase_config.dart`:
```dart
static const String supabaseUrl = 'https://eblilamcydtnafqhzcxa.supabase.co';
static const String supabaseAnonKey = 'eyJhbGci...';
```

Skip ke langkah 8.5. Aplikasi langsung jalan.

### Opsi B — Bikin Project Sendiri

1. Buka https://supabase.com → Sign up → New project
2. Region: Singapore (paling dekat untuk Indonesia)
3. Set database password (catat baik-baik)
4. Tunggu project provisioning (~2 menit)
5. Buka **SQL Editor** di sidebar
6. Copy-paste seluruh isi `database_setup.sql` → Run
7. Buka **Settings → API** → copy:
   - `Project URL` → ganti `supabaseUrl` di `lib/core/supabase_config.dart`
   - `anon public` key → ganti `supabaseAnonKey`
8. Buka **Storage** → New bucket → nama `attachments` → centang "Public bucket" → Create

## 8.5 Setup Storage (Wajib)

Di Supabase dashboard:
1. Klik **Storage** di sidebar
2. New bucket → nama: `attachments`
3. Centang **Public bucket** (supaya file bisa diakses publik)
4. Create

Bucket ini dipakai oleh `SupabaseService.uploadAttachment()`.

## 8.6 Buat Bucket + Storage Policies (Penting!)

Supabase secara default **tidak mengizinkan upload anonim**. Tambahkan policy:

Di SQL Editor, jalankan:
```sql
-- Allow public upload to attachments bucket
CREATE POLICY "Allow public uploads"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'attachments');

-- Allow public read
CREATE POLICY "Allow public read"
ON storage.objects FOR SELECT
USING (bucket_id = 'attachments');
```

(Untuk UAS, demi kesederhanaan, RLS di-disable — lihat `database_setup.sql` baris akhir.)

## 8.7 Jalankan Aplikasi

### Di Android Emulator

```bash
# Lihat emulator yang tersedia
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_name>

# Atau buka dari Android Studio → Device Manager → Run

# Run app
flutter run
```

### Di Chrome (Web)

```bash
flutter config --enable-web
flutter run -d chrome
```

> Catatan: Supabase tidak support hot reload untuk native modules, pertama kali agak lama.

### Di Perangkat Fisik (Android)

1. Aktifkan **USB Debugging** di HP (Settings → Developer Options)
2. Colok USB
3. `flutter devices` → lihat device terdeteksi
4. `flutter run -d <device_id>`

## 8.8 Login Akun Demo

Setelah app jalan, login dengan salah satu akun ini (password semua `123`):

| Email | Role |
|---|---|
| `irsad@email.com` | User |
| `azzam@email.com` | User |
| `rafael@email.com` | Helpdesk |
| `dewi@email.com` | Helpdesk |
| `admin@email.com` | Admin |

## 8.9 Build APK / AppBundle untuk Distribusi

### Debug APK (untuk testing)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (untuk di-share)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle (untuk Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

> Untuk release, Anda perlu signing key. Untuk UAS cukup APK debug yang di-share via WhatsApp/Drive.

## 8.10 Troubleshooting Umum

| Masalah | Solusi |
|---|---|
| `flutter pub get` gagal | Cek koneksi internet, atau `flutter pub cache clean` lalu coba lagi |
| Emulator tidak muncul di `flutter devices` | Buka Android Studio → buka AVD Manager → Run emulator dulu |
| App stuck di splash screen | Cek Supabase URL/key di `supabase_config.dart`, pastikan tidak ada spasi |
| Login gagal padahal akun ada | Cek `is_active` di tabel users (mungkin nonaktif), atau password salah |
| Upload attachment error | Pastikan bucket `attachments` sudah dibuat dan public |
| Notifikasi tidak muncul | Pull-to-refresh di tab notifikasi; atau cek `notifications` table di Supabase |
| Hot reload error | Tekan R (restart) di terminal, atau `flutter clean` lalu `flutter pub get` |
| Network timeout | Pastikan emulator ada akses internet (biasanya WiFi Android Studio) |
| Error `PostgrestException` | Cek log detail di debug console; biasanya RLS policy atau foreign key constraint |

## 8.11 Reset Database ke Seed

Untuk reset data demo ke kondisi awal:

1. Buka Supabase Dashboard → SQL Editor
2. Jalankan:
   ```sql
   TRUNCATE TABLE ticket_attachments, ticket_history, comments, notifications, tickets, users CASCADE;
   ```
3. Copy-paste blok `INSERT` dari `database_setup.sql` (mulai dari baris `INSERT INTO users...`)
4. Run

Atau lebih simpel: hapus semua baris + jalankan ulang seluruh file `database_setup.sql` (semua INSERT pakai `ON CONFLICT DO NOTHING`, jadi aman dijalankan ulang).

## 8.12 Struktur Folder Lengkap (Final)

```
eTicketing/
├── lib/                          # Source code Flutter
│   ├── main.dart
│   ├── core/                     # Konfigurasi & utility
│   ├── data/                     # Models + dummy
│   ├── presentation/             # Screens, widgets, providers
│   └── services/                 # Supabase service
├── test/                         # Unit/widget tests (kosong untuk UAS)
├── database_setup.sql            # Schema + seed
├── pubspec.yaml                  # Dependencies
├── pubspec.lock                  # Locked versions
├── analysis_options.yaml         # Lint rules
├── android/                      # Android-specific config
├── ios/                          # iOS-specific config
├── laporan/                      # 📁 Folder laporan UAS ini
│   ├── README.md
│   ├── 01-pendahuluan.md
│   ├── 02-arsitektur.md
│   ├── 03-database.md
│   ├── 04-api.md
│   ├── 05-uiux.md
│   ├── 06-fitur.md
│   ├── 07-video-tutorial.md
│   ├── 08-panduan-deploy.md
│   └── 09-dokumentasi-kode.md
├── screenshots/                  # 📁 Untuk screenshot UI (opsional)
└── diagrams/                     # 📁 Untuk diagram tambahan (opsional)
```

## 8.13 Langkah Final: Build & Submit

Untuk tugas UAS, yang perlu di-submit:
1. **Source code** (folder `lib/` + `database_setup.sql` + `pubspec.yaml`)
2. **Laporan** (folder `laporan/`, convert ke PDF jika perlu)
3. **Video demo** (lihat [07-video-tutorial.md](07-video-tutorial.md))
4. **APK release** (opsional, untuk demonstrasi langsung tanpa setup)
5. **Link repository GitHub** (best practice)

Semoga sukses UAS-nya! 🎓