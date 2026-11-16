# Prioritas restyle halaman Edukita

Tanggal: 16 November 2026. Urutan mengikuti permintaan pengguna: kebutuhan perubahan terbesar lebih dahulu. Dasar penilaian adalah luas workflow, jumlah layout/dialog khusus, reflow desktop dan text scaling, konsistensi komponen, serta state/keyboard yang perlu diverifikasi. Jumlah baris membantu inventaris, bukan ukuran tunggal kualitas UI atau perkiraan waktu yang pasti.

Theme, komponen bersama, shell/sidebar, title bar Windows, dan dashboard sudah direstyle pada tahap sebelumnya (`d722c59`, `06f9079`). Halaman lain sudah menerima perbaikan komponen bersama tetapi belum otomatis dianggap selesai direstyle secara khusus.

| Urutan | Halaman / alur | Kebutuhan perubahan | Bukti source dan lingkup berikutnya | Status |
|---|---|---|---|---|
| 1 | Periode Bantuan (`assistance_periods_page.dart`) | Sangat besar | Sebelum perubahan: sekitar 4.978 baris; daftar, empat tab detail, target per aturan, review/persetujuan, penerima/bukti, wizard tiga langkah dan beberapa dialog khusus. Header, ringkasan, setup dan review berisiko melebihi jendela; aksi tabel tidak wrap; target kecil; wizard memakai warna navy terpisah dari brand. | Workspace utama dan wizard diterapkan pada tahap ini; lihat verifikasi di bawah |
| 2 | Jadwal (`schedule_page.dart`) | Sangat besar | Sekitar 3.456 baris; kalender/timeline, overlay pencarian, sinkronisasi scroll dan form jadwal/acara. Perlu penataan toolbar, sel kalender, dialog, focus, serta pengujian setiap mode. | Workspace, kalender, pencarian dan dialog diterapkan; lihat verifikasi Jadwal |
| 3 | Detail Aktivitas Mengajar (`teaching_activity_detail_page.dart`) | Besar | Sekitar 3.315 baris; beberapa area data, attendance/nilai/kompetensi, aksi status dan banyak ukuran lokal. Sudah memiliki reflow dan tes fungsional; perlu standardisasi surface, kontrol, dan hierarchy per area. | Workspace detail, rating, kontrol dan dialog diterapkan; lihat verifikasi prioritas 3 |
| 4 | Siswa: daftar, filter, form, tab detail | Besar | Daftar sekitar 1.671 baris sebelum perubahan, ditambah form/detail terpisah; statistik satu baris, toolbar, dua implementasi dialog filter, form besar, dan row action kecil. | Restyle utama diterapkan; lihat audit dan verifikasi prioritas 4 |
| 5 | Silabus, daftar Aktivitas Mengajar, Laporan/Definisi Laporan, Users | Sedang–besar | Silabus sekitar 1.470 baris, aktivitas 1.288, laporan 1.098, users 1.043. Perlu keseragaman navigasi bagian, toolbar, empty/error, form dan permission matrix; pertahankan grid data. | Belum restyle khusus |
| 6 | Settings, Guru/detail/form, Sekolah/Kelas, Parameter | Sedang | Settings dan laporan memakai panel/master-detail; guru memiliki masalah error yang mengganti data; sekolah/parameter memiliki reflow awal. Perlu perbaikan yang lebih terlokalisasi. | Belum restyle khusus |
| 7 | Program Bantuan, Aturan Bantuan, Lokasi Mengajar, Strategi, Wali, Login/Ganti Password | Kecil–sedang | Lebih sedikit area mandiri; mayoritas memperoleh manfaat dari komponen bersama. Perlu spacing, hit target, label, dialog dan state per halaman. | Belum restyle khusus |

`management_page.dart`, `classes_page.dart`, dan `class_detail_page.dart` juga tercakup dalam inventaris. Sebagian berfungsi sebagai wrapper/host sehingga penilaian restyle harus mengikuti komponen anaknya, bukan mengganti wrapper tanpa kebutuhan.

## Prioritas 1 yang diterapkan

File utama:

- `lib/features/assistance/periods/presentation/assistance_periods_page.dart`
- `lib/features/assistance/presentation/assistance_workspace.dart`
- `lib/widgets/step_process.dart`
- `lib/widgets/detail_tab_bar.dart`
- `lib/theme/app_theme.dart` dan ARB EN/ID beserta hasil generate

