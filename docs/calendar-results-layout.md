# Kalender kiri dan hasil kanan

Tanggal: 18 November 2026. Lingkup: mengembalikan pola desktop yang dipilih pengguna untuk Aktivitas Mengajar dan Jadwal, lalu membuat tinggi baris serta lebar kolom jam Jadwal mengikuti isi.

## Audit dan keputusan sebelum implementasi

Inventaris: teaching_activity_page.dart, schedule_page.dart, kalender tanggal, filter hasil, timeline/header jam, kartu jadwal/acara, scroll controller, Cubit/state, caller dan tes terkait. Riwayat sebelum restyle diperiksa: Aktivitas Mengajar memakai kalender 286 px dan breakpoint 920 px; Jadwal kalender 300 px dan breakpoint 940 px. Pattern kiri–kanan dipulihkan dengan kalender dasar 320 px agar tujuh tanggal tetap memiliki target minimal 40 px setelah padding/border.

| Severity | Lokasi | Masalah | Perubahan dan dampak |
|---|---|---|---|
| MEDIUM | Aktivitas Mengajar | Breakpoint efektif 1100 dan kalender 406 px membuat kalender turun ke atas hasil pada desktop umum setelah sidebar/scaling | Kalender lebih ringkas di kiri, tabel hasil tetap di kanan; batas berdasarkan kebutuhan nyata kedua panel |
| MEDIUM | Jadwal | Breakpoint efektif 1160 dan kalender compact disembunyikan dalam disclosure | Kalender selalu terlihat. Kalender kiri dan timeline kanan dipakai selama ruang cukup; susunan vertikal hanya untuk area yang lebih sempit |
| MEDIUM | Timeline Jadwal | Semua baris setinggi minimal 128 px dan semua jam minimal 176 px, termasuk area kosong | Baris kosong rendah dan jam kosong sempit; slot berisi memakai lebar lebih besar; tinggi baris mengikuti slot dengan jumlah kartu terbanyak |
| MEDIUM | Timeline isi padat | Scroll kecil per sel menyembunyikan item bertumpuk | Semua kartu ditampung oleh tinggi baris yang dihitung; scrolling vertikal melalui timeline utama |
| LOW | Panel hasil | Panel selalu mengisi tinggi tersedia, walau isi sedikit | Flexible dengan ukuran minimum konten membuat panel mengikuti isi dan tetap dibatasi viewport jika panjang |

Desain tetap menggunakan Poppins, semantic AppColors, AppSpacing/AppRadii, tombol/focus/tooltip serta komponen Material dan tabel yang ada. Tidak menambah framework atau dependency.

## Implementasi

- teaching_activity_page.dart: kalender dasar 320 × text scale dan ruang hasil minimum 480 × text scale, gap 16; kedua panel berdampingan ketika ruang memenuhi kebutuhan tersebut. Kalender memiliki Scrollbar/ScrollView dengan controller yang sama dan dispose yang jelas. Pada area kecil kalender tetap terbuka dengan lebar terbatas dan hasil di bawah.
- schedule_page.dart: pola split yang sama, kalender selalu terlihat pada fallback compact, scroll kalender terpisah dari timeline.
- Slot timeline dihitung sekali dari jadwal/acara yang sudah melewati filter yang ada. Daftar slot yang sama dipakai untuk menentukan ukuran dan merender kartu, termasuk event lintas hari.
- Lebar jam kosong minimal 80 px; jam berisi tetap memakai lebar minimum 176 px dan bertambah menurut text scale. Header dan grid memakai satu vector lebar dan controller sinkron yang sudah ada.
- Tinggi hari kosong mengikuti kebutuhan label tanggal yang kini ringkas. Tinggi hari berisi mengikuti kartu terbesar/bertumpuk per slot, padding, gap dan border; ukuran dibulatkan ke skala 8. Batas hit target dan text scaling tetap.
- Kolom tanggal dan seluruh sel pada hari yang sama memakai satu tinggi baris. Pilihan tanggal, multi-day coverage, rentang jam 09–22, urutan kartu, search, hak akses serta aksi CRUD tetap.
- tests operations/schedule: delapan regresi split pada ruang konten 1040 @100%, 1100 @125%, 1366 @150%, 1920 @200%; empat regresi ukuran isi/filter/scroll pada 100/125/150/200%, serta event lintas hari. Tes compact memastikan kalender tidak dibungkus disclosure; disclosure toolbar sekunder tetap diperbolehkan.

## Kontrak dan verifikasi

Tidak ada perubahan Cubit/repository, SQLite/schema, model publik, cache, route, permission, aturan waktu atau transaksi. Pemilihan scope aktivitas, otorisasi, refresh cache, predicate search/coverage, rentang tanggal dan handler simpan/hapus dibandingkan dengan snapshot source awal. Perubahan adalah pada penyajian, ukuran slot dan penyusunan data UI yang sudah difilter.

- Tes halaman yang sudah ada: matriks Aktivitas Mengajar 560x600–2560x1080 dan Jadwal 800x600–2560x1080, masing-masing text scaling 100/125/150/200%, EN/ID, kalender keyboard/range, search, empty/loading/error, dialog dan busy.
- Tes ukuran isi: kosong mengecil, beberapa item bertumpuk memperbesar baris, tinggi tanggal/grid sama, lebar header/grid sama, posisi header-grid tetap selaras setelah scroll dan pencarian mempersempit hasil. Sel tidak memiliki scroll vertikal tersendiri. Event lintas hari hanya muncul pada tanggal/jam yang tercakup.
- Preview Poppins/MaterialIcons diperiksa pada ruang konten 1040x800 @100%, 1100x800 @125%, 1280x800 @100% dan 800x600 @200%; data/session sintetis dan terisolasi di .dart_tool.
- DPI Windows fisik, multi-monitor dan Narrator tidak diuji langsung. Tidak mengubah data nyata atau me-reset aplikasi/database pada tugas ini.
- Verifikasi akhir: formatter empat file Dart, 0 perubahan tersisa; flutter analyze --no-pub tanpa issue (6.2 detik); flutter test --no-pub, 295 tes lulus termasuk 13 regresi baru; flutter build windows --release --no-pub berhasil (79.5 detik), output build/windows/x64/runner/Release/edukita.exe. Tes render tambahan final lulus; preview delapan kombinasi halaman/ukuran diperiksa. git diff --check bersih. Tidak ada perubahan fungsional setelah verifikasi ini.

Status implementasi: selesai dan terverifikasi. Pada tahap penutupan pengguna meminta commit all dan push, termasuk konfigurasi analyzer, lockfile serta pembaruan versi 1.1.2 yang sudah ada di workspace. Tidak mengubah isi perubahan pengguna tersebut.
