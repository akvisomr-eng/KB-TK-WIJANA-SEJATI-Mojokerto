# KB/TK WIJANA SEJATI Mojokerto

Platform digital terpadu untuk website publik dan manajemen pendidikan KB/TK WIJANA SEJATI Mojokerto.

## Prinsip
- Bahasa Indonesia sebagai bahasa utama.
- Responsif untuk ponsel, tablet, dan desktop.
- GitHub untuk kode, kolaborasi, CI, dan deployment workflow.
- Neon PostgreSQL sebagai basis data utama.
- Data siswa, wali murid, pegawai, dan keuangan harus dilindungi dengan autentikasi, otorisasi server-side, dan audit log.
- Jangan pernah mengekspos `DATABASE_URL` atau kredensial database ke browser.

## Modul rencana
1. Website publik dan PPDB.
2. Sistem informasi pendidikan: siswa, kelas, tahun ajaran, absensi, perkembangan anak, jadwal, pengumuman.
3. CRM calon siswa dan komunikasi wali murid.
4. ERP operasional, aset, inventaris, dan pengadaan.
5. Akuntansi dan anggaran sekolah.
6. HRD dan payroll.
7. Dashboard manajemen dan laporan.

## Arsitektur
Website statis dapat dipublikasikan melalui GitHub Pages. Fitur aplikasi yang membutuhkan login, transaksi, atau akses Neon memerlukan backend/API server-side yang berjalan di lingkungan hosting. GitHub dan Neon saja tidak menyediakan runtime backend web yang selalu aktif; jangan menghubungkan browser langsung ke database. Backend hosting dan domain produksi perlu ditetapkan sebelum sistem transaksi digunakan.

## Tahapan implementasi
- Fase 1: website publik responsif dan struktur proyek.
- Fase 2: backend aman, autentikasi, peran, dan migrasi database Neon.
- Fase 3: data induk pendidikan dan PPDB.
- Fase 4: absensi, perkembangan anak, komunikasi, dan laporan.
- Fase 5: CRM, ERP, akuntansi, HRD, dan payroll.
- Fase 6: pengujian keamanan, UAT, deployment, dan dokumentasi operasional.

## Status
Repositori diinisialisasi. Modul aplikasi harus dianggap belum produksi sampai backend, database, autentikasi, pengujian, dan deployment diverifikasi.