Perubahan:

1. Workspace memberi scroll halaman pada jendela kecil/teks besar; pada jendela luas, tabel memakai sisa area kerja. Tabel tetap mempunyai viewport tersendiri untuk header dan daftar yang panjang.
2. Ringkasan daftar/detail dan field filter beradaptasi dengan lebar serta text scaling; kolom angka utama rata kanan. Action tabel dapat wrap tanpa menghilangkan tombol.
3. Header detail memakai komponen bersama, metadata setup dapat digulir dan nilainya membungkus, sedangkan tab mempunyai minimum target 40 px serta foreground yang kontras pada turquoise.
4. Header target draft tidak lagi memaksa judul dan dua aksi dalam satu baris. Auto Target menjadi secondary action; Save tetap primary. Aturan perhitungan dan callback tetap.
5. Finalisasi distribusi tampil sebagai tombol langsung. Pembatalan dipisah di bawah bukti dengan warna error. Izin dan konfirmasi yang sudah ada tetap dipanggil melalui handler yang sama.
6. Loading tidak menghapus data lama. Kegagalan load mendapat Retry; exception aksi tidak tampil pada pesan normal, tetapi tetap tersedia melalui helper detail diagnostik.
7. Ctrl+F memfokuskan pencarian. Query dipertahankan saat kembali dari detail. Pemilihan tanggal mempunyai tombol kalender yang dapat difokuskan keyboard.
8. Wizard tiga langkah memakai token brand, indikator langkah sederhana, footer konsisten, langkah aturan/review yang dapat digulir, dan controls yang dapat tumbuh. Validasi gagal mempertahankan langkah; klik ganda saat validasi diblokir; completion setelah dispose dijaga. Saat submit aktif, tombol dinonaktifkan dan dismiss ditahan.
9. Callback reorder aturan memakai API yang sesuai, dengan tes bahwa kuota ikut pada urutan aturan. Date field tidak lagi membuat controller tanpa dispose pada setiap build.
10. Typography eksplisit dan dropdown memakai token font Poppins agar tombol/label tidak jatuh ke font default berbeda. Tidak menambahkan font atau palette baru.

## Batas kontrak dan pekerjaan yang tidak diubah

Tidak ada perubahan repository, Cubit/state persistence, SQL, schema/migration, perhitungan prioritas/kuota/kelayakan, penguncian status, aturan persetujuan, model benefit, file upload/export, atau grant izin. Penanganan error baru hanya pada presentation. API callback dan konfirmasi aksi kritis tetap.

Dialog sekunder pemilihan aturan, konfirmasi aturan kuota nol, pemilihan kandidat, dokumen distribusi dan eksport tidak ditulis ulang secara menyeluruh; alur validasi/konfirmasi yang ada dipertahankan. Standardisasi tambahan pada surface tersebut tetap dapat dilakukan setelah pengujian per alur. Tidak mengklaim seluruh modul bantuan ataupun semua role sudah selesai diaudit runtime.

## Verifikasi

- Tes prioritas ini mencakup 800x600, 1280x800, 1920x1080; text scaling 100%, 125%, 150%, 200%; label Inggris/Indonesia; data sintetis panjang; empat tab periode approved; aksi draft; ketiga langkah wizard; Ctrl+F; query kembali dari detail; error/retry; permission denied; reorder dan kuota; validasi gagal/duplikat/disposal.
- Preview daftar/detail dengan Poppins diperiksa pada 1280x800 @100% dan 800x600 @200%. Tidak menggunakan data siswa atau transaksi nyata.
- `dart format --output=none --set-exit-if-changed`: tujuh file yang disentuh sudah terformat (0 perubahan).
- `flutter test --no-pub`: 101 tes lulus, termasuk 19 tes baru untuk bantuan dan wizard.
- `flutter analyze --no-pub`: bersih, tanpa error, warning, atau info; tidak menggunakan pengecualian fatal-info.
- `flutter build windows --release --no-pub`: berhasil (76.4 detik), output `build/windows/x64/runner/Release/edukita.exe`.
- `flutter gen-l10n` dan `git diff --check`: berhasil. Tidak ada dependency-boundary check khusus di proyek; import/diff diperiksa.
- Perbandingan dengan baseline yang diformat SDK yang sama memastikan kode ekspor dan helper sesudahnya identik; selisih raw source pada area itu hanya formatting.
- Dua tes rendering preview akhir daftar/detail dengan font Poppins: lulus. SDK aktual Flutter 3.47.4 / Dart 3.13.3; versi persis pada panduan 3.41.6 belum diuji.
- Pengujian widget text scaling bukan pengganti uji DPI Windows, multi-monitor, Narrator, file picker asli, atau pembayaran/distribusi nyata.

