# Audit dan implementasi UI desktop Edukita

Tanggal: 16 November 2026. Lingkup implementasi: fondasi bersama yang dipakai lintas fitur. Ini bukan pernyataan bahwa seluruh halaman sudah memenuhi seluruh kriteria UX.

## Identitas dan token

Identitas dipertahankan dari `lib/theme/app_theme.dart`, font Poppins pada `pubspec.yaml`, dan penggunaan logo `assets/images/logo.webp`: turquoise #48CFCB, putih, abu lembut, charcoal #1F2937. Material 3 tetap menjadi fondasi; Shadcn yang sudah digunakan tidak diganti.

- Semantic aliases: secondary = accentBlue, accent = accentPurple, surfaceElevated = card, info = accentBlue. Alias kompatibel dengan token lama.
- `primaryForeground` #176F6C adalah turunan turquoise gelap untuk teks/fokus di permukaan terang. `onPrimary` memakai charcoal yang sudah ada. Warna brand utama tidak diubah.
- Spacing: xxs 4, xs 8, sm 12, md 16, lg 24, xl 32, xxl 48 logical pixels.
- Radius: control 12, panel 16, dialog 24, menu 12. Header tabel di dalam border 1 px memakai radius 15, mengikuti radius luar 16 dikurangi inset 1.
- Typography tema disederhanakan menjadi delapan ukuran: 10, 11, 12, 13, 14, 16, 18, 24. Body line height 1.45. Ini belum memigrasikan override typography lokal semua fitur.
- `numericStyle` memakai tabular figures. Tabel mewariskan font feature angka; kolom masih menentukan alignment bisnisnya sendiri.
- Light theme saja tersedia. Dark mode tidak diaktifkan karena komponen lama masih menggunakan token warna statis; perlu migrasi menyeluruh sebelum aman dijanjikan.

## Permukaan yang diperiksa

Audit source mendalam: bootstrap/startup, theme, router, sidebar, AppTable beserta pemakai siswa/guru, AppPageHeader, AppDialog, AppDialogTitle, dropdown, MultiFilter, dan form guru. Pemeriksaan pola dan inventaris: dashboard, jadwal, aktivitas mengajar/detail, settings, laporan/definisi laporan, parameter, sekolah/kelas, bantuan, users, serta detail siswa. Inventaris route mencakup halaman auth, dashboard, siswa, guru, parameter, jadwal, aktivitas mengajar, bantuan, reports, users, dan settings. Audit ini tidak setara dengan walkthrough runtime semua halaman/role.

## Temuan dan keputusan

| Severity | Lokasi | Masalah / dampak | Rekomendasi / status |
|---|---|---|---|
| HIGH | main.dart, MaterialApp.router builder | Skala teks sistem ditimpa 0.94; pembesaran aksesibilitas diabaikan | Override dihapus; selesai |
| HIGH | app_table.dart, _AppTableRowState | GestureDetector tidak menyediakan aktivasi keyboard; detail sulit diakses tanpa mouse | InkWell dengan Tab, Enter/Space, focus outline, minimum tinggi 40; selesai |
| HIGH | app_theme.dart, ColorScheme dan button/input theme | Putih di primary turquoise berkontras rendah; fokus dropdown transparan | onPrimary charcoal, foreground turquoise gelap, focus ring dropdown mengikuti kontrol dan bertahan setelah perubahan pilihan; selesai untuk default tema bersama, bukan semua override lokal |
| MEDIUM | app_dialog_title.dart | Close hanya 28 px; judul dipotong; tooltip tidak tersedia | IconButton >=40 px, tooltip lokal, judul wrap; selesai |
| MEDIUM | app_table.dart, footer | Pagination 32 px, tanpa tooltip, label Inggris tetap, page 1 of 0 ketika kosong | 40 px, tooltip Material lokal, ARB EN/ID, 0 dari 0 dan disabled; selesai |
| MEDIUM | app_page_header.dart | Aksi selalu satu baris dengan judul | Stack pada lebar <600 atau text scaling >150%, tetap rata tepi konten; selesai |
| MEDIUM | app_shell.dart, _RailTooltip / rail controls | Tooltip overlay hanya hover dan tidak menambahkan nama aksesibel; tombol 38 px | Tooltip native yang mendukung semantics, rail item/tombol minimum 40; selesai |
| MEDIUM | main.dart, _StartupPage | Smoke test menemukan overflow kanan 5.8 px pada baris logo/nama | Flexible pada teks brand dan konten dapat digulir; selesai |
| MEDIUM | app_theme.dart / app_dialog.dart | Spacing/radius berbeda-beda | Token terpusat; default dialog/menu/input/button dan komponen yang disentuh diselaraskan; migrasi local override masih terbuka |
| MEDIUM | app_shell.dart, _menuItems | 9 tujuan utama berupa ikon; grouping kerja belum diterapkan | Rancang ulang grouping dan label bersama verifikasi role serta menu-order tersimpan; belum diubah |
| MEDIUM | dashboard_page.dart, _dashboardMetricCardHeight / _MetricRangeFilter | Panel tinggi tetap 374 dan filter 34 px berisiko pada teks besar | Audit layout runtime per panel dan data realistis sebelum mengganti struktur; belum diubah |
| MEDIUM | teachers_page.dart, _buildContent | Error mengganti seluruh konten dan memakai errorWithDetails | Pisahkan kegagalan awal/refresh, simpan data lama dan pesan aman; memerlukan perubahan state/data, belum diubah |
| MEDIUM | students_page.dart, dialog filter; multi_filter.dart | Pola dialog filter berulang dan label campuran bahasa | Satukan hanya setelah menyamakan perilaku filter dan lifecycle; belum diubah |
| LOW | fitur dengan override AppColors.white / primary | Override lokal dapat mempertahankan kontras lama | Migrasi terarah per surface dengan tes, bukan penggantian string global; belum diubah |

