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
| MEDIUM | app_shell.dart, _menuItems | 9 tujuan utama berupa ikon; grouping kerja belum diterapkan | Selesai pada tahap lanjutan: label adaptif, tujuh tujuan operasional dan dua tujuan administrasi; filter izin tetap milik shell; urutan relatif per kelompok tetap tersimpan |
| MEDIUM | dashboard_page.dart, _dashboardMetricCardHeight / _MetricRangeFilter | Panel tinggi tetap 374 dan filter 34 px berisiko pada teks besar | Selesai pada tahap lanjutan: panel dinamis, controls >=40 px, legend wrap, breakpoint mengikuti text scaling; area plot chart tetap dibatasi secara sengaja |
| MEDIUM | teachers_page.dart, _buildContent | Error mengganti seluruh konten dan memakai errorWithDetails | Pisahkan kegagalan awal/refresh, simpan data lama dan pesan aman; memerlukan perubahan state/data, belum diubah |
| MEDIUM | students_page.dart, dialog filter; multi_filter.dart | Pola dialog filter berulang dan label campuran bahasa | Satukan hanya setelah menyamakan perilaku filter dan lifecycle; belum diubah |
| LOW | fitur dengan override AppColors.white / primary | Override lokal dapat mempertahankan kontras lama | Migrasi terarah per surface dengan tes, bukan penggantian string global; belum diubah |

## Kontrak yang dijaga

Tidak ada perubahan SQL, schema/migration/seed, repository, Cubit, cache, penyimpanan dokumen, izin, route, atau callback save/delete. Sorting lokal, paging 0-based, click-to-open, dan pengunci aksi tabel dipertahankan. Hak akses tetap. Format penyimpanan urutan route tetap; pengelompokan visual dan urutan relatif per kelompok diterapkan pada tahap lanjutan. Tidak menambahkan dependency, framework, layanan jaringan, atau motion dekoratif.

Perubahan lokal awal pengguna pada `analysis_options.yaml` dan `pubspec.lock` dipertahankan. Fondasi UI disimpan pada commit `d722c59`; belum push. Restyle lanjutan disimpan terpisah setelah verifikasi.

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

## Tahap lanjutan — sidebar, dashboard, dan title bar Windows

Permintaan lanjutan pengguna: commit fondasi lalu lanjutkan restyle. Commit fondasi: `d722c59`.

Temuan tambahan: shell membatasi seluruh konten ke 1200 px sehingga tabel/dashboard tidak memanfaatkan jendela lebar; title bar memakai teks tanpa Flexible dan tombol GestureDetector tanpa aktivasi keyboard. Perbaikan menghilangkan batas global shell, memberi judul panjang tooltip/ellipsis yang dibatasi dengan Flexible, serta memakai IconButton 48 px dengan focus indicator. Kontrak minimize/maximize/restore/close, drag title bar, dan double-click maximize tetap menggunakan window_manager yang sama.

Perubahan:

- `lib/app_sidebar.dart`: navigasi presentasi terpisah dari pembacaan izin/session. Label terlihat mulai lebar 1200 px; rail 56 px pada jendela kecil. Label dapat wrap saat text scaling membesar, ikon selected memakai filled variant, dan fokus memakai outline gelap. Tujuh tujuan operasional tetap langsung tersedia; Parameter/Pengguna dipisah ke Administrasi. Preferences dan Logout tetap di bagian bawah.
- `lib/app_shell.dart`: tetap memasok hanya menu yang diizinkan, menyimpan list route yang sama, dan menerapkan reorder hanya pada slot anggota kelompok terkait. Route yang tidak disediakan sidebar tidak ditambahkan; slot menu lain tetap. Logout memakai dialog guard bersama untuk mencegah konfirmasi bertumpuk.
- `dashboard_page.dart`: KPI tanpa fixed height, grid berdasarkan ruang efektif setelah text scaling, metric header/legend responsif, daftar jadwal/peringkat tumbuh sesuai isinya, angka tabular, baris peringkat memakai InkWell/tooltip, dan scrollbar dengan controller yang sama. Refresh memakai progress bar pada slot stabil sehingga data lama tidak tertutup overlay. Error menampilkan pesan lokal generik dengan Retry dan detail diagnostik melalui helper yang sudah tersedia.
- `AppChartPalette`: memusatkan warna chart yang sudah ada tanpa mengubah nilai warnanya. Tidak ada warna brand baru atau dependency baru.
- `title_bar.dart`: judul panjang tidak mendorong tombol jendela keluar; tombol dapat dipakai dengan Tab/Enter dan mempunyai tooltip/fokus. Window manager tetap boundary platform yang sama.
- ARB Indonesia/Inggris dan generated localization diperbarui untuk judul kelompok serta pesan kegagalan dashboard.

Verifikasi lanjutan:

- 20 tes dashboard/sidebar lulus pada iterasi awal: 800x600, 1280x800, 1920x1080, 2560x1080; text scaling 100/125/150/200%; scroll sampai panel terakhir; data sintetis panjang; empty/loading/error/retry; keyboard; serta drag reorder terbatas pada kelompoknya.
- Tes tambahan title bar memverifikasi label panjang pada text scaling 200% dan pemanggilan minimize melalui Tab/Enter dengan mock window_manager. Tidak menjalankan aksi jendela pengguna saat test.
- Analyzer terarah untuk tujuh file produksi/test: tidak ada issue. Verifikasi akhir: full `flutter test --no-pub` 82 tes lulus; full `flutter analyze --no-pub --no-fatal-infos` exit 0 tanpa error/warning, dengan satu info deprecation lama pada assistance_periods_page.dart:3824; `flutter build windows --release --no-pub` berhasil (65.1 detik). Strict analyzer masih exit 1 karena info lama tersebut.
- Preview Poppins/MaterialIcons diperiksa pada 800x600 @200%, 1280x800 @100%, dan 1920x1080 @100%. Preview memakai data sintetis; label sidebar pada fixture bukan data pengguna.
- Tidak ada perubahan repository, Cubit, SQL, schema, cache, perhitungan KPI, atau izin. Scope perubahan data hanya preferensi urutan menu UI pada format route yang sudah ada.

Yang masih terbuka: restyle per halaman form/tabel, penanganan error halaman guru, penyatuan dialog filter siswa, dark mode, serta pengujian runtime DPI/multi-monitor/Narrator dan semua role. Pengujian widget scaling tidak menggantikan pengujian display scaling Windows.
Tahap lanjutan prioritas berdasarkan besarnya perubahan: lihat [ui-restyle-priorities.md](ui-restyle-priorities.md). Workspace Periode Bantuan dan wizard telah direstyle; hasil verifikasi akhir dicatat pada dokumen tersebut.

Tahap Jadwal: workspace, kalender, toolbar/pencarian keyboard, timeline dan dialog direstyle. Audit severity, batas kontrak, dan hasil verifikasinya dicatat dalam [ui-restyle-priorities.md](ui-restyle-priorities.md). Perubahan Bantuan sebelumnya sudah di-commit `126d391`.
