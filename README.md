# KB/TK WIJANA SEJATI Mojokerto

Platform digital terpadu untuk website publik dan manajemen pendidikan KB/TK WIJANA SEJATI Mojokerto.

## Prinsip
- Bahasa Indonesia sebagai bahasa utama.
- Responsif untuk ponsel, tablet, dan desktop.
- GitHub untuk kode, dokumentasi, kolaborasi, dan CI.
- Neon PostgreSQL ditetapkan sebagai target database utama produksi.
- Hatchable saat ini menjadi hosting/backend aktif; database internal Hatchable adalah target staging, bukan bukti koneksi Neon.
- Data siswa, wali murid, pegawai, dan keuangan harus dilindungi dengan autentikasi, otorisasi server-side, dan audit log.
- Jangan pernah mengekspos DATABASE_URL atau kredensial database ke browser atau repositori.

## Modul rencana
1. Website publik dan PPDB.
2. Sistem informasi pendidikan: siswa, kelas, tahun ajaran, absensi, perkembangan anak, jadwal, pengumuman.
3. CRM calon siswa dan komunikasi wali murid.
4. ERP operasional, aset, inventaris, dan pengadaan.
5. Akuntansi dan anggaran sekolah.
6. HRD dan payroll.
7. Dashboard manajemen dan laporan.

## Konversi CMS Sekolahku dan desain Playschool
Sumber CMS CodeIgniter 4 dan Elementor Template Kit Playschool telah diaudit. Karena runtime aktif menggunakan endpoint JavaScript, komponen CMS yang sesuai dikonversi ke skema PostgreSQL dan API; kode PHP CodeIgniter tidak disalin mentah karena tidak akan berjalan langsung di runtime tersebut. Lapisan desain Playschool diterapkan sebagai CSS native, tanpa ketergantungan Elementor Pro saat runtime.

Rincian modul, batas kompatibilitas, dan prosedur migrasi ada di [docs/MIGRASI-CMS-SEKOLAHKU-PLAYSCHOOL.md](docs/MIGRASI-CMS-SEKOLAHKU-PLAYSCHOOL.md).

## Arsitektur dan deployment
- Website aktif: https://kbtk-wijana-sejati.hatchable.site
- Kode sumber dan migrasi: repositori ini.
- Hatchable menjalankan endpoint aplikasi dan database PostgreSQL terkelola untuk staging.
- Neon tetap menjadi target database utama produksi, tetapi koneksi dan kredensial Neon belum dikonfigurasi di deployment aktif.
- Workflow GitHub Actions memvalidasi entry point website, aset desain, sintaks API, dan migrasi SQL. GitHub Pages belum digunakan sebagai target deployment aktif karena aktivasi Pages memerlukan izin repositori yang tidak tersedia melalui koneksi saat ini.

## Status
- Website Hatchable v2 sudah ter-deploy.
- Migrasi CMS aditif sudah diterapkan pada database PostgreSQL internal Hatchable dan struktur tabel telah diverifikasi.
- Endpoint baca konten publik berjalan dan hanya menampilkan konten berstatus published.
- Endpoint manajemen CMS mensyaratkan akses admin; pengujian anonim menghasilkan HTTP 401.
- CI validasi terbaru berhasil.
- Neon belum terhubung; jangan memasukkan data siswa atau data sensitif sampai target database produksi dan autentikasi admin selesai diverifikasi.
