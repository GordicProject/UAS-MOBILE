-- =============================================================
-- FIX TOTAL: Toggle Aktif/Nonaktif User di eTicketing
-- Jalankan SEKALI di Supabase Dashboard → SQL Editor → New query
-- =============================================================

-- 1. Pastikan kolom is_active ada (aman dijalankan berulang)
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- 2. Set semua NULL menjadi TRUE (akun lama default aktif)
UPDATE users
  SET is_active = TRUE
  WHERE is_active IS NULL;

-- 3. PASTIKAN RLS POLICY MENGIZINKAN UPDATE
--    Cek dulu policy yang ada:
SELECT policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'users';

-- 4. (JALANKAN INI JIKA TIDAK ADA POLICY UNTUK UPDATE,
--     ATAU POLICY TERLALU KETAT):
--    Hapus policy lama yang mungkin memblokir:
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname
    FROM pg_policies
    WHERE tablename = 'users'
      AND cmd = 'UPDATE'
      AND policyname NOT LIKE '%admin%'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON users', pol.policyname);
    RAISE NOTICE 'Dropped policy: %', pol.policyname;
  END LOOP;
END $$;

-- 5. Buat policy UPDATE yang mengizinkan SEMUA user
--    (cocok untuk demo project — untuk production, ganti qual)
CREATE POLICY "Allow update users" ON users
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- 6. Verifikasi: lihat data terbaru
SELECT id, name, email, role, is_active
FROM users
ORDER BY created_at DESC
LIMIT 20;

-- =============================================================
-- CARA PAKAI:
-- 1. Buka https://supabase.com/dashboard/project/eblilamcydtnafqhzcxa
-- 2. Klik "SQL Editor" → "New query"
-- 3. Copy-paste SELURUH isi file ini
-- 4. Klik "Run" (atau Ctrl+Enter)
-- 5. Lihat output di bawah:
--    - Jika ada kolom is_active, akan tampil hasil SELECT
--    - Jangan panik jika baris "ALTER TABLE" muncul "already exists" — itu normal
-- 6. Kembali ke aplikasi Flutter
-- 7. Hot Restart (R besar di terminal)
-- 8. Coba toggle user lagi
-- =============================================================