## Kontrak yang dijaga

Tidak ada perubahan SQL, schema/migration/seed, repository, Cubit, cache, penyimpanan dokumen, izin, route, atau callback save/delete. Sorting lokal, paging 0-based, click-to-open, dan pengunci aksi tabel dipertahankan. Urutan menu dan hak akses tetap. Tidak menambahkan dependency, framework, layanan jaringan, atau motion dekoratif.

Perubahan lokal awal pengguna pada `analysis_options.yaml` dan `pubspec.lock` dipertahankan. Tidak dibuat commit atau push.

## Verifikasi

Environment aktual: Flutter 3.47.4 / Dart 3.13.3; nama folder SDK lama tidak mencerminkan versinya. Panduan proyek menyebut 3.41.6; kompatibilitas pada SDK persis itu belum dijalankan.

- `dart format` untuk delapan file Dart yang disentuh: berhasil.
- `flutter gen-l10n`: berhasil; generated localization berasal dari ARB.
- Test UI mencakup 800x600, 1280x800, 1920x1080, 2560x1080; text scaling 100%, 125%, 150%, 200%; list sintetis 1000 baris, header tetap, scroll, empty/disabled pagination, sorting, callback pagination, keyboard Tab/Enter/Space, fokus dropdown sebelum/sesudah pemilihan, Escape dialog, dan kontras pasangan warna utama.
- Dua tes rendering preview dengan Poppins dan MaterialIcons pada 800x600 @200% dan 1280x800 @100% diperiksa. Preview menggunakan data sintetis, bukan screenshot data pengguna.
- Full `flutter test --no-pub`: 61 tes lulus pada pengulangan final, termasuk 23 tes regresi UI baru.
- `flutter analyze --no-pub --no-fatal-infos`: exit 0, dua info deprecation `onReorder` pada app_shell.dart dan assistance_periods_page.dart. Tidak ada error/warning. Strict analyze tetap exit 1 karena dua info lama ini; tidak disembunyikan/dinonaktifkan di source. Migrasi API reorder sengaja dipisah agar kontrak index dan kompatibilitas SDK tidak berubah dalam pekerjaan visual.
- `flutter build windows --release --no-pub`: berhasil pada build final setelah perbaikan fokus dropdown (68.4 detik); output `build/windows/x64/runner/Release/edukita.exe`.
- `git diff --check`: berhasil.
- Tidak ditemukan dependency-boundary check khusus pada tool/scripts/test/CI. Batas dependency diperiksa melalui diff/import: komponen bersama tidak mendapat dependency fitur atau akses database.

Batas pengujian: text scaling widget bukan penggantian pengujian DPI Windows 125/150/200%, perpindahan monitor, Narrator, atau keyboard-only walkthrough seluruh aplikasi. Loading/error/saving/success dan izin semua role belum diuji menyeluruh; suite lama mencakup sebagian alur form guru, startup, jadwal, registrasi siswa, serta aktivitas mengajar. Tidak mengklaim sertifikasi WCAG AA seluruh aplikasi atau dukungan dark mode.