Status Bantuan: sudah commit `126d391`, belum push. Perubahan lokal awal pada `analysis_options.yaml` dan `pubspec.lock` tetap dipertahankan.

## Prioritas 2 — Jadwal

Tahap Bantuan telah di-commit sebagai `126d391` (`Restyle assistance period workspace and setup wizard`), tanpa push. Berikut audit dan implementasi Jadwal.

### Audit sebelum perubahan

Design system tetap Poppins, turquoise Edukita, Material 3, semantic `AppColors`, spacing 4/8 dan radius bersama. Surface yang diperiksa: header/statistik, toolbar/search, kalender bulanan/rentang, daftar acara terpilih, timeline mingguan/rentang, popup baris, chooser tambah, form jadwal, form acara dan konfirmasi hapus. Penelusuran Cubit/repository/cache hanya untuk memastikan kontrak tetap.

| Severity | Lokasi | Masalah | Rekomendasi dan dampak |
|---|---|---|---|
| HIGH | Kalender dan popup timeline | Sel kalender serta target menu 20–28 px; rentang bergantung pointer | Target minimal 40 px, fokus terlihat, panah tanggal dan Shift+panah; pekerjaan dapat dilakukan dengan keyboard |
| HIGH | Timeline/form/chooser | Tinggi tetap dan judul terbatas memotong teks besar | Konten tumbuh, scroll terarah, pilihan tambah berupa list, tanggal/jam form reflow; mengurangi overflow |
| MEDIUM | Workspace/statistik | Ringkasan dan kalender mendesak area jadwal pada jendela kecil | Ringkasan compact dapat diperluas, kalender sekunder collapse, timeline tetap dapat diakses |
| MEDIUM | Pencarian | Overlay dan lifecycle fokus; tanpa pemilihan hasil melalui keyboard | Panel hasil inline, Ctrl+F, panah, Enter, Escape serta clear; menghindari overlay lepas dari layar |
| MEDIUM | Error dan dialog | Error awal mentah, footer kaku, radius lokal | Pesan actionable dengan Retry/detail, AppDialog/token, footer wrap, Ctrl+S dan busy guard |

### Implementasi

- `schedule_page.dart`: header bersama, statistik adaptif, toolbar, panel hasil pencarian, kalender/timeline, popup dan dialog mengikuti token Edukita. Warna data biru/amber yang sudah ada dipertahankan. Tidak ada palette baru.
- `schedule_calendar_day.dart`: label tanggal lengkap dan indikator acara/jadwal, selected state, target aman, panah dan Shift+panah. Rentang drag yang ada tetap tersedia.
- `schedule_workspace.dart`: viewport desktop normal memakai sisa ruang, sedangkan jendela kecil dan teks besar dapat menggulir konten.
- Form jadwal memakai field tanggal/jam yang reflow. Picker mempunyai tombol berlabel yang dapat difokuskan. Kedua form mempertahankan input setelah kegagalan, mencegah submit ganda dan menahan dismiss saat saving. Callback async picker memeriksa mounted.
- Popup dan konfirmasi tetap memakai guard/izin yang sama. Cancel mendapat fokus aman. Error load awal memakai pesan lokal EN/ID dan detail terpisah.

### Kontrak yang dipertahankan dan batas

Tidak mengubah model, Cubit, repository, SQL, cache, schema, router, teacher scope, menu/action authorization, validasi bentrok, rentang jam 09–22, perhitungan minggu/rentang, atau callback persistence. Timeline tetap kalender operasional dengan scroll horizontal tersinkron dan tanggal/header menetap; tidak diganti tabel umum. View/edit yang dibatasi izin tetap mengikuti perilaku sebelumnya.

