-- ============================================
-- E-Ticketing Helpdesk — Database Setup
-- Project Supabase: eblilamcydtnafqhzcxa
-- Tanggal export: 2026-07-08
-- ============================================

-- ── 1. TABLE: users ──
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('user', 'helpdesk', 'admin')),
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_active BOOLEAN DEFAULT TRUE
);

-- ── 2. TABLE: tickets ──
CREATE TABLE IF NOT EXISTS tickets (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (category IN ('hardware', 'software', 'network', 'other')),
  priority TEXT NOT NULL CHECK (priority IN ('low', 'medium', 'high')),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'inProgress', 'resolved', 'closed')),
  created_by UUID NOT NULL REFERENCES users(id),
  assigned_to UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 3. TABLE: comments ──
CREATE TABLE IF NOT EXISTS comments (
  id TEXT PRIMARY KEY,
  ticket_id TEXT NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  user_name TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 4. TABLE: ticket_history ──
CREATE TABLE IF NOT EXISTS ticket_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id TEXT NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  status TEXT NOT NULL,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  note TEXT
);

-- ── 5. TABLE: notifications ──
CREATE TABLE IF NOT EXISTS notifications (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  ticket_id TEXT REFERENCES tickets(id),
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 6. TABLE: ticket_attachments ──
CREATE TABLE IF NOT EXISTS ticket_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id TEXT NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  file_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- 1. Disable RLS di semua tabel (development mode)
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE tickets DISABLE ROW LEVEL SECURITY;
ALTER TABLE comments DISABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_history DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_attachments DISABLE ROW LEVEL SECURITY;

-- 2. Enable RLS kembali + policy sederhana untuk authenticated users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_attachments ENABLE ROW LEVEL SECURITY;

-- 3. Drop policy lama (kalau ada)
DROP POLICY IF EXISTS "Allow all authenticated users on users" ON users;
DROP POLICY IF EXISTS "Allow all authenticated users on tickets" ON tickets;
DROP POLICY IF EXISTS "Allow all authenticated users on comments" ON comments;
DROP POLICY IF EXISTS "Allow all authenticated users on ticket_history" ON ticket_history;
DROP POLICY IF EXISTS "Allow all authenticated users on notifications" ON notifications;
DROP POLICY IF EXISTS "Allow all authenticated users on ticket_attachments" ON ticket_attachments;

-- 4. Buat policy: semua bisa baca/tulis untuk authenticated
CREATE POLICY "Allow all authenticated users on users"
  ON users FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow all authenticated users on tickets"
  ON tickets FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow all authenticated users on comments"
  ON comments FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow all authenticated users on ticket_history"
  ON ticket_history FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow all authenticated users on notifications"
  ON notifications FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow all authenticated users on ticket_attachments"
  ON ticket_attachments FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ============================================
-- SEED DATA — AKUN LOGIN
-- ============================================
-- Password semua: "123"

INSERT INTO users (id, name, email, password, role, created_at, is_active) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'Irsad Gufar',       'irsad@email.com',       '123', 'user',    '2026-07-06T00:00:00+00:00', TRUE),
  ('a0000000-0000-0000-0000-000000000002', 'Abdullah Azzam',    'azzam@email.com',       '123', 'user',    '2026-07-06T00:00:00+00:00', TRUE),
  ('a0000000-0000-0000-0000-000000000003', 'Rizky Pratama',     'rizky@email.com',       '123', 'helpdesk','2026-07-06T00:00:00+00:00', TRUE),
  ('a0000000-0000-0000-0000-000000000004', 'Dewi Chumairoh',    'dewi@email.com',        '123', 'helpdesk','2026-07-06T00:00:00+00:00', TRUE),
  ('a0000000-0000-0000-0000-000000000005', 'Admin',             'admin@email.com',       '123', 'admin',   '2026-07-06T00:00:00+00:00', TRUE)
ON CONFLICT (id) DO NOTHING;

-- ── SAMPLE TICKETS ──
INSERT INTO tickets (id, title, description, category, priority, status, created_by, assigned_to, created_at, updated_at) VALUES
  ('TK-001', 'Laptop sering hang saat buka banyak aplikasi', 'Laptop Lenovo saya selalu hang kalau buka Chrome + Excel + Word bersamaan. Ram cuma 4GB.', 'hardware', 'high', 'inProgress',
   'a0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003', '2026-07-01T08:00:00+00:00', '2026-07-02T10:00:00+00:00'),
  ('TK-002', 'Tidak bisa print ke printer kantor lantai 3', 'Sudah install driver tapi printer HP LaserJet tidak terdeteksi.', 'software', 'medium', 'open',
   'a0000000-0000-0000-0000-000000000002', NULL, '2026-07-03T14:00:00+00:00', '2026-07-03T14:00:00+00:00'),
  ('TK-003', 'WiFi drop setiap jam 10 pagi', 'Koneksi internet cuti terus dari jam 10 sampai jam 11. Padahal biasanya lancar.', 'network', 'high', 'resolved',
   'a0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000004', '2026-06-28T09:00:00+00:00', '2026-06-30T16:00:00+00:00'),
  ('TK-004', 'Access VPN tidak bisa login', 'Sudah reinstall Cisco VPN client tapi masih gagal login. Error "Authentication Failed".', 'network', 'high', 'inProgress',
   'a0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000003', '2026-07-04T11:00:00+00:00', '2026-07-05T09:00:00+00:00'),
  ('TK-005', 'Install Office 365 untuk kerja jarak jauh', 'Mohon install Microsoft Office 365 agar bisa kerja dari rumah.', 'software', 'low', 'closed',
   'a0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003', '2026-07-01T10:00:00+00:00', '2026-07-03T15:00:00+00:00'),
  ('TK-006', 'Monitor LCD rusak pixel mati', 'Monitor Dell saya ada garis-garis vertikal di tengah layar.', 'hardware', 'medium', 'open',
   'a0000000-0000-0000-0000-000000000002', NULL, '2026-07-05T13:00:00+00:00', '2026-07-05T13:00:00+00:00')
