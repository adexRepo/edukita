# Edukita

# 📘 Requirement Sistem Informasi Baitul Hikmah  

## 1. Latar Belakang & Definisi  
---  
Baitul Hikmah (Bayt al-Hikmah) merupakan pusat pengembangan ilmu pengetahuan dan penerjemahan pada masa kejayaan peradaban Islam di Baghdad. Institusi ini menjadi simbol integrasi antara ilmu, sistem, dan manajemen pengetahuan.  

Dengan semangat yang serupa, sistem ini dirancang sebagai platform manajemen informasi pendidikan terintegrasi untuk mendukung operasional dan pengambilan keputusan di lingkungan Yayasan Alkahfi.  

Sistem ini berfungsi sebagai *single source of truth* dalam pengelolaan data pendidikan, guna meningkatkan kualitas pembelajaran, efisiensi operasional, dan objektivitas evaluasi.  

---

## 2. Identifikasi Permasalahan  
---  
Berdasarkan observasi empiris dan pengalaman operasional di bidang pengajaran, ditemukan beberapa permasalahan utama:  

1. Kurangnya pemahaman komprehensif terhadap karakteristik siswa.  
2. Keterbatasan jumlah dan distribusi tenaga pengajar.  
3. Ketidakterstandarisasian materi dan silabus antar kelas maupun institusi.  
4. Manajemen jadwal pembelajaran yang tidak terstruktur.  
5. Tidak adanya perencanaan dan strategi pembelajaran yang terdokumentasi dengan baik.  
6. Evaluasi progres siswa yang bersifat subjektif dan tidak berbasis data.  
7. Dokumentasi kegiatan yang tidak terorganisir.  
8. Kesulitan dalam penyusunan laporan pembelajaran periodik.  
9. Manajemen lingkungan belajar (pengondisian) yang tidak sistematis.  
10. Data yang tidak terstruktur untuk mendukung pengambilan keputusan (misalnya penentuan penerima beasiswa).  

---

## 3. Solusi yang Diusulkan  
---  
Sistem ini dirancang sebagai *Education Management Information System (EMIS)* yang terintegrasi, dengan cakupan sebagai berikut:  

### 3.1 Manajemen Data Siswa  
Menyediakan profil siswa yang komprehensif, meliputi:  

1. Data identitas pribadi.  
2. Latar belakang lingkungan (sekolah dan keluarga).  
3. Data orang tua/wali.  
4. Relasi sosial (pertemanan).  
5. Riwayat interaksi dengan pengajar.  
6. Riwayat akademik dan penilaian.  
7. Dokumentasi (foto/video).  
8. Catatan perilaku dan perkembangan.  

---

### 3.2 Manajemen Data Pengajar  
Mencakup:  

1. Profil pengajar.  
2. Latar belakang pendidikan.  
3. Pengalaman mengajar.  
4. Spesialisasi bidang.  
5. Jadwal mengajar.  

---

### 3.3 Standarisasi Materi dan Silabus  

1. Penyusunan materi berbasis level/kelas.  
2. Integrasi dengan kurikulum resmi (misalnya dari dinas pendidikan).  
3. Penyediaan repository materi terstruktur.  

---

### 3.4 Manajemen Jadwal Pembelajaran  

1. Penjadwalan terintegrasi antara siswa, pengajar, waktu, dan lokasi.  
2. Pengelolaan konflik jadwal.  
3. Monitoring kehadiran.  

---

### 3.5 Perencanaan dan Strategi Pembelajaran  

Sistem menyediakan repository strategi pembelajaran yang dapat digunakan ulang, seperti:  

1. Direct Instruction: Penjelasan → Latihan → Evaluasi.  
2. Contextual Learning: Observasi → Analisis → Refleksi.  
3. Problem-Based Learning: Identifikasi masalah → Analisis → Solusi → Evaluasi.  
4. Gamification-Based Learning.  

Tujuan: meningkatkan konsistensi dan efisiensi pengajaran.  

---

### 3.6 Manajemen Pengondisian Lingkungan Belajar  

Meliputi:  

1. Aturan disiplin.  
2. Manajemen visual (mading, poster edukatif).  
3. Standar perilaku dan budaya yayasan.  
4. Aktivitas pembentukan karakter.  

---

### 3.7 Sistem Evaluasi dan Progress Siswa  

