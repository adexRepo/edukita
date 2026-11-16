# Prioritas restyle halaman Edukita

Tanggal: 16 November 2026. Urutan mengikuti permintaan pengguna: kebutuhan perubahan terbesar lebih dahulu. Dasar penilaian adalah luas workflow, jumlah layout/dialog khusus, reflow desktop dan text scaling, konsistensi komponen, serta state/keyboard yang perlu diverifikasi. Jumlah baris membantu inventaris, bukan ukuran tunggal kualitas UI atau perkiraan waktu yang pasti.

Theme, komponen bersama, shell/sidebar, title bar Windows, dan dashboard sudah direstyle pada tahap sebelumnya (`d722c59`, `06f9079`). Halaman lain sudah menerima perbaikan komponen bersama tetapi belum otomatis dianggap selesai direstyle secara khusus.

| Urutan | Halaman / alur | Kebutuhan perubahan | Bukti source dan lingkup berikutnya | Status |
|---|---|---|---|---|
| 1 | Periode Bantuan (`assistance_periods_page.dart`) | Sangat besar | Sebelum perubahan: sekitar 4.978 baris; daftar, empat tab detail, target per aturan, review/persetujuan, penerima/bukti, wizard tiga langkah dan beberapa dialog khusus. Header, ringkasan, setup dan review berisiko melebihi jendela; aksi tabel tidak wrap; target kecil; wizard memakai warna navy terpisah dari brand. | Workspace utama dan wizard diterapkan pada tahap ini; lihat verifikasi di bawah |
| 2 | Jadwal (`schedule_page.dart`) | Sangat besar | Sekitar 3.456 baris; kalender/timeline, overlay pencarian, sinkronisasi scroll dan form jadwal/acara. Perlu penataan toolbar, sel kalender, dialog, focus, serta pengujian setiap mode. | Berikutnya |
| 3 | Detail Aktivitas Mengajar (`teaching_activity_detail_page.dart`) | Besar | Sekitar 3.315 baris; beberapa area data, attendance/nilai/kompetensi, aksi status dan banyak ukuran lokal. Sudah memiliki reflow dan tes fungsional; perlu standardisasi surface, kontrol, dan hierarchy per area. | Belum restyle khusus |
| 4 | Siswa: daftar, filter, form, tab detail | Besar | Daftar sekitar 1.671 baris, ditambah form/detail terpisah; statistik satu baris, toolbar, dua implementasi dialog filter, form besar, dan row action kecil. | Belum restyle khusus |
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

Status: perubahan tahap ini belum commit/push. Perubahan lokal awal pada `analysis_options.yaml` dan `pubspec.lock` tetap dipertahankan.