Belum menambahkan dark mode karena proyek belum mempunyai theme gelap lengkap. Tidak merancang ulang algoritme kalender/virtualisasi atau kemampuan read-only baru. Uji DPI Windows fisik, multi-monitor dan Narrator masih perlu dilakukan di lingkungan desktop; widget text scaling tidak mewakili semuanya. Tidak memakai data pribadi untuk tes/preview.

### Verifikasi Jadwal

- Formatter: empat file Dart produksi/test terformat, pemeriksaan akhir menghasilkan 0 perubahan.
- Analyzer penuh: flutter analyze --no-pub bersih tanpa error, warning, atau info.
- Full flutter test --no-pub: 122 tes lulus. Termasuk 21 tes Jadwal baru dan tes penghapusan/cache/transaksi Jadwal yang sudah ada.
- Matriks workspace: 800x600, 1280x800, 1920x1080, 2560x1080; text scaling 100%, 125%, 150%, 200%; EN/ID, label panjang dan data sintetis.
- Interaksi: Ctrl+F, hasil pencarian/panah/Enter/Escape, kalender panah dan Shift+panah, kedua form pada 800x600 @200%, gagal simpan mempertahankan input, submit ganda diblokir, dismiss saat saving ditahan, error awal/retry, serta indikator loading dan refresh disabled.
- Preview dengan Poppins dan MaterialIcons diperiksa pada 1280x800 @100% dan 800x600 @200%. Satu tes preview tambahan lulus; tidak dimasukkan ke source test permanen.
- Diff fungsi pemilihan acara, rentang timeline, pencocokan pencarian, cakupan tanggal dan batas jam dibandingkan dengan commit sebelumnya: identik setelah whitespace dinormalisasi.
- Tidak ada dependency-boundary script khusus. Import dan diff diperiksa; shared/core tidak memperoleh dependency fitur. git diff --check bersih.
- flutter build windows --release --no-pub final berhasil (73.1 detik), output build/windows/x64/runner/Release/edukita.exe.

Status Jadwal: sudah commit dan push ke origin/main sebagai `cec69c0`. `analysis_options.yaml` dan `pubspec.lock` adalah perubahan lokal awal dan tidak dimasukkan ke commit Bantuan.

## Prioritas 3 — Detail Aktivitas Mengajar

### Audit dan design system

Surface yang diperiksa: header/aksi laporan, ringkasan dan catatan sesi, daftar/pencarian/kehadiran siswa, panel pelaporan, nilai kompetensi numerik dan bintang, catatan observasi, riwayat/edit catatan, serta konfirmasi sinkronisasi, reset, selesai dan pergantian tipe. Cubit, cache, repository dan transaksi ditelusuri untuk menjaga kontrak persistence. Design system tetap turquoise Edukita, Poppins, Material 3 dan kontrol Shadcn yang sudah ada, dengan semantic AppColors, AppSpacing dan AppRadii. Tidak menambahkan framework/dependency/palette.

| Severity | Lokasi | Masalah | Perubahan dan dampak |
|---|---|---|---|
| HIGH | Layout informasi sesi | Pada jendela pendek, ekspansi informasi mengganti seluruh workspace dan melepas draft siswa | Workspace selalu terpasang; informasi sesi dan catatan dapat dibuka/tutup tanpa menghapus draft |
| HIGH | Rating bintang | Gesture pointer saja, target sekitar 24 px, tanpa fokus/aksi screen reader | Widget rating 40x40 per bintang, langkah setengah, panah/Home/End, focus ring dan semantic slider |
| HIGH | Header, toolbar dan attendance select | Lebar tetap, aksi satu baris dan batas maxWidth select gagal pada teks 200% | Reflow berdasarkan lebar efektif, toolbar wrap, ukuran kolom dan batas dropdown mengikuti text scaling |
| MEDIUM | Form/dialog catatan | Dialog tidak mempunyai busy state lokal; submit ganda dan dismiss saat simpan tidak ditahan | Submit dijaga, controls nonaktif saat saving, PopScope, error komentar dekat field, input dipertahankan |
| MEDIUM | Hierarki aksi dan informasi | Reset berada dekat Complete; banyak panel bersarang; metadata penting dipotong | Reset menjadi secondary action berwarna error pada informasi sesi; section pelaporan tanpa frame berulang; metadata lengkap tersedia dalam ringkasan |
| MEDIUM | Font, status, error | Label/placeholder Shadcn tidak mengikuti Poppins; foreground status memakai warna terang; pesan normal memuat exception | Theme kontrol laporan memakai Poppins dan radius project; teks status kontras tinggi; pesan operasional lokal dengan detail diagnostik terpisah |

