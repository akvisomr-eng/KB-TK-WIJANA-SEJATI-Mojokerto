# Arsitektur Platform Digital KB/TK WIJANA SEJATI

## Sasaran
Satu platform untuk website publik dan aplikasi internal sekolah. Modul berbagi model data dan identitas pengguna, tetapi akses dibatasi berdasarkan peran.

## Komponen
- **GitHub**: repositori, issue/PR, CI, versioning, dan deployment website statis.
- **GitHub Pages**: website publik; tidak menjalankan backend server-side.
- **Neon PostgreSQL**: penyimpanan data relasional.
- **Backend/API**: wajib untuk autentikasi aplikasi, otorisasi, validasi, transaksi akuntansi/payroll, dan akses database Neon. Backend harus berjalan di runtime server yang mendukung Node.js/TypeScript dan variabel rahasia.
- **Browser**: hanya berkomunikasi dengan backend melalui HTTPS. Browser tidak boleh memiliki kredensial database.

## Modul
1. Website publik, berita, agenda, galeri, dan formulir minat PPDB.
2. CRM/PPDB: leads, status tindak lanjut, komunikasi, dan konversi.
3. Sistem informasi pendidikan: tahun ajaran, kelas, siswa, wali, absensi, perkembangan, jadwal, dan laporan.
4. Administrasi sekolah: surat, dokumen, pengumuman, serta alur persetujuan.
5. ERP: inventaris, aset, vendor, pengadaan, dan kebutuhan operasional.
6. Akuntansi: bagan akun, jurnal berpasangan, buku besar, anggaran, pemasukan, pengeluaran, dan laporan.
7. HRD: data pegawai, kontrak, kehadiran, cuti, dan evaluasi.
8. Payroll: periode penggajian, komponen gaji, potongan, persetujuan, dan slip gaji.
9. Dashboard manajemen: indikator sesuai izin akses.
10. Portal wali murid: pengumuman, agenda, dan laporan perkembangan anak yang diizinkan.

## Peran awal
- Superadmin teknis: konfigurasi sistem; tidak otomatis memiliki hak melihat seluruh data sensitif.
- Kepala sekolah: ringkasan dan persetujuan sesuai kewenangan.
- Administrasi/PPDB: data pendaftaran dan siswa yang relevan.
- Guru: kelas yang ditugaskan, absensi, dan perkembangan anak.
- Keuangan: transaksi dan laporan keuangan.
- HRD: data pegawai dan penggajian sesuai kewenangan.
- Wali murid: hanya data anak yang terhubung dengan akun wali tersebut.

Setiap endpoint memeriksa identitas dan izin di server. Menyembunyikan menu di frontend bukan kontrol keamanan.

## Keamanan minimum
- Simpan DATABASE_URL, session secret, dan kunci lain hanya di environment secrets backend.
- Password disimpan menggunakan hash adaptif yang kuat; jangan menyimpan password mentah.
- Terapkan validasi input, rate limit login, sesi aman, CSRF protection jika memakai cookie, dan HTTPS.
- Catat tindakan penting dalam audit log tanpa menyimpan password/token atau data sensitif berlebihan.
- Backup dan uji pemulihan database; batasi akses produksi.
- Payroll, data anak, dan catatan perkembangan hanya untuk peran yang benar-benar memerlukan.
- Gunakan data uji fiktif untuk pengembangan dan demo.

## Tahapan rilis
1. Website publik responsif dan CI/deployment.
2. Tentukan runtime backend, domain, dan konfigurasi Neon; siapkan migrasi.
3. Autentikasi, role-based access control, audit log, dan pengujian.
4. PPDB serta data induk siswa/wali/kelas/tahun ajaran.
5. Absensi, perkembangan anak, jadwal, notifikasi, dan portal wali.
6. CRM, ERP, akuntansi, HRD, dan payroll.
7. UAT dengan sekolah, hardening keamanan, backup/restore drill, lalu produksi.

## Status implementasi
Website publik awal dan workflow GitHub Pages telah ditambahkan ke repositori. Sistem login, backend, koneksi Neon, transaksi, dan modul internal belum dinyatakan tersedia atau siap produksi.