ON CONFLICT (id) DO NOTHING;

-- ── SAMPLE COMMENTS ──
INSERT INTO comments (id, ticket_id, user_id, user_name, content, created_at) VALUES
  ('cm-01', 'TK-001', 'a0000000-0000-0000-0000-000000000003', 'Rizky Pratama',
   'Sudah dicek, kemungkinan perlu upgrade RAM ke 8GB.', '2026-07-02T10:00:00+00:00'),
  ('cm-02', 'TK-003', 'a0000000-0000-0000-0000-000000000004', 'Dewi Lestari',
   'Sudah direstart access point lantai 3, WiFi sudah stabil.', '2026-06-30T16:00:00+00:00'),
  ('cm-03', 'TK-005', 'a0000000-0000-0000-0000-000000000003', 'Rizky Pratama',
   'Office 365 sudah di-install. Silakan cek.', '2026-07-03T15:00:00+00:00')
ON CONFLICT (id) DO NOTHING;

-- ── SAMPLE TICKET HISTORY ──
INSERT INTO ticket_history (ticket_id, status, changed_at, note) VALUES
  ('TK-001', 'open',        '2026-07-01T08:00:00+00:00', 'Tiket dibuat'),
  ('TK-001', 'inProgress',  '2026-07-02T10:00:00+00:00', 'Diagnosa: perlu upgrade RAM'),
  ('TK-002', 'open',        '2026-07-03T14:00:00+00:00', 'Tiket dibuat'),
  ('TK-003', 'open',        '2026-06-28T09:00:00+00:00', 'Tiket dibuat'),
  ('TK-003', 'resolved',    '2026-06-30T16:00:00+00:00', 'Access point direstart, WiFi stabil'),
  ('TK-004', 'open',        '2026-07-04T11:00:00+00:00', 'Tiket dibuat'),
  ('TK-004', 'inProgress',  '2026-07-05T09:00:00+00:00', 'Sedang cek konfigurasi VPN'),
  ('TK-005', 'open',        '2026-07-01T10:00:00+00:00', 'Tiket dibuat'),
  ('TK-005', 'resolved',    '2026-07-03T11:00:00+00:00', 'Office 365 terinstall'),
  ('TK-005', 'closed',      '2026-07-03T15:00:00+00:00', 'Tiket ditutup'),
  ('TK-006', 'open',        '2026-07-05T13:00:00+00:00', 'Tiket dibuat')
ON CONFLICT DO NOTHING;

-- ── SAMPLE NOTIFICATIONS ──
INSERT INTO notifications (id, title, message, ticket_id, is_read, created_at) VALUES
  ('nf-01', 'Tiket TK-001 Diperbarui', 'Status tiket "Laptop sering hang saat buka banyak aplikasi" berubah menjadi In Progress.', 'TK-001', FALSE, '2026-07-02T10:00:00+00:00'),
  ('nf-02', 'Komentar Baru di TK-001', 'Rizky Pratama menambahkan komentar pada tiket Anda.', 'TK-001', FALSE, '2026-07-02T10:05:00+00:00'),
  ('nf-03', 'Tiket TK-003 Selesai', 'Tiket "WiFi drop setiap jam 10 pagi" telah diselesaikan.', 'TK-003', TRUE,  '2026-06-30T16:00:00+00:00'),
  ('nf-04', 'Tiket TK-005 Ditutup', 'Tiket "Install Office 365 untuk kerja jarak jauh" telah ditutup.', 'TK-005', TRUE,  '2026-07-03T15:00:00+00:00'),
  ('nf-05', 'Tiket TK-004 Diperbarui', 'Status tiket "Access VPN tidak bisa login" berubah menjadi In Progress.', 'TK-004', FALSE, '2026-07-05T09:00:00+00:00')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- STORAGE BUCKET untuk attachments
-- ============================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('attachments', 'attachments', true)
ON CONFLICT (id) DO NOTHING;

-- Policy storage: public read & write untuk development
DROP POLICY IF EXISTS "Allow public read attachments" ON storage.objects;
DROP POLICY IF EXISTS "Allow public upload attachments" ON storage.objects;
DROP POLICY IF EXISTS "Allow public access to attachments" ON storage.objects;

CREATE POLICY "Allow public access to attachments"
  ON storage.objects FOR ALL
  USING (bucket_id = 'attachments')
  WITH CHECK (bucket_id = 'attachments');
