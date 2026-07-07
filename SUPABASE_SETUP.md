# Setup Supabase untuk E-Ticketing App

## Langkah 1 — Buat Project di Supabase Dashboard
1. Buka https://supabase.com/dashboard/project
2. Klik **"New Project"**
3. Isi nama (misal: `eTicketing-Praktikum`)
4. Pilih region terdekat, buat password
5. Tunggu sampai project selesai dibuat

## Langkah 2 — Jalankan SQL Setup
1. Buka Dashboard project baru → klik **SQL Editor** di sidebar kiri
2. Copy paste seluruh isi file [`database_setup.sql`](./database_setup.sql)
3. Klik **Run**
4. Pastikan muncul pesan **"Success. No rows returned"** atau semua INSERT berhasil

## Langkah 3 — Ambil API Keys
1. Klik **Settings** (ikon gear di sidebar kiri bawah)
2. Klik **API**
3. Salin dua hal ini:
   - **Project URL** → contoh: `https://xxxxx.supabase.co`
   - **anon/public key** → contoh: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

## Langkah 4 — Update Config di Proyek
Buka file `lib/core/supabase_config.dart`, lalu isi:
```dart
const String supabaseUrl = 'https://xxxxx.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

## Langkah 5 — Buat Storage Bucket
1. Buka **Storage** di sidebar
2. Klik **New Bucket**
3. Nama bucket: `attachments`
4. Public bucket: **ON**
5. Max file size: `10485760` (10 MB)
6. Klik **Save**

## Langkah 6 — Run App
```bash
cd eTicketing
flutter pub get
flutter run -d chrome
```

---

## Akun Login yang Tersedia (seed data)

| Email | Password | Role |
|-------|----------|------|
| `budi@email.com` | `123` | user |
| `siti@email.com` | `123` | user |
| `rizky@email.com` | `123` | helpdesk |
| `dewi@email.com` | `123` | helpdesk |
| `adminit@email.com` | `123` | admin |