### Implementasi dan file utama

- `teaching_activity_detail_page.dart`: header, ringkasan, section dan dialog konsisten; daftar kehadiran/master-detail tetap dipertahankan. Pada ruang sempit dipakai pemilih pane yang sudah ada dengan minimum tinggi mengikuti teks. Riwayat dan konfirmasi mempunyai scroll yang sesuai ruang.
- `teaching_rating_input.dart`: komponen domain rating, mempertahankan nilai 0.5–5 dan pointer setengah/penuh; tombol minimal 40 px serta akses keyboard dan semantics.
- `app_desktop_workspace.dart`: ekstraksi pola layout yang sudah dipakai Jadwal untuk dua pemakaian nyata. `ScheduleWorkspace` tetap tersedia sebagai wrapper; tidak membuat dependency antarfitur.
- Pencarian siswa berlabel dan Ctrl+F bekerja sejak halaman dibuka. Ctrl+S mengikuti panel yang mendapat fokus, kehadiran atau pelaporan; tetap memakai handler validasi/simpan yang sama. List siswa memakai ScrollController dan Scrollbar yang sama.
- Dua ARB dan generated localization menambahkan pesan error operasional serta label rating. Test widget ditambah pada file detail dan `teaching_rating_input_test.dart`.

### Kontrak dan bagian yang dipertahankan

Tidak ada perubahan SQL, schema, repository, Cubit, cache, model atau rute. Normalisasi skor, validasi 0–100/0.5–5, kewajiban catatan izin, daftar siswa sesi, sinkronisasi siswa baru, konfirmasi pergantian tipe/reset/selesai, penguncian completed/cancelled, dan izin guru tetap. Perbandingan fungsi hydrate/merge draft, pengumpulan absensi, save attendance, save reporting, parse score dan change assessment type dengan HEAD menunjukkan kode identik setelah whitespace dinormalisasi.

Halaman daftar Aktivitas Mengajar tetap menjadi lingkup prioritas 5. Tidak menambahkan auto-save, shortcut global OS, dark mode atau algoritme penilaian baru. Uji DPI Windows fisik/multi-monitor/Narrator dan penggunaan dengan data produksi belum dilakukan. Semua fixture dan preview memakai data sintetis; session test berada di `.dart_tool` dan tidak masuk commit.

### Verifikasi prioritas 3

- Matriks 800x600, 1280x800, 1920x1080, 2560x1080; text scaling 100%, 125%, 150%, 200%; label EN/ID, metadata/kompetensi panjang dan 200 siswa sintetis.
- Draft antar-siswa, membuka/menutup informasi sesi, pencarian dan simpan keyboard, gagal simpan mempertahankan input, kehadiran, riwayat/edit catatan, validasi komentar, busy/dismiss/submit ganda, konfirmasi selesai/cancel, dan completed/cancelled read-only.
- Rating pointer setengah/penuh, target minimal 40 px, fokus keyboard, panah/Home/End, batas nilai, semantics dan disabled pada teks 200%.
- Preview Poppins diperiksa pada 1280x800 @100% dan 800x600 @200%. Label/placeholder yang awalnya tidak mengikuti font project diperbaiki dan preview diulang.
- Formatter enam file Dart produksi/test: 0 perubahan pada pemeriksaan akhir.
- flutter gen-l10n: berhasil; perubahan ARB dibatasi pada key baru tanpa reformat seluruh file.
- flutter analyze --no-pub: bersih tanpa error, warning atau info.
- flutter test --no-pub final: 146 tes lulus, termasuk 24 tes baru pada prioritas ini. Seluruh 51 tes fitur Aktivitas Mengajar juga lulus pada iterasi terarah.
- Ekstraksi workspace bersama ikut diverifikasi oleh tes Jadwal yang ada. Tidak ada script dependency-boundary khusus; diff/import diperiksa dan shared widget tidak mengimpor fitur.
- git diff --check: bersih.
- flutter build windows --release --no-pub berhasil (67.9 detik), output build/windows/x64/runner/Release/edukita.exe.

Status: perubahan prioritas 3 belum commit/push. Perubahan lokal awal `analysis_options.yaml` dan `pubspec.lock` tetap dipertahankan.