Penilaian berbasis data, meliputi:  

1. Nilai akademik (rapor, latihan).  
2. Kehadiran.  
3. Interaksi pembelajaran.  
4. Penilaian akhlak.  

Output:  

1. Dashboard analitik (chart performa siswa).  
2. Ranking siswa (akademik, akhlak, keaktifan).  
3. Rekomendasi penerima beasiswa berbasis data.  

---

### 3.8 Manajemen Dokumentasi  

1. Dokumentasi kegiatan pembelajaran.  
2. Dokumentasi program yayasan (beasiswa, sosial, dll).  
3. Arsip kegiatan khusus (study tour, donasi, kurban, dll).  

---

### 3.9 Sistem Pelaporan (Reporting)  

1. Laporan perkembangan siswa (real-time & periodik).  
2. Laporan performa pengajar.  
3. Laporan operasional yayasan.  
4. Insight berbasis data untuk pengambilan keputusan strategis.  

---

## 4. Arsitektur & Pengembangan Aplikasi  
---  

### 4.1 Karakteristik Sistem  

1. Aplikasi internal (highly restricted access).  
2. Data bersifat sensitif (high confidentiality).  
3. Role-based access (otorisasi terbatas).  

---

### 4.2 Model Deployment  

Beberapa opsi implementasi:  

1. Desktop-based (offline-first): hanya pada perangkat tertentu.  
2. Local network (intranet-based): hanya dapat diakses dalam jaringan internal yayasan.  
3. Centralized system (future state):  
   3.1. Integrasi antar cabang.  
   3.2. Sinkronisasi data ke pusat.  
   3.3. Monitoring nasional oleh manajemen pusat.  

---

### 4.3 Roadmap Pengembangan  

1. Phase 1: Desktop / Local system / Offline System.  
2. Phase 2: Web-based internal system.  
3. Phase 3: Mobile application dengan enhanced security.  

---

## 5. Teknologi  
---  

### 5.1 Tech Stack  

1. Frontend: Flutter (cross-platform, rapid development).  
2. Backend: REST API / modular architecture.  
3. Database: Relational DB dengan strong consistency (ACID compliant, misalnya PostgreSQL).  

---

## 6. Keamanan Sistem (Security Architecture)  
---  
Mengacu pada standar dari OWASP, sistem harus memenuhi prinsip *defense in depth*:  

---

### 6.1 Access Control  

1. VPN-based access restriction.  
2. Device whitelisting.  
3. Role-Based Access Control (RBAC).  
4. Token-based authentication (short-lived token).  

---

### 6.2 Authentication & Verification  

1. Multi-Factor Authentication (MFA).  
2. Biometric (opsional, mobile).  
3. Session management yang aman.  

---

### 6.3 Data Protection  

1. Enkripsi data (in transit: HTTPS/TLS).  
2. Enkripsi data sensitif (at rest).  
3. Secure key management.  

---

### 6.4 Application Security  

Proteksi terhadap:  

1. SQL Injection.  
2. Cross-Site Scripting (XSS).  
3. Cross-Site Request Forgery (CSRF).  
4. Broken Access Control.  
5. Input validation & sanitization.  
6. Rate limiting (anti abuse API).  

---

### 6.5 Mobile & Client Security  

1. Code obfuscation.  
2. No secret stored di client.  
3. Backend validation.  
4. Anti reverse engineering.  

---

### 6.6 Operational Security  

1. Disable debug mode di production.  
2. Logging & monitoring.  
3. Incident response mechanism.  

---

### 6.7 Kebijakan Penggunaan  

1. Akses hanya melalui jaringan terpercaya.  
2. Larangan penggunaan WiFi publik tanpa proteksi.  
3. Pengamanan perangkat (device security awareness).  

---

## 7. Kesimpulan  
---  
Sistem Baitul Hikmah ini dirancang sebagai platform strategis untuk:  

1. Meningkatkan kualitas pendidikan berbasis data.  
2. Menstandarisasi proses pembelajaran.  
3. Mendukung pengambilan keputusan yang objektif.  
4. Membangun ekosistem pendidikan yang terintegrasi dan berkelanjutan.  

Dalam jangka panjang, sistem ini berpotensi menjadi *core platform* pendidikan yayasan yang dapat diskalakan secara nasional.  