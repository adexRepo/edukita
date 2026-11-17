# Penyederhanaan Settings

Tanggal: 17 November 2026. Lingkup: merapikan Settings serta menghapus kontrol yang tidak berpengaruh pada aplikasi. Identitas Edukita, Poppins, semantic colors, spacing 4/8/12/16/24/32/48 dan komponen Material bersama tetap.

## Audit sebelum implementasi

Diperiksa: SettingsPage, AppSettingsData/SettingsRepository, AppLanguageCubit/LocaleStorage, route Settings dan Ganti Password, cache services, helper nama file, pemakaian key settings di seluruh lib, serta tes administrasi.

| Severity | Lokasi | Temuan | Keputusan dan dampak |
|---|---|---|---|
| HIGH | Default Umum | Nama yayasan, prefix ekspor, kode/simbol mata uang, ambang kehadiran default dan rentang dashboard tersimpan tetapi tidak ditemukan consumer otomatis di fitur aplikasi | Enam kontrol dihapus dari UI agar tidak memberi kesan mengubah perilaku. Nilai/key/model dan repository tetap dipertahankan |
| HIGH | Save Settings | Form bahasa juga membangun ulang semua nilai umum dari controller dan memvalidasi persentase yang tidak digunakan | Save hanya mengganti language melalui copyWith pada record yang dimuat; seluruh nilai lain tetap. Ctrl+S tidak melakukan write tanpa perubahan |
| MEDIUM | Personalisasi | Ada dua tombol save pada halaman, banner bahasa mengulang pilihan, deskripsi menyebut density/format yang tidak tersedia, label Save & Refresh tidak menjelaskan efek | Satu section Bahasa dan satu tombol Simpan; teks menjelaskan kapan bahasa diterapkan; save disabled sampai ada perubahan |
| MEDIUM | Layout | Workspace data-grid ditumpuk dengan scroll form, menambah dua area scroll dan viewport buatan | Satu scroll dengan controller/Scrollbar yang sama, konten max 720 px; kontrol/action sejajar pada desktop dan bertumpuk ketika ruang efektif menyempit |
| MEDIUM | Pemeliharaan | Banner admin berulang; path/schema terlalu menonjol; cakupan backup kurang jelas | Backup/cache tetap aksi langsung khusus admin, path/schema dalam disclosure Penyimpanan. Teks menyebut backup database tidak menyertakan dokumen unggahan |
| LOW | Tentang | Nama produk diulang dengan heading Edukita | Hilangkan pasangan Product/Edukita yang berulang; versi/build dan penerbit tetap |

Bukti pemakaian: SettingsRepository hanya diregistrasi di service_locator.dart dan dipanggil SettingsPage; nama/key enam default tidak dibaca consumer aplikasi lain. Format Rupiah, helper generatedFileName, parameter periode bantuan dan rentang dashboard tidak mengambil nilai umum tersebut. Query/report kustom tetap dapat mengakses nilai lama karena persistence tidak dihapus.

## Implementasi

- settings_page.dart: empat section utama untuk admin (Bahasa, Keamanan Akun, Pemeliharaan, Tentang); staff/teacher mendapat Bahasa, Keamanan Akun dan Tentang. Header dan section lebih ringkas; satu Material surface memastikan hover/ink disclosure terlihat.
- Bahasa tampil sesuai locale AppLanguageCubit yang sedang aktif. Simpan dan Ctrl+S hanya aktif jika pilihan berubah; duplicate submission dan input selama saving tetap diblokir; kegagalan simpan mempertahankan pilihan dan menawarkan detail error lewat helper yang ada.
- AppSettingsData yang dimuat disalin dengan language baru. Tidak ada fallback/default baru yang menimpa foundation, currency, prefix, attendance, dashboard, theme, density atau format tersimpan.
- BackupDatabase, ClearCaches, pemuatan package info, serta route Ganti Password tetap. Fungsi backup/cache/package-info dibandingkan dengan snapshot awal dan identik setelah whitespace/trailing comma dinormalisasi. Pemeriksaan admin tetap memakai session.isAdmin; state staff yang hanya mengontrol form nonaktif dihapus.
- Path database/upload dan schema tetap dapat diperiksa admin melalui Penyimpanan. Clear Cache dijelaskan sebagai cache sementara, tanpa penghapusan record/dokumen.
- ARB EN/ID dan hasil generate diperbarui untuk penjelasan yang sesuai kontrol nyata. Tidak menghapus key database atau field model lama.
- Tes administrasi diperbarui untuk alur bahasa, ditambah regresi preservasi semua nilai lama dan disclosure/visibility tiga role pada teks 200%.

## Verifikasi dan batas

- Matriks administrasi lima lebar: 560x600 (area setelah sidebar), 800x600, 1280x800, 1920x1080, 2560x1080; text scaling 100/125/150/200%; EN/ID.
- Regresi: gagal load mengunci save, Retry, Ctrl+S submit tunggal, gagal save mempertahankan pilihan, no-op save, locale diterapkan dan nilai legacy dipertahankan; akses admin/staff/teacher, satu scroll, disclosure path/schema pada 200%.
- Preview Poppins/MaterialIcons diperiksa pada 1280x800 @100% dan 800x600 @200%, admin serta nonadmin; data/session terisolasi dan sintetis.
- Repository/schema, format dan mekanisme backup, cache invalidation, password/session, route, serta dependensi tidak diubah. Tidak menguji backup database nyata, folder picker Windows, DPI fisik/multi-monitor atau Narrator. Tidak menambah dark mode atau opsi yang belum terhubung ke aplikasi.
- Verifikasi akhir: formatter dua file Dart, 0 perubahan tersisa; flutter analyze --no-pub tanpa issue (5.7 detik); flutter test --no-pub, 282 tes lulus; flutter build windows --release --no-pub berhasil (71.3 detik), menghasilkan build/windows/x64/runner/Release/edukita.exe. Satu tes render tambahan final lulus. git diff --check bersih. Tidak ada perubahan fungsional setelah checks ini.

Status implementasi: selesai dan terverifikasi. Commit dan push kelompok penyederhanaan Settings diminta pengguna pada tahap penutupan. analysis_options.yaml, pubspec.lock dan management_page.dart yang sudah dirty pada awal tugas tidak diubah.