## Prioritas 4 — Siswa

### Audit sebelum implementasi

Surface yang diperiksa: daftar/statistik, pencarian dan filter, dua implementasi filter lama, pilihan cara menambah siswa, form cepat/lengkap, tabel draft wali/aktivitas, header profil/foto, overview, personal, keluarga, akademik/nilai ujian, perilaku, aktivitas dan lainnya/dokumen. Komponen section, info, metric, chart, tabel, tab dan scroll bersama ikut diperiksa. Repository, Cubit, model dan callback file ditelusuri untuk menjaga kontrak data.

Identitas tetap Poppins dan turquoise Edukita, Material 3 serta Shadcn yang sudah dipakai project. Warna berasal dari AppColors; spacing dan radius mengikuti token bersama. Tidak menambah framework, package, schema atau lapisan persistence.

| Severity | Lokasi | Masalah | Perubahan dan dampak |
|---|---|---|---|
| HIGH | Filter dan Quick Register | Dialog tanpa scroll memadai; panel filter berukuran tetap; form overflow saat teks besar | Konten dialog dapat digulir, pilihan tambah memakai list tanpa tinggi tetap, footer dapat wrap |
| HIGH | Header profil/foto | Tinggi profil tetap, badge overlap, unduh foto mengandalkan pointer/hover | Identitas tumbuh mengikuti isi, badge dalam Wrap, chart punya viewport sendiri, tombol unduh eksplisit dan fokus keyboard |
| HIGH | Aksi tabel siswa/wali/dokumen | Target 28–32 px, kolom dua aksi wali terlalu sempit untuk kontrol desktop | Target minimal 40 px, kolom aksi diperlebar, izin dan konfirmasi tetap dipanggil |
| MEDIUM | Toolbar/statistik | Satu baris, belum ada pencarian langsung; Done filter memerlukan Inquiry lagi | Layout adaptif/compact, pencarian nama + Ctrl+F/Enter, Done langsung memanggil filter yang sama |
| MEDIUM | Filter duplikat | Dua implementasi UI dengan perbedaan label/layout | Nama legacy tetap tersedia sebagai wrapper menuju satu draft editor; Cancel tidak menerapkan draft |
| MEDIUM | Form dan error | Close masih aktif saat saving; error teknis langsung ditampilkan | Busy guard, Ctrl+S, controls nonaktif, dismiss ditahan, pesan lokal dengan detail terpisah; input dipertahankan |
| MEDIUM | Detail dan tabel | Metadata dibatasi dua baris; field/grid tidak mempertimbangkan text scaling; header tabel hilang saat kosong | Teks membungkus, grid memakai lebar efektif, posisi scroll per tab, tabel kosong mempertahankan header; kolom angka ditandai eksplisit |
| MEDIUM | Sorting nama/kelas | Hanya membandingkan kode huruf pertama | Urutan alfabet nama/kelas lengkap untuk data di halaman aktif; cakupan sorting/pagination tetap sama |

### Perubahan dan file utama

- `students_page.dart`: workspace desktop bersama, statistik compact, pencarian berlabel, filter langsung diterapkan, error/retry, pilihan tambah intrinsik, sorting alfabet dan target aksi. Filter tetap memakai MultiFilterItem, buildStudentFilter dan StudentPageCubit.applyFilter.
- `quick_student_form_dialog.dart`, `student_form_dialog.dart`, `student_form_card.dart`: maksimum lebar form 720 px, scroll mengikuti viewport, grid mengikuti skala teks, spacing token, Ctrl+S, close berlabel, kontrol/busy/duplikat/dismiss serta error yang mempertahankan input. Section form disederhanakan tanpa shadow berulang. Wali dan aktivitas tetap memakai draft serta validasi yang sama.
- `student_detail_page.dart`, `student_header_detail.dart`, `student_info_tile.dart`: header nama sederhana, loading/error/retry, identitas tidak terikat tinggi tetap dan foto mempunyai aksi unduh keyboard. Nama di app bar ditahan sampai akses diperiksa. Loading/error status wali tidak ditampilkan sebagai klasifikasi yang sudah berhasil dimuat.
- `detail_section_card.dart`, `detail_info_pill.dart`, `detail_metric_*`, `student_info_item.dart`, `student_information_section.dart`: metadata membungkus, grid dan ringkasan adaptif; nested frame informasi dikurangi.
- `detail_data_table.dart`: header tetap pada empty state, long text terbaca, scroll horizontal memiliki controller yang sama dengan Scrollbar, kolom angka dapat diratakan kanan dan memakai tabular figures. Dipakai untuk pendapatan wali dan ringkasan nilai yang relevan; nilai yang disimpan tidak berubah.
- Tujuh tab memperoleh identitas PageStorage untuk scroll, menggunakan komponen detail yang sama. Target aksi dokumen diperbesar. Student story mempertahankan generator PDF; foreground tombol primary mengikuti onPrimary.
- `app_shad_theme.dart`: ekstraksi style font/radius yang sudah digunakan di prioritas 3 untuk pemakaian nyata lintas form. Helper tetap feature-agnostic dan tidak mengimpor module bisnis.
- ARB EN/ID dan generated output diperbarui untuk pencarian nama, load error dan save error. Dua file tes UI siswa ditambahkan.

