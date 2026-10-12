# Konversi dan Integrasi CMS Sekolahku + Playschool

## Keputusan teknis
- Sumber CMS: CodeIgniter 4 (cms-sekolahku-v3.1.2.zip), semula memakai driver MySQLi dan skema MySQL/MariaDB.
- Sumber desain: Elementor Template Kit Playschool; manifest menyatakan sejumlah template memerlukan Elementor Pro.
- Runtime proyek: frontend statis + endpoint JavaScript di Hatchable, dengan PostgreSQL. Runtime ini tidak menjalankan aplikasi PHP CodeIgniter secara langsung, sehingga modul relevan dikonversi, bukan menyalin folder PHP mentah lalu menganggapnya dapat berjalan.
- Desain Playschool diterapkan sebagai CSS native responsif. File JSON Elementor tidak menjadi dependensi runtime.
- Tidak ada data siswa atau data pribadi yang disalin dari seed/demo CMS.

## Pemetaan komponen CMS
| Komponen Sekolahku | Bentuk hasil konversi |
|---|---|
| Pages / Menus / Settings | cms_content tipe page, cms_menu_items, cms_site_settings |
| News | cms_content tipe news |
| Programs / Extracurriculars | cms_content tipe program; rincian ekstra disimpan di payload |
| Teachers | cms_content tipe teacher |
| Gallery | cms_content tipe gallery, media_url dan payload |
| Events | cms_content tipe event |
| FAQ / Testimonials | cms_content tipe faq / testimonial |
| Downloads | cms_content tipe download dengan URL file pada media_url/payload |
| Messages / Contact | cms_messages; minat PPDB tetap pada admission_interest |
| Users / Roles | Harus memakai autentikasi dan otorisasi server-side; tidak dibuatkan tabel login buatan |
| Komentar moderasi | Belum diaktifkan; ditambahkan hanya jika kebutuhan sekolah mengharuskannya |

## Skema dan migrasi
- migrations/002_school_cms_core.sql adalah migrasi PostgreSQL aditif dan idempotent.
- Salinan sumber migrasi untuk repositori: database/migrations/0002_school_cms_core.sql.
- Migrasi menambahkan konten CMS, menu, pengaturan, pesan, dan audit log; tidak menghapus tabel admission_interest.
- Database internal Hatchable dan Neon adalah dua target berbeda. Keberhasilan migrasi pada satu target tidak membuktikan Neon telah terhubung.
- Jangan menaruh DATABASE_URL atau kredensial database di HTML, JavaScript browser, atau repositori.

## Validasi sebelum mengaktifkan data nyata
1. Uji migrasi pada database kosong dan database yang sudah memiliki admission_interest.
2. Endpoint baca publik hanya boleh mengembalikan status published.
3. Operasi tulis CMS harus dibatasi ke peran admin dan perubahan tercatat di audit log.
4. Verifikasi unggahan media, validasi URL, sanitasi HTML, autentikasi, rate limiting, dan backup.
5. Jangan memasukkan data anak/siswa sampai kontrol akses dan target database produksi tervalidasi.

## Batas pekerjaan
Ini adalah konversi skema dan lapisan desain awal. Ini tidak mengklaim seluruh CMS CodeIgniter berjalan identik atau koneksi Neon sudah aktif. Modul admin tetap tertutup sampai autentikasi admin runtime dikonfigurasi dan diuji.
