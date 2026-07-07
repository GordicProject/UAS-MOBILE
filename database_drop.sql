-- DROP SEMUA TABLE (jika data belum ada)
-- Jalankan ini dulu di SQL Editor Supabase sebelum menjalankan database_setup.sql

DROP TABLE IF EXISTS ticket_attachments CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS ticket_history CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS users CASCADE;