### Kontrak dan batas yang dipertahankan

Tidak ada perubahan repository, Cubit, model, SQL, schema, permission grant, router, data anak/wali, penomoran siswa, default kelas quick-register, klasifikasi domain, relasi keluarga, perhitungan/normalisasi nilai atau persistence dokumen. Perbandingan dengan snapshot source awal menunjukkan builder guardian/advanced data, validasi wali/tanggal, penyimpanan dan penerapan foto/form registrasi tetap identik setelah normalisasi whitespace serta trailing comma formatter.

Kontrak callback, validasi field wajib (termasuk orang tua dan rumah tangga), aturan file, cleanup kegagalan, cache revision dan refresh setelah perubahan eksternal dipertahankan. Tidak mengubah sorting menjadi query lintas semua halaman: header tetap mengurutkan halaman yang sedang dimuat. Pencarian baru secara eksplisit mencari nama, lalu digabung dengan filter aktif melalui API yang ada.

Dialog sekunder ujian/wali/aktivitas/catatan tidak ditulis ulang seluruh workflow-nya; memperoleh manfaat theme, target aksi dan komponen bersama. Native picker/drop, download/export PDF dan operasi berkas nyata belum diuji end-to-end. Tidak menambahkan auto-save, dark mode, konflik versi atau sinkronisasi baru. DPI Windows fisik, perpindahan monitor dan Narrator masih memerlukan pengujian desktop. Semua fixture/preview sintetis dan tidak memakai data siswa/wali nyata.

### Verifikasi prioritas 4

- Daftar dan tujuh tab detail: 800x600, 1280x800, 1920x1080, 2560x1080; text scaling 100%, 125%, 150%, 200%; EN/ID; nama/metadata panjang, data halaman 20 baris dari total sintetis 200.
- Filter dan kedua form: 800x600 dan 1280x800 pada keempat skala; seluruh section form lengkap dibuka; draft filter Cancel/Done, validasi field, gagal simpan/retry, input dipertahankan, submit ganda dan dismiss saat saving.
- Ctrl+F dan Enter pada pencarian; Ctrl+S pada kedua form dalam tes simpan gagal/retry; sorting nama yang memiliki awalan sama; pagination; refresh error mempertahankan baris; tabel 30 baris/teks panjang pada 200% dan empty header.
- Seluruh 33 tes fitur Siswa lulus pada iterasi terarah. Preview Poppins daftar, profil dan form diperiksa pada 1280x800 @100% dan 800x600 @200%; satu tes render tambahan lulus.
- Formatter seluruh 36 file Dart yang berubah/baru: 0 perubahan pada pemeriksaan akhir.
- flutter gen-l10n berhasil; key ARB prioritas sebelumnya tetap dipertahankan.
- flutter analyze --no-pub bersih tanpa error, warning atau info.
- flutter test --no-pub: 177 tes lulus, termasuk 31 tes baru untuk prioritas ini. Tes fitur Siswa terarah: 33 lulus.
- git diff --check bersih. Tidak ada dependency-boundary script khusus; import/diff diperiksa, shared theme tidak bergantung pada feature.
- flutter build windows --release --no-pub berhasil (71.8 detik), output build/windows/x64/runner/Release/edukita.exe.

Status: prioritas 3 dan 4 belum commit/push. Perubahan lokal awal `analysis_options.yaml` dan `pubspec.lock` tetap dipertahankan.
