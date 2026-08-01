// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Edukita';

  @override
  String get menuDashboard => 'Beranda';

  @override
  String get menuStudents => 'Siswa';

  @override
  String get menuTeachers => 'Guru';

  @override
  String get menuSyllabus => 'Silabus';

  @override
  String get menuStrategy => 'Strategi';

  @override
  String get menuSchedule => 'Jadwal';

  @override
  String get menuReports => 'Laporan';

  @override
  String get menuManagement => 'Manajemen';

  @override
  String get menuSettings => 'Pengaturan';

  @override
  String get menuTeachingActivity => 'Aktivitas Mengajar';

  @override
  String get menuParameter => 'Parameter';

  @override
  String get menuAssistancePrograms => 'Program Bantuan';

  @override
  String get menuUserManagement => 'Manajemen Pengguna';

  @override
  String get menuPreferences => 'Preferensi';

  @override
  String get menuLogout => 'Keluar';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get changeLanguage => 'Ubah Bahasa';

  @override
  String get language => 'Bahasa';

  @override
  String get english => 'Inggris';

  @override
  String get bahasaIndonesia => 'Bahasa Indonesia';

  @override
  String get currentLanguage => 'Bahasa Saat Ini';

  @override
  String get languageUpdated => 'Bahasa berhasil diperbarui';

  @override
  String get rejectedBy => 'Ditolak Oleh';

  @override
  String get rejectedAt => 'Ditolak Pada';

  @override
  String get rejectionReasonRequired => 'Alasan penolakan wajib diisi.';

  @override
  String get downloadApprovalDocument => 'Unduh Dokumen Persetujuan';

  @override
  String get personalization => 'Personalisasi';

  @override
  String get personalizationDescription =>
      'Preferensi pengguna untuk bahasa, kepadatan tampilan, serta format tanggal atau angka.';

  @override
  String get generalDefaults => 'Default Umum';

  @override
  String get generalDefaultsDescription =>
      'Nilai ini digunakan sebagai default aplikasi untuk ekspor, label mata uang, dan aturan kelayakan.';

  @override
  String get technicalSettingsAdminOnly =>
      'Pengaturan teknis di bawah ini hanya terlihat untuk pengguna admin.';

  @override
  String get buttonSave => 'Simpan';

  @override
  String get buttonSaveAndRefresh => 'Simpan & Muat Ulang';

  @override
  String get buttonCancel => 'Batal';

  @override
  String get buttonEdit => 'Ubah';

  @override
  String get buttonDelete => 'Hapus';

  @override
  String get buttonRemove => 'Hapus';

  @override
  String get buttonAdd => 'Tambah';

  @override
  String get buttonSearch => 'Cari';

  @override
  String get buttonReset => 'Reset';

  @override
  String get buttonClose => 'Tutup';

  @override
  String get buttonConfirm => 'Konfirmasi';

  @override
  String get buttonBack => 'Kembali';

  @override
  String get buttonNext => 'Lanjut';

  @override
  String get buttonContinue => 'Lanjutkan';

  @override
  String get buttonSaving => 'Menyimpan';

  @override
  String get statusActive => 'Aktif';

  @override
  String get status => 'Status';

  @override
  String get statusInactive => 'Tidak Aktif';

  @override
  String get statusDraft => 'Draf';

  @override
  String get statusApproved => 'Disetujui';

  @override
  String get statusRejected => 'Ditolak';

  @override
  String get statusCompleted => 'Selesai';

  @override
  String get statusCancelled => 'Dibatalkan';

  @override
  String get statusTargeted => 'Ditargetkan';

  @override
  String get statusSubmitted => 'Diajukan';

  @override
  String get statusDistributed => 'Didistribusikan';

  @override
  String get statusPaid => 'Dibayar';

  @override
  String get genderMale => 'Laki-laki';

  @override
  String get genderFemale => 'Perempuan';

  @override
  String get attendancePresent => 'Hadir';

  @override
  String get attendanceAbsent => 'Tidak Hadir';

  @override
  String get attendanceSick => 'Sakit';

  @override
  String get attendancePermission => 'Izin';

  @override
  String get attendanceLate => 'Terlambat';

  @override
  String get studentName => 'Nama Siswa';

  @override
  String get studentCode => 'Kode Siswa';

  @override
  String get teacherName => 'Nama Guru';

  @override
  String get className => 'Kelas';

  @override
  String get school => 'Sekolah';

  @override
  String get subject => 'Mata Pelajaran';

  @override
  String get subjects => 'Mata Pelajaran';

  @override
  String get unit => 'Unit';

  @override
  String get competency => 'Kompetensi';

  @override
  String get records => 'Data';

  @override
  String get checkIn => 'Check In';

  @override
  String get scheduleDate => 'Tanggal Jadwal';

  @override
  String get scheduleCalendar => 'Kalender Jadwal';

  @override
  String scheduleHeaderSummary(Object scheduleCount, Object eventCount) {
    return '$scheduleCount jadwal mengajar, $eventCount event';
  }

  @override
  String get scheduleAccessDenied =>
      'Anda tidak memiliki izin untuk melihat jadwal.';

  @override
  String get scheduleCreateDenied =>
      'Anda tidak memiliki izin untuk membuat jadwal.';

  @override
  String get scheduleUpdateDenied =>
      'Anda tidak memiliki izin untuk mengubah jadwal ini.';

  @override
  String get scheduleDeleteDenied =>
      'Anda tidak memiliki izin untuk menghapus jadwal ini.';

  @override
  String get eventCreateDenied =>
      'Anda tidak memiliki izin untuk membuat event.';

  @override
  String get eventUpdateDenied =>
      'Anda tidak memiliki izin untuk mengubah event.';

  @override
  String get eventDeleteDenied =>
      'Anda tidak memiliki izin untuk menghapus event.';

  @override
  String get userNotLinkedTeacher =>
      'User Anda belum terhubung ke profil guru.';

  @override
  String get refreshSchedules => 'Muat ulang jadwal';

  @override
  String get findScheduleHint => 'Cari jadwal, event, guru, level';

  @override
  String get addScheduleOrEvent => 'Tambah jadwal atau event';

  @override
  String get teachingSchedule => 'Jadwal mengajar';

  @override
  String get teachingScheduleRequiresUnit =>
      'Buat minimal satu unit silabus di Parameter > Academic > Units sebelum menambahkan jadwal mengajar.';

  @override
  String get teachingScheduleRequiresUnitShort =>
      'Buat unit silabus terlebih dahulu';

  @override
  String get schoolEvent => 'Event sekolah';

  @override
  String get otherEvent => 'Event lainnya';

  @override
  String get events => 'Event';

  @override
  String get noSchoolEventOnDate => 'Tidak ada event sekolah pada tanggal ini.';

  @override
  String get noTeacherAssigned => 'Belum ada guru';

  @override
  String get noMatchingSchedule => 'Tidak ada jadwal atau event yang cocok.';

  @override
  String get deleteSchedule => 'Hapus Jadwal';

  @override
  String get deleteEvent => 'Hapus Event';

  @override
  String deleteScheduleConfirm(Object name) {
    return 'Hapus $name?';
  }

  @override
  String deleteEventConfirm(Object name) {
    return 'Hapus $name?';
  }

  @override
  String get thisSchedule => 'jadwal ini';

  @override
  String get addSchedule => 'Tambah Jadwal';

  @override
  String get editSchedule => 'Ubah Jadwal';

  @override
  String get addEvent => 'Tambah Event';

  @override
  String get editEvent => 'Ubah Event';

  @override
  String get eventName => 'Nama Event';

  @override
  String get wholeDay => 'Sepanjang hari';

  @override
  String get wholeDaySubtitle =>
      'Gunakan jika event berlangsung sepanjang hari yang dipilih.';

  @override
  String get wholeDayUnavailableSubtitle =>
      'Sepanjang hari hanya tersedia untuk event satu hari.';

  @override
  String get endDateAfterStartDate =>
      'Tanggal selesai harus setelah tanggal mulai';

  @override
  String get start => 'Mulai';

  @override
  String get end => 'Selesai';

  @override
  String get title => 'Judul';

  @override
  String get description => 'Deskripsi';

  @override
  String get cannotSaveSchedule => 'Tidak Bisa Menyimpan Jadwal';

  @override
  String get phoneNumber => 'Nomor Telepon';

  @override
  String get address => 'Alamat';

  @override
  String get createdAt => 'Dibuat Pada';

  @override
  String get updatedAt => 'Diperbarui Pada';

  @override
  String get emptyData => 'Tidak ada data';

  @override
  String get loading => 'Memuat...';

  @override
  String get errorSomethingWentWrong => 'Terjadi kesalahan';

  @override
  String get messageDataSaved => 'Data berhasil disimpan';

  @override
  String get messageDataUpdated => 'Data berhasil diperbarui';

  @override
  String get messageDataDeleted => 'Data berhasil dihapus';

  @override
  String get messageConfirmDelete =>
      'Apakah Anda yakin ingin menghapus data ini?';

  @override
  String get dashboardSubtitle =>
      'Ringkasan pendidikan yayasan dan operasional.';

  @override
  String get dashboardRefresh => 'Muat ulang Beranda';

  @override
  String get dashboardLevel => 'Level';

  @override
  String get dashboardSelectLevels => 'Pilih Level';

  @override
  String get dashboardSelectLevelsDescription =>
      'Pilih satu atau beberapa level sekolah.';

  @override
  String get dashboardAllLevels => 'Semua Level';

  @override
  String get dashboardAllSd => 'Semua SD';

  @override
  String get dashboardAllSmp => 'Semua SMP';

  @override
  String get dashboardAllSma => 'Semua SMA';

  @override
  String get dashboardUniversity => 'Universitas';

  @override
  String get dashboardLevelLabel => 'Level';

  @override
  String get dashboardClear => 'Bersihkan';

  @override
  String get dashboardApply => 'Terapkan';

  @override
  String get dashboardActiveStudents => 'Siswa Aktif';

  @override
  String get dashboardWithGenderData => 'dengan data gender';

  @override
  String get dashboardAverageAttendance => 'Rata-rata Kehadiran';

  @override
  String get dashboardAttendanceRecords => 'data kehadiran';

  @override
  String get dashboardAverageAcademic => 'Rata-rata Akademik';

  @override
  String get dashboardActiveSubjects => 'mata pelajaran aktif';

  @override
  String get dashboardTeachingSessions => 'Sesi Mengajar';

  @override
  String get dashboardStudentsTitle => 'Siswa';

  @override
  String get dashboardStudentsDescription => 'Komposisi gender.';

  @override
  String get dashboardStudentsStatusDescription => 'Komposisi status bantuan.';

  @override
  String get dashboardBoys => 'Laki-laki';

  @override
  String get dashboardGirls => 'Perempuan';

  @override
  String get duafaStatus => 'Status Dhuafa';

  @override
  String get studentStatusDhuafa => 'Dhuafa';

  @override
  String get studentStatusYatim => 'Yatim';

  @override
  String get studentStatusPiatu => 'Piatu';

  @override
  String get studentStatusYatimPiatu => 'Yatim Piatu';

  @override
  String get dashboardAttendanceTitle => 'Kehadiran';

  @override
  String get dashboardRecords => 'Catatan';

  @override
  String get dashboardAcademicAverageScore => 'Rata-rata Nilai Akademik';

  @override
  String get dashboardSubjectScoreAverage => 'rata-rata nilai mata pelajaran.';

  @override
  String get dashboardNoSubjectsYet => 'Belum ada mata pelajaran.';

  @override
  String get dashboardPreviousSubjects => 'Mata pelajaran sebelumnya';

  @override
  String get dashboardNextSubjects => 'Mata pelajaran berikutnya';

  @override
  String get dashboardSwapSubjects => 'Geser mapel';

  @override
  String get dashboardStudentProgressTrend => 'Tren Perkembangan Siswa';

  @override
  String dashboardProgressSubtitle(
    Object attendance,
    Object academic,
    Object notes,
  ) {
    return 'Kehadiran $attendance% | Akademik $academic% | Catatan $notes%';
  }

  @override
  String get dashboardAcademic => 'Akademik';

  @override
  String get dashboardTeacherNotes => 'Catatan Guru';

  @override
  String get dashboardNoProgressData =>
      'Belum ada data progres untuk filter ini.';

  @override
  String get dashboardSessionProgress => 'Progress Sesi';

  @override
  String get dashboardNoTeachingSessionRange =>
      'Tidak ada sesi mengajar pada rentang ini.';

  @override
  String get dashboardSessions => 'sesi';

  @override
  String get dashboardStatusInProgress => 'Berjalan';

  @override
  String get dashboardUpcomingScheduleThisWeek => 'Jadwal Minggu Ini';

  @override
  String get dashboardUpcomingScheduleSubtitle =>
      'Jadwal mengajar untuk 7 hari ke depan';

  @override
  String get dashboardNoUpcomingSchedule =>
      'Tidak ada jadwal mengajar minggu ini.';

  @override
  String get dashboardTopLearners => 'Siswa Terbaik';

  @override
  String get dashboardTopLearnersSubtitle =>
      'Peringkat nilai akademik dan catatan guru';

  @override
  String get dashboardTopLearnersTooltip =>
      'Poin = 65% rata-rata akademik + 35% nilai catatan guru.\nNilai catatan dikonversi dari 0-5 bintang menjadi 0-100.';

  @override
  String get dashboardNoLearnerScore =>
      'Belum ada nilai akademik atau catatan guru.';

  @override
  String get dashboardPointsShort => 'poin';

  @override
  String get rangeWeekly => 'Mingguan';

  @override
  String get rangeMonthly => 'Bulanan';

  @override
  String get rangeThreeMonths => '3 Bulan';

  @override
  String get rangeSixMonths => '6 Bulan';

  @override
  String get rangeOneYear => '1 Tahun';

  @override
  String get teachingActivityTitle => 'Aktivitas Mengajar';

  @override
  String get teachingActivitySubtitle =>
      'Buka kelas terjadwal, catat kehadiran, catatan, dan hasil mengajar.';

  @override
  String get teachingActivityError => 'Error Aktivitas Mengajar';

  @override
  String get teachingActivityAccessDenied =>
      'Anda tidak memiliki izin untuk melihat aktivitas mengajar.';

  @override
  String get teachingReportAccessDenied =>
      'Anda tidak memiliki izin untuk melihat laporan mengajar.';

  @override
  String get teachingActivityNotFound => 'Aktivitas mengajar tidak ditemukan.';

  @override
  String get teachingReportNoAccess =>
      'Anda tidak memiliki akses ke laporan mengajar ini.';

  @override
  String get backToTeachingActivity => 'Kembali ke Aktivitas Mengajar';

  @override
  String get allTeachers => 'Semua guru';

  @override
  String get allLevels => 'Semua level';

  @override
  String get allStatus => 'Semua status';

  @override
  String get noTeachingSessionsFilter =>
      'Tidak ada sesi mengajar untuk filter ini.';

  @override
  String get unitMaterial => 'Unit / Materi';

  @override
  String get action => 'Aksi';

  @override
  String get selectedDate => 'Tanggal Dipilih';

  @override
  String get sessions => 'Sesi';

  @override
  String get session => 'Sesi';

  @override
  String get scheduled => 'Terjadwal';

  @override
  String get inProgress => 'Berjalan';

  @override
  String get previousMonth => 'Bulan sebelumnya';

  @override
  String get nextMonth => 'Bulan berikutnya';

  @override
  String get startClass => 'Mulai Kelas';

  @override
  String get complete => 'Selesai';

  @override
  String get viewDetail => 'Lihat Detail';

  @override
  String get cancelSession => 'Batalkan Sesi';

  @override
  String get reason => 'Alasan';

  @override
  String get notes => 'Catatan';

  @override
  String get note => 'Catatan';

  @override
  String get replacementNeeded => 'Perlu pengganti';

  @override
  String get markCancelled => 'Tandai Dibatalkan';

  @override
  String get teachingSessionCancelled => 'Sesi mengajar dibatalkan.';

  @override
  String get teachingSessionReport => 'Laporan Sesi Mengajar';

  @override
  String get teachingReportCompleted => 'Laporan mengajar selesai.';

  @override
  String get completeReport => 'Selesaikan Laporan';

  @override
  String get teachingReportReset => 'Laporan mengajar direset.';

  @override
  String get resetReport => 'Reset Laporan';

  @override
  String get sessionNotes => 'Catatan Sesi';

  @override
  String get sessionOverview => 'Ringkasan Sesi';

  @override
  String get sessionOverviewSubtitle =>
      'Detail sesi mengajar dan ringkasan penyelesaian.';

  @override
  String get sessionNote => 'Catatan Sesi';

  @override
  String get date => 'Tanggal';

  @override
  String get time => 'Waktu';

  @override
  String get teacher => 'Guru';

  @override
  String get strategy => 'Strategi';

  @override
  String get assessment => 'Penilaian';

  @override
  String get students => 'Siswa';

  @override
  String get assessments => 'Penilaian';

  @override
  String get studentNotes => 'Catatan Siswa';

  @override
  String get completion => 'Penyelesaian';

  @override
  String get editSessionNote => 'Ubah catatan sesi';

  @override
  String get studentsAttendance => 'Siswa & Kehadiran';

  @override
  String get studentsAttendanceSubtitle => 'Pilih siswa dan tandai kehadiran.';

  @override
  String get searchStudentHint => 'Cari nama atau nomor siswa';

  @override
  String get saveAttendance => 'Simpan kehadiran';

  @override
  String get allPresent => 'Semua Hadir';

  @override
  String get student => 'Siswa';

  @override
  String get attendance => 'Kehadiran';

  @override
  String get noteHistory => 'Riwayat Catatan';

  @override
  String get saveReporting => 'Simpan Pelaporan';

  @override
  String get reporting => 'Pelaporan';

  @override
  String get searchStudent => 'Cari siswa';

  @override
  String get studentSearchHint => 'Nama atau nomor siswa';

  @override
  String get shown => 'ditampilkan';

  @override
  String get noStudentsMatchSearch =>
      'Tidak ada siswa yang cocok dengan pencarian.';

  @override
  String get competencyScores => 'Nilai Kompetensi';

  @override
  String get quizNumericScoreSubtitle => 'Nilai kuis menggunakan angka 0-100.';

  @override
  String get starAssessmentSubtitle =>
      'Penilaian sesi menggunakan rating bintang.';

  @override
  String get selectAssessmentType => 'Pilih tipe penilaian';

  @override
  String get noCompetenciesRegistered => 'Belum ada kompetensi untuk unit ini.';

  @override
  String attendanceNoteRequiredForStudent(Object student) {
    return 'Catatan kehadiran wajib untuk $student.';
  }

  @override
  String get assessmentType => 'Tipe Penilaian';

  @override
  String get studentNotesSubtitle =>
      'Tambahkan catatan observasi sosial langsung berdasarkan tipe.';

  @override
  String get attendanceNote => 'Catatan Kehadiran';

  @override
  String get attendanceNoteRequired => 'Catatan kehadiran *';

  @override
  String get attendanceNoteRequiredSubtitle =>
      'Wajib karena kehadiran berstatus Izin.';

  @override
  String get attendanceNoteOptionalSubtitle =>
      'Catatan kehadiran opsional untuk siswa ini.';

  @override
  String get teacherNotesHistory => 'Riwayat Catatan Guru';

  @override
  String get confirmDelete => 'Konfirmasi Hapus';

  @override
  String get resetTeachingReport => 'Reset Laporan Mengajar?';

  @override
  String get resetTeachingReportMessage =>
      'Ini akan menghapus semua kehadiran, nilai kompetensi, catatan siswa, dan catatan sesi untuk laporan ini.';

  @override
  String get resetAll => 'Reset Semua';

  @override
  String get changeAssessmentType => 'Ubah Tipe Penilaian?';

  @override
  String get changeAssessmentTypeMessage =>
      'Sesi ini sudah memiliki baris penilaian. Mengubah tipe akan membuat tab Penilaian memakai mode nilai berbeda untuk input berikutnya.';

  @override
  String get changeType => 'Ubah Tipe';

  @override
  String get statusScheduled => 'Terjadwal';

  @override
  String get statusInProgress => 'Berjalan';

  @override
  String get teacherUnavailable => 'Guru tidak tersedia';

  @override
  String get studentGroupUnavailable => 'Kelompok siswa tidak tersedia';

  @override
  String get publicHoliday => 'Hari libur';

  @override
  String get roomUnavailable => 'Ruangan tidak tersedia';

  @override
  String get weatherOrEmergency => 'Cuaca atau keadaan darurat';

  @override
  String get scheduleMistake => 'Kesalahan jadwal';

  @override
  String get administrativeReason => 'Alasan administrasi';

  @override
  String get other => 'Lainnya';

  @override
  String get assessmentObservation => 'Observasi';

  @override
  String get assessmentExercise => 'Latihan';

  @override
  String get assessmentQuiz => 'Kuis';

  @override
  String get assessmentOral => 'Lisan';

  @override
  String get assessmentPractical => 'Praktik';

  @override
  String get assessmentAssignment => 'Tugas';

  @override
  String get assessmentParticipation => 'Partisipasi';

  @override
  String get assessmentMemorization => 'Hafalan';

  @override
  String get assessmentReading => 'Membaca';

  @override
  String get noteLearningProgress => 'Perkembangan Belajar';

  @override
  String get noteBehavior => 'Perilaku';

  @override
  String get noteAttendanceConcern => 'Perhatian Kehadiran';

  @override
  String get noteNeedsSupport => 'Butuh Dukungan';

  @override
  String get noteAchievement => 'Pencapaian';

  @override
  String get noteParentFollowUp => 'Tindak Lanjut Orang Tua';

  @override
  String get studentDetail => 'Detail Siswa';

  @override
  String get studentAccessDenied =>
      'Anda tidak memiliki izin untuk melihat siswa.';

  @override
  String get studentCreateDenied =>
      'Anda tidak memiliki izin untuk membuat siswa.';

  @override
  String get studentUpdateDenied =>
      'Anda tidak memiliki izin untuk mengubah siswa.';

  @override
  String get studentDeleteDenied =>
      'Anda tidak memiliki izin untuk menghapus siswa.';

  @override
  String get teacherAccessDenied =>
      'Anda tidak memiliki izin untuk melihat guru.';

  @override
  String get teacherCreateDenied =>
      'Anda tidak memiliki izin untuk membuat guru.';

  @override
  String get teacherUpdateDenied =>
      'Anda tidak memiliki izin untuk mengubah guru.';

  @override
  String get teacherDeleteDenied =>
      'Anda tidak memiliki izin untuk menghapus guru.';

  @override
  String get addStudent => 'Tambah Siswa';

  @override
  String get addFullStudent => 'Tambah Siswa Lengkap';

  @override
  String get quickRegisterStudent => 'Daftar Cepat';

  @override
  String get chooseStudentCreationMode => 'Pilih cara menambahkan siswa.';

  @override
  String get quickRegisterStudentDescription =>
      'Gunakan informasi minimum agar siswa bisa langsung masuk target mengajar.';

  @override
  String get fullStudentDescription =>
      'Gunakan form siswa lengkap dengan keluarga, sekolah, dan dokumen pendukung.';

  @override
  String get addTeacher => 'Tambah Guru';

  @override
  String get editTeacher => 'Ubah Guru';

  @override
  String get deleteTeacher => 'Hapus Guru';

  @override
  String deleteTeacherConfirm(Object name) {
    return 'Hapus $name?';
  }

  @override
  String get searchTeacherName => 'Cari nama guru';

  @override
  String get noTeachersYet => 'Belum ada guru. Tambahkan guru.';

  @override
  String get noTeachersMatch => 'Tidak ada guru yang cocok dengan pencarian.';

  @override
  String get education => 'Pendidikan';

  @override
  String get educationLevel => 'Tingkat Pendidikan';

  @override
  String get appUser => 'User Aplikasi';

  @override
  String get linked => 'Terhubung';

  @override
  String get noUser => 'Belum ada user';

  @override
  String get createAppUser => 'Buat user aplikasi';

  @override
  String get teacherAlreadyHasAppUser => 'Guru sudah memiliki user aplikasi';

  @override
  String get editTeacherTooltip => 'Ubah guru';

  @override
  String get deleteTeacherTooltip => 'Hapus guru';

  @override
  String get teacherNotFound => 'Guru tidak ditemukan';

  @override
  String get teacherProfile => 'Profil Guru';

  @override
  String get noSubjectsAssigned => 'Belum ada mata pelajaran';

  @override
  String get teachingLoad => 'Beban Mengajar';

  @override
  String get teachingHours => 'Jam Mengajar';

  @override
  String get summaryInsight => 'Ringkasan Insight';

  @override
  String get alerts => 'Peringatan';

  @override
  String get detail => 'Detail';

  @override
  String get level => 'Level';

  @override
  String get noManagementAlerts =>
      'Tidak ada peringatan manajemen untuk guru ini.';

  @override
  String get impact => 'Dampak';

  @override
  String get classes => 'Kelas';

  @override
  String get studentImpactSnapshot => 'Snapshot Dampak Siswa';

  @override
  String get improved => 'Meningkat';

  @override
  String get stable => 'Stabil';

  @override
  String get declined => 'Menurun';

  @override
  String get up => 'naik';

  @override
  String get same => 'tetap';

  @override
  String get down => 'turun';

  @override
  String get needCare => 'Perlu Perhatian';

  @override
  String get studentsUnderCare => 'Siswa Dalam Perhatian';

  @override
  String get scoreTrend => 'Tren Nilai';

  @override
  String get followUp => 'Tindak Lanjut';

  @override
  String get noStudentImpactRows =>
      'Data dampak siswa akan tampil setelah nilai asesmen mengajar dicatat.';

  @override
  String get assignedClassesStudents => 'Kelas & Siswa Terhubung';

  @override
  String get assignedClassesEmpty =>
      'Kelas terhubung akan tampil setelah jadwal dikaitkan ke guru ini.';

  @override
  String get notesActivity => 'Aktivitas Catatan';

  @override
  String get totalNotes => 'Total Catatan';

  @override
  String get recentTeacherNotes => 'Catatan Guru Terbaru';

  @override
  String get noStudentSessionNotes =>
      'Belum ada catatan sesi siswa yang dicatat oleh guru ini.';

  @override
  String get editStudent => 'Ubah Siswa';

  @override
  String get deleteStudent => 'Hapus Siswa';

  @override
  String deleteStudentConfirm(Object name) {
    return 'Hapus $name?';
  }

  @override
  String get filterStudents => 'Filter Siswa';

  @override
  String get total => 'Total';

  @override
  String get studentProfile => 'Profil Siswa';

  @override
  String get profileStatus => 'Status Profil';

  @override
  String get profileComplete => 'Lengkap';

  @override
  String get profileIncomplete => 'Belum Lengkap';

  @override
  String get classSchool => 'Kelas\nSekolah';

  @override
  String get ageGender => 'Usia\nGender';

  @override
  String get scoreStatus => 'Nilai\nStatus';

  @override
  String get joinDate => 'Tanggal Bergabung';

  @override
  String get actions => 'Aksi';

  @override
  String get editStudentTooltip => 'Ubah siswa';

  @override
  String get deleteStudentTooltip => 'Hapus siswa';

  @override
  String get overview => 'Ringkasan';

  @override
  String get personal => 'Personal';

  @override
  String get personalProfile => 'Profil Personal';

  @override
  String get fullName => 'Nama Lengkap';

  @override
  String get nickName => 'Nama Panggilan';

  @override
  String get nis => 'NIS';

  @override
  String get birthDate => 'Tanggal Lahir';

  @override
  String get gender => 'Gender';

  @override
  String get mobileNo => 'No Ponsel';

  @override
  String get basicInfo => 'Info Dasar';

  @override
  String get contact => 'Kontak';

  @override
  String get physical => 'Fisik';

  @override
  String get photo => 'Foto';

  @override
  String get photos => 'Foto';

  @override
  String get registrationForm => 'Formulir Pendaftaran';

  @override
  String get studentPhoto => 'Foto Siswa';

  @override
  String get noPhotoSelected => 'Belum ada foto dipilih';

  @override
  String get dropPhotoHere => 'Lepaskan foto di sini';

  @override
  String get noFileSelected => 'Belum ada file dipilih';

  @override
  String get uploadRegistrationFormHelp =>
      'Unggah formulir pendaftaran kertas yang sudah ditandatangani (PDF/JPG/PNG)';

  @override
  String get upload => 'Unggah';

  @override
  String get removeFile => 'Hapus file';

  @override
  String get generatedNo => 'Student No. Dibuat otomatis';

  @override
  String get selectSchool => 'Pilih sekolah';

  @override
  String get selectSchoolFirst => 'Pilih sekolah terlebih dahulu';

  @override
  String get selectClass => 'Pilih kelas';

  @override
  String get createStudent => 'Buat Siswa';

  @override
  String get updateStudent => 'Ubah Siswa';

  @override
  String get advancedDetail => 'Detail Lanjutan';

  @override
  String get hideAdvancedDetail => 'Sembunyikan Detail Lanjutan';

  @override
  String get studentNumberNotReady => 'Nomor siswa belum siap.';

  @override
  String get unsupportedPhotoFileType => 'File foto harus JPG, PNG, atau WEBP.';

  @override
  String get photoSizeLimit => 'Foto harus 20 MB atau lebih kecil.';

  @override
  String get dropRegistrationFormHere =>
      'Lepaskan formulir pendaftaran di sini';

  @override
  String get unsupportedRegistrationFormFileType =>
      'Formulir pendaftaran harus PDF, JPG, atau PNG.';

  @override
  String get registrationFormSizeLimit =>
      'Formulir pendaftaran harus 20 MB atau lebih kecil.';

  @override
  String get registrationFormRequired => 'Formulir pendaftaran wajib diunggah.';

  @override
  String get shoeSize => 'Ukuran Sepatu';

  @override
  String get uniformSize => 'Ukuran Seragam';

  @override
  String get pantsSize => 'Ukuran Celana';

  @override
  String get hobby => 'Hobi';

  @override
  String get aspiration => 'Cita-cita';

  @override
  String get citaCita => 'Cita-cita';

  @override
  String get family => 'Keluarga';

  @override
  String get siblingRelation => 'Relasi Saudara';

  @override
  String get siblingRelationHelp =>
      'Masukkan nomor siswa saudara yang sudah terdaftar jika kedua siswa berasal dari keluarga yang sama.';

  @override
  String get addSiblingRelation => 'Tambah Relasi Saudara';

  @override
  String get guardianParents => 'Wali / Orang Tua';

  @override
  String get addParentGuardian => 'Tambah orang tua / wali';

  @override
  String get addGuardian => 'Tambah Wali';

  @override
  String get editGuardian => 'Ubah Wali';

  @override
  String get primaryGuardian => 'Wali Utama';

  @override
  String get notPrimary => 'Bukan Utama';

  @override
  String get parentGuardianName => 'Nama Orang Tua / Wali';

  @override
  String get extracurricularActivity => 'Ekstrakurikuler / Aktivitas';

  @override
  String get addActivity => 'Tambah aktivitas';

  @override
  String get editActivity => 'Ubah Aktivitas';

  @override
  String get activityName => 'Nama Aktivitas';

  @override
  String get studentIdNo => 'ID / No Siswa';

  @override
  String get searchSibling => 'Cari saudara';

  @override
  String get hobbyAspiration => 'Hobi & Cita-cita';

  @override
  String get academic => 'Akademik';

  @override
  String get examScores => 'Nilai Ujian';

  @override
  String get addScoreExam => 'Tambah Nilai Ujian';

  @override
  String get editScoreExam => 'Ubah Nilai Ujian';

  @override
  String get examScoresDescription =>
      'Nilai sekolah dikelompokkan berdasarkan laporan/ujian dan dapat berisi beberapa mata pelajaran. Nilai internal dapat berisi beberapa unit.';

  @override
  String get loadingExamScores => 'Memuat nilai ujian...';

  @override
  String get noExamScores => 'Belum ada nilai ujian internal atau sekolah.';

  @override
  String get removeExamScoreTitle => 'Hapus Nilai Ujian?';

  @override
  String removeExamScoreMessage(Object type) {
    return 'Ini akan menghapus data nilai $type dari siswa ini.';
  }

  @override
  String get scoreAvg => 'Nilai\nRata-rata';

  @override
  String get scoreAvgTooltip =>
      'Rata-rata dihitung dari nilai tiap item dibagi nilai maksimal, lalu dirata-ratakan untuk ujian ini.';

  @override
  String get internal => 'Internal';

  @override
  String get examType => 'Tipe Ujian';

  @override
  String get internalType => 'Tipe Internal';

  @override
  String get source => 'Sumber';

  @override
  String get scope => 'Lingkup';

  @override
  String get academicYear => 'Tahun Akademik';

  @override
  String get semester => 'Semester';

  @override
  String get subjectScores => 'Nilai Mata Pelajaran';

  @override
  String get unitScores => 'Nilai Unit';

  @override
  String get addSubject => 'Tambah Mata Pelajaran';

  @override
  String get addUnit => 'Tambah Unit';

  @override
  String get noSubjectScore =>
      'Belum ada nilai mata pelajaran. Klik Tambah Mata Pelajaran untuk menginput nilai laporan.';

  @override
  String get noUnitScore =>
      'Belum ada nilai unit. Klik Tambah Unit untuk menginput nilai internal.';

  @override
  String get maxScore => 'Nilai Maksimal';

  @override
  String get score => 'Nilai';

  @override
  String get removeRow => 'Hapus baris';

  @override
  String get removeScoreRecord => 'Hapus data nilai';

  @override
  String get behavior => 'Perilaku';

  @override
  String get activities => 'Aktivitas';

  @override
  String get more => 'Lainnya';

  @override
  String get quickProfile => 'Profil Singkat';

  @override
  String get aggregatedSnapshot => 'Ringkasan Agregat';

  @override
  String get loadingStudentSnapshot => 'Memuat ringkasan siswa...';

  @override
  String get noStudentSnapshot => 'Ringkasan siswa belum tersedia.';

  @override
  String get attendanceRecords => 'Catatan Kehadiran';

  @override
  String attendanceChartTitle(Object year) {
    return 'Kehadiran $year';
  }

  @override
  String get monthlyAttendanceRate => 'Rasio kehadiran bulanan';

  @override
  String get attendanceChartEmpty =>
      'Kehadiran akan tampil setelah absensi mengajar disimpan.';

  @override
  String get averageScore => 'Rata-rata Nilai';

  @override
  String get assistance => 'Bantuan';

  @override
  String get needsAttention => 'Perlu Perhatian';

  @override
  String get noAttentionNeeded => 'Belum ada sinyal perhatian untuk siswa ini.';

  @override
  String get attendanceBelowThreshold => 'Kehadiran di bawah 75%';

  @override
  String absenceRecords(Object count) {
    return '$count catatan absen';
  }

  @override
  String permissionRecords(Object count) {
    return '$count catatan izin';
  }

  @override
  String recentTeacherNotesCount(Object count) {
    return '$count catatan guru terbaru';
  }

  @override
  String get signal => 'Sinyal';

  @override
  String get physicalAttributes => 'Atribut Fisik';

  @override
  String get height => 'Tinggi (cm)';

  @override
  String get weight => 'Berat (kg)';

  @override
  String get uniform => 'Seragam';

  @override
  String get pants => 'Celana';

  @override
  String get shoes => 'Sepatu';

  @override
  String get studentRelations => 'Relasi Siswa';

  @override
  String get loadingStudentRelations => 'Memuat relasi siswa...';

  @override
  String get parentsGuardians => 'Orang Tua / Wali';

  @override
  String get loadingGuardianInformation => 'Memuat informasi wali...';

  @override
  String get learningSummary => 'Ringkasan Belajar';

  @override
  String get loadingLearningSummary => 'Memuat ringkasan belajar...';

  @override
  String get noLearningSummary => 'Ringkasan belajar belum tersedia.';

  @override
  String get latest => 'Terbaru';

  @override
  String get competencyAverage => 'Rata-rata Kompetensi';

  @override
  String get loadingCompetencyRecords => 'Memuat data kompetensi...';

  @override
  String get teachingAttendance => 'Kehadiran Mengajar';

  @override
  String get loadingAttendanceRecords => 'Memuat catatan kehadiran...';

  @override
  String get teacherNotes => 'Catatan Guru';

  @override
  String get loadingTeacherNotes => 'Memuat catatan guru...';

  @override
  String get noteTypeDistribution => 'Distribusi Tipe Catatan';

  @override
  String get loadingNoteDistribution => 'Memuat distribusi catatan...';

  @override
  String get extracurricular => 'Ekstrakurikuler';

  @override
  String get loadingActivities => 'Memuat aktivitas...';

  @override
  String get extraActivityRecords => 'Data Aktivitas Tambahan';

  @override
  String get assistanceHistory => 'Riwayat Bantuan';

  @override
  String get loadingAssistanceHistory => 'Memuat riwayat bantuan...';

  @override
  String get goals => 'Tujuan';

  @override
  String get loadingGoals => 'Memuat tujuan...';

  @override
  String get rating => 'Rating';

  @override
  String get comment => 'Komentar';

  @override
  String get count => 'Jumlah';

  @override
  String get type => 'Tipe';

  @override
  String get activity => 'Aktivitas';

  @override
  String get role => 'Peran';

  @override
  String get achievement => 'Pencapaian';

  @override
  String get startDate => 'Tanggal Mulai';

  @override
  String get endDate => 'Tanggal Selesai';

  @override
  String get program => 'Program';

  @override
  String get period => 'Periode';

  @override
  String get rule => 'Aturan';

  @override
  String get benefit => 'Manfaat';

  @override
  String get approvedAt => 'Disetujui Pada';

  @override
  String get category => 'Kategori';

  @override
  String get goal => 'Tujuan';

  @override
  String get relationship => 'Hubungan';

  @override
  String get relation => 'Relasi';

  @override
  String get agePosition => 'Posisi Usia';

  @override
  String get primary => 'Utama';

  @override
  String get mobile => 'Ponsel';

  @override
  String get email => 'Email';

  @override
  String get occupation => 'Pekerjaan';

  @override
  String get noTeacherNotes => 'Belum ada catatan guru dari sesi mengajar.';

  @override
  String get noTeacherNoteDistribution =>
      'Distribusi catatan guru belum tersedia.';

  @override
  String get noExtracurricularActivity =>
      'Belum ada aktivitas ekstrakurikuler.';

  @override
  String get noExtraActivity => 'Belum ada aktivitas tambahan.';

  @override
  String get noAssistanceHistory => 'Riwayat penerima bantuan belum tersedia.';

  @override
  String get noGoals => 'Belum ada hobi atau cita-cita.';

  @override
  String get healthInformation => 'Informasi Kesehatan';

  @override
  String get loadingHealthInformation => 'Memuat informasi kesehatan...';

  @override
  String get noHealthInformation => 'Belum ada informasi kesehatan.';

  @override
  String get householdProfile => 'Profil Keluarga';

  @override
  String get loadingHouseholdProfile => 'Memuat profil keluarga...';

  @override
  String get noHouseholdProfile => 'Belum ada profil keluarga.';

  @override
  String get noStudentRelations =>
      'Belum ada relasi saudara atau relasi siswa.';

  @override
  String get noGuardianInformation =>
      'Belum ada informasi orang tua atau wali.';

  @override
  String get noCompetencyScores =>
      'Belum ada nilai kompetensi dari sesi mengajar.';

  @override
  String get noTeachingAttendance =>
      'Belum ada kehadiran mengajar untuk siswa ini.';

  @override
  String get name => 'Nama';

  @override
  String get studentNo => 'No Siswa';

  @override
  String get age => 'Usia';

  @override
  String get years => 'tahun';

  @override
  String get assistanceProgramsTitle => 'Program Bantuan';

  @override
  String get assistanceProgramsSubtitle =>
      'Kelola program bantuan, jenis manfaat, dan nilai bantuan bawaan.';

  @override
  String get addProgram => 'Tambah Program';

  @override
  String get editProgram => 'Ubah Program';

  @override
  String get searchCodeNameDescription => 'Cari kode, nama, deskripsi';

  @override
  String get clearSearch => 'Bersihkan pencarian';

  @override
  String get noAssistancePrograms => 'Program bantuan tidak ditemukan';

  @override
  String get defaultBenefit => 'Manfaat Bawaan';

  @override
  String get editProgramTooltip => 'Ubah program';

  @override
  String get activate => 'Aktifkan';

  @override
  String get deactivate => 'Nonaktifkan';

  @override
  String get noPermissionViewAssistancePrograms =>
      'Anda tidak memiliki akses untuk melihat program bantuan.';

  @override
  String get noPermissionCreateAssistancePrograms =>
      'Anda tidak memiliki akses untuk membuat program bantuan.';

  @override
  String get noPermissionUpdateAssistancePrograms =>
      'Anda tidak memiliki akses untuk mengubah program bantuan.';

  @override
  String get assistanceProgramActivated => 'Program bantuan diaktifkan.';

  @override
  String get assistanceProgramDeactivated => 'Program bantuan dinonaktifkan.';

  @override
  String get failedUpdateAssistanceProgramStatus =>
      'Gagal mengubah status program bantuan.';

  @override
  String get codeRequired => 'Kode wajib diisi';

  @override
  String get codeFormatUppercase =>
      'Gunakan huruf besar, angka, atau garis bawah';

  @override
  String get nameRequired => 'Nama wajib diisi';

  @override
  String get benefitType => 'Jenis Manfaat';

  @override
  String get frequency => 'Frekuensi';

  @override
  String get defaultAmountRp => 'Nominal Bawaan (Rp)';

  @override
  String get amountMustBeNumber => 'Nominal harus berupa angka';

  @override
  String get amountCannotBeNegative => 'Nominal tidak boleh negatif';

  @override
  String get defaultItemDescription => 'Deskripsi Barang Bawaan';

  @override
  String get benefitPackages => 'Paket Manfaat';

  @override
  String get addPackage => 'Tambah Paket';

  @override
  String get usePackagesBySchoolType =>
      'Gunakan paket jika nominal atau barang berbeda berdasarkan tipe sekolah.';

  @override
  String get noPackageYet =>
      'Belum ada paket. Jika kosong, nominal/barang bawaan program akan digunakan.';

  @override
  String get editPackage => 'Ubah paket';

  @override
  String get removePackage => 'Hapus paket';

  @override
  String get addBenefitPackage => 'Tambah Paket Manfaat';

  @override
  String get editBenefitPackage => 'Ubah Paket Manfaat';

  @override
  String get schoolType => 'Tipe Sekolah';

  @override
  String get amountRp => 'Nominal (Rp)';

  @override
  String get enterAmountRupiah => 'Masukkan nominal dalam Rupiah';

  @override
  String get amountRequired => 'Nominal wajib diisi';

  @override
  String get optionalPackageNotes => 'Catatan paket opsional';

  @override
  String get goodsItems => 'Barang / Item';

  @override
  String get addItem => 'Tambah Item';

  @override
  String get itemsForGoodsMixed =>
      'Item digunakan untuk paket barang atau manfaat campuran.';

  @override
  String get noItemsYet => 'Belum ada item.';

  @override
  String get editItem => 'Ubah item';

  @override
  String get removeItem => 'Hapus item';

  @override
  String get savePackage => 'Simpan Paket';

  @override
  String get goodsPackageNeedsItem =>
      'Paket barang membutuhkan minimal satu item.';

  @override
  String get mixedPackageNeedsAmountOrItem =>
      'Paket campuran membutuhkan nominal atau item.';

  @override
  String get itemName => 'Nama Item';

  @override
  String get itemNameRequired => 'Nama item wajib diisi';

  @override
  String get quantity => 'Jumlah';

  @override
  String get quantityGreaterThanZero => 'Jumlah harus lebih dari nol';

  @override
  String get unitHint => 'pcs, paket, set';

  @override
  String get estimatedValueRp => 'Estimasi Nilai (Rp)';

  @override
  String get estimatedValueValid => 'Estimasi nilai harus valid';

  @override
  String get saveItem => 'Simpan Item';

  @override
  String get categoryEducation => 'Pendidikan';

  @override
  String get categorySeasonal => 'Musiman';

  @override
  String get categoryUniform => 'Seragam';

  @override
  String get categoryTransport => 'Transportasi';

  @override
  String get categoryFood => 'Makanan';

  @override
  String get categoryEmergency => 'Darurat';

  @override
  String get categoryHealth => 'Kesehatan';

  @override
  String get categoryOther => 'Lainnya';

  @override
  String get benefitCash => 'Tunai';

  @override
  String get benefitGoods => 'Barang';

  @override
  String get benefitVoucher => 'Voucher';

  @override
  String get benefitService => 'Layanan';

  @override
  String get benefitMixed => 'Campuran';

  @override
  String get frequencyMonthly => 'Bulanan';

  @override
  String get frequencyYearly => 'Tahunan';

  @override
  String get frequencySeasonal => 'Musiman';

  @override
  String get frequencyOneTime => 'Satu Kali';

  @override
  String get frequencyAsNeeded => 'Sesuai Kebutuhan';

  @override
  String get schoolTypeAll => 'Semua';

  @override
  String get schoolTypeUniversity => 'Universitas';

  @override
  String get draft => 'Draft';

  @override
  String get targeted => 'Ditargetkan';

  @override
  String get submitted => 'Diajukan';

  @override
  String get approved => 'Disetujui';

  @override
  String get rejected => 'Ditolak';

  @override
  String get distributed => 'Didistribusikan';

  @override
  String get cancelled => 'Dibatalkan';

  @override
  String get assistancePeriodsTitle => 'Periode Bantuan';

  @override
  String get assistancePeriodsSubtitle =>
      'Kelola periode bantuan, kandidat target, persetujuan, dan penerima.';

  @override
  String get create => 'Buat';

  @override
  String get thisMonth => 'Bulan Ini';

  @override
  String activeCount(Object count) {
    return '$count Aktif';
  }

  @override
  String get searchPeriodProgramMonth => 'Cari periode, program, bulan';

  @override
  String get year => 'Tahun';

  @override
  String get noAssistancePeriods => 'Periode bantuan tidak ditemukan';

  @override
  String get periodName => 'Nama Periode';

  @override
  String get target => 'Target';

  @override
  String get selected => 'Terpilih';

  @override
  String get approvedFinalizedPeriodCannotDelete =>
      'Periode yang sudah disetujui atau selesai tidak bisa dihapus';

  @override
  String get deletePeriod => 'Hapus periode';

  @override
  String get noPermissionDeletePeriods =>
      'Anda tidak memiliki akses untuk menghapus periode.';

  @override
  String get deleteAssistancePeriodTitle => 'Hapus Periode Bantuan?';

  @override
  String deleteAssistancePeriodMessage(Object period) {
    return 'Ini akan menghapus \"$period\" beserta aturan, kandidat target, dan data penerimanya. Aksi ini tidak bisa dibatalkan.';
  }

  @override
  String get deletePeriodButton => 'Hapus Periode';

  @override
  String get assistancePeriodDeleted => 'Periode bantuan dihapus.';

  @override
  String get setup => 'Setup';

  @override
  String get open => 'Buka';

  @override
  String get review => 'Review';

  @override
  String get view => 'Lihat';

  @override
  String get finalize => 'Finalisasi';

  @override
  String get report => 'Laporan';

  @override
  String get targetCandidates => 'Kandidat Target';

  @override
  String get reviewApproval => 'Review & Persetujuan';

  @override
  String get approvalDocument => 'Dokumen Persetujuan';

  @override
  String get recipients => 'Penerima';

  @override
  String get remaining => 'Sisa';

  @override
  String get minimumAttendance => 'Minimum Kehadiran';

  @override
  String get calculation => 'Perhitungan';

  @override
  String get calculationRange => 'Rentang Perhitungan';

  @override
  String get periodInfo => 'Info Periode';

  @override
  String get targetQuota => 'Kuota Target';

  @override
  String get calculationWindow => 'Jendela Perhitungan';

  @override
  String get manualOverride => 'Override Manual';

  @override
  String get rulesUsed => 'Aturan Digunakan';

  @override
  String get quota => 'Kuota';

  @override
  String get mode => 'Mode';

  @override
  String get createAssistancePeriod => 'Buat Periode Bantuan';

  @override
  String get createPeriod => 'Buat Periode';

  @override
  String get creating => 'Membuat...';

  @override
  String get periodInfoStep => 'Info Periode';

  @override
  String get rulesQuota => 'Aturan & Kuota';

  @override
  String get reviewSetup => 'Review Setup';

  @override
  String get allowManualOverrideBelowAttendance =>
      'Izinkan Override Manual di Bawah Kehadiran Minimum';

  @override
  String get periodNameRequired => 'Nama periode wajib diisi';

  @override
  String get addRule => 'Tambah Aturan';

  @override
  String get allocation => 'Alokasi';

  @override
  String get dateRange => 'Rentang Tanggal';

  @override
  String get allowed => 'Diizinkan';

  @override
  String get notAllowed => 'Tidak diizinkan';

  @override
  String monthsCount(Object count) {
    return '$count bulan';
  }

  @override
  String get manual => 'Manual';

  @override
  String get auto => 'Otomatis';

  @override
  String get overAllocated => 'Melebihi alokasi';

  @override
  String get autoTarget => 'Target Otomatis';

  @override
  String get saveTargetPlan => 'Simpan Rencana Target';

  @override
  String get targetPlanSaved => 'Rencana target disimpan.';

  @override
  String get autoTargetsGenerated =>
      'Target otomatis dibuat. Klik Simpan Rencana Target untuk menyimpan.';

  @override
  String get autoTargetFailed => 'Target Otomatis Gagal';

  @override
  String get selectStudents => 'Pilih Siswa';

  @override
  String get removeAll => 'Hapus Semua';

  @override
  String get parameterSubtitle =>
      'Parameter akademik, pengajaran, bantuan, dan sistem.';

  @override
  String get noPermissionViewParameters =>
      'Anda tidak memiliki akses untuk melihat parameter.';

  @override
  String get academicParameters => 'Akademik';

  @override
  String get teachingParameters => 'Pengajaran';

  @override
  String get systemParameters => 'Sistem';

  @override
  String get schools => 'Sekolah';

  @override
  String get curriculum => 'Kurikulum';

  @override
  String get syllabus => 'Silabus';

  @override
  String get units => 'Unit';

  @override
  String get competencies => 'Kompetensi';

  @override
  String get strategies => 'Strategi';

  @override
  String get programs => 'Program';

  @override
  String get rules => 'Aturan';

  @override
  String get reports => 'Laporan';

  @override
  String get config => 'Konfigurasi';

  @override
  String get systemConfig => 'Konfigurasi Sistem';

  @override
  String get configDescription =>
      'Kelola pengaturan parameter sistem yang digunakan di seluruh aplikasi.';

  @override
  String get reportDefinitionsDescription =>
      'Kelola definisi laporan dinamis yang digunakan oleh menu Laporan.';

  @override
  String get parameterDefaultDescription =>
      'Kelola data parameter yang digunakan modul Edukita.';

  @override
  String get save => 'Simpan';

  @override
  String get saving => 'Menyimpan';

  @override
  String get noPermissionUpdateParameters =>
      'Anda tidak memiliki akses untuk mengubah parameter.';

  @override
  String get systemConfigSaved => 'Konfigurasi sistem disimpan.';

  @override
  String get examTypeNamesUnique => 'Nama tipe ujian harus unik.';

  @override
  String get numbering => 'Penomoran';

  @override
  String get numberingDescription =>
      'Prefix bawaan untuk kode yang dibuat otomatis. Data yang sudah ada tidak berubah.';

  @override
  String get studentPrefix => 'Prefix Siswa';

  @override
  String get teacherPrefix => 'Prefix Guru';

  @override
  String get reportPrefix => 'Prefix Laporan';

  @override
  String get attendanceStatuses => 'Status Kehadiran';

  @override
  String get attendanceStatusesDescription =>
      'Status kehadiran operasional untuk laporan mengajar dan ringkasan dashboard.';

  @override
  String get approvalExportLabels => 'Label Persetujuan & Export';

  @override
  String get approvalExportLabelsDescription =>
      'Label yang digunakan pada dokumen persetujuan bantuan dan area tanda tangan laporan.';

  @override
  String get assistanceApproval => 'Persetujuan Bantuan';

  @override
  String get reportSignatures => 'Tanda Tangan Laporan';

  @override
  String get preparedLabel => 'Label Disiapkan';

  @override
  String get reviewedLabel => 'Label Direview';

  @override
  String get approvedLabel => 'Label Disetujui';

  @override
  String get dateLabel => 'Label Tanggal';

  @override
  String get examTypes => 'Tipe Ujian';

  @override
  String get examTypesDescription =>
      'Tipe nilai sekolah eksternal. Bukti dapat diwajibkan untuk ujian formal penting.';

  @override
  String get evidence => 'Bukti';

  @override
  String get evidenceRequiredTooltip =>
      'Wajibkan upload bukti saat menambahkan tipe nilai ini';

  @override
  String get examTypeActiveTooltip =>
      'Tampilkan tipe ujian ini pada pilihan input nilai';

  @override
  String get reportsChooseDefinition =>
      'Pilih definisi laporan untuk melihat preview dan export data.';

  @override
  String get noPermissionViewReports =>
      'Anda tidak memiliki akses untuk melihat laporan.';

  @override
  String reportRowsLoaded(Object name, Object count) {
    return '$name | $count baris dimuat';
  }

  @override
  String get refreshReports => 'Refresh laporan';

  @override
  String get run => 'Jalankan';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get availableReports => 'Laporan Tersedia';

  @override
  String get searchCodeOrName => 'Cari kode atau nama';

  @override
  String get noActiveReportSettings =>
      'Belum ada setting laporan aktif. Tambahkan laporan dari Parameter > Sistem > Laporan.';

  @override
  String get noReportsMatchSearch =>
      'Tidak ada laporan yang cocok dengan pencarian.';

  @override
  String get selectReport => 'Pilih Laporan';

  @override
  String get selectReportMessage =>
      'Pilih laporan dari panel kiri untuk melihat preview data.';

  @override
  String get searchLoadedRows => 'Cari baris yang dimuat';

  @override
  String get noDataLoaded => 'Data Belum Dimuat';

  @override
  String get clickRunReportPreview =>
      'Klik Jalankan untuk menjalankan laporan ini dan menampilkan preview.';

  @override
  String get noRowsMatchSearch => 'Tidak ada baris yang cocok dengan pencarian';

  @override
  String get failedRunReport => 'Gagal menjalankan laporan';

  @override
  String get noPermissionExportReports =>
      'Anda tidak memiliki akses untuk export laporan.';

  @override
  String get reportExported => 'Laporan diexport.';

  @override
  String get failedExportReport => 'Gagal export laporan';

  @override
  String get reportSettings => 'Setting Laporan';

  @override
  String get reportSettingsSubtitle =>
      'Kelola definisi laporan dinamis, nama file, query SQL, dan pengaturan tampilan kolom.';

  @override
  String get addReport => 'Tambah Laporan';

  @override
  String get searchReportNameCodeDescription =>
      'Cari nama laporan, kode, deskripsi';

  @override
  String get noReportSettings => 'Setting laporan tidak ditemukan';

  @override
  String get codeReportName => 'Kode\nNama Laporan';

  @override
  String get fileName => 'Nama File';

  @override
  String get columns => 'Kolom';

  @override
  String columnsCount(Object count) {
    return '$count kolom';
  }

  @override
  String columnsMissingCount(Object count, Object missing) {
    return '$count kolom, $missing hilang';
  }

  @override
  String get editReport => 'Ubah laporan';

  @override
  String get deleteReportSetting => 'Hapus setting laporan';

  @override
  String get noPermissionUpdateReportSettings =>
      'Anda tidak memiliki akses untuk mengubah setting laporan.';

  @override
  String get noPermissionDeleteReportSettings =>
      'Anda tidak memiliki akses untuk menghapus setting laporan.';

  @override
  String get reportSettingActivated => 'Setting laporan diaktifkan.';

  @override
  String get reportSettingDeactivated => 'Setting laporan dinonaktifkan.';

  @override
  String get failedUpdateReport => 'Gagal mengubah laporan';

  @override
  String get deleteReportSettingTitle => 'Hapus Setting Laporan';

  @override
  String deleteReportSettingMessage(Object name) {
    return 'Hapus $name? Ini akan menghapus laporan dari Parameter dan menu Laporan.';
  }

  @override
  String get failedDeleteReport => 'Gagal menghapus laporan';

  @override
  String get addReportSetting => 'Tambah Setting Laporan';

  @override
  String get editReportSetting => 'Ubah Setting Laporan';

  @override
  String get reportNameRequired => 'Nama laporan wajib diisi';

  @override
  String get reportFileNameRequired => 'Nama file laporan wajib diisi';

  @override
  String get reportName => 'Nama Laporan';

  @override
  String get reportFileName => 'Nama File Laporan';

  @override
  String get reportCode => 'Kode Laporan';

  @override
  String get autoGenerated => 'Dibuat otomatis';

  @override
  String get descriptionHint => 'Tujuan singkat laporan ini';

  @override
  String get querySql => 'Query SQL';

  @override
  String get columnSettings => 'Pengaturan Kolom';

  @override
  String get detectColumns => 'Deteksi Kolom';

  @override
  String get reportQueryRequired => 'Query laporan wajib diisi';

  @override
  String get readOnlySelectQuery => 'Query SELECT read-only';

  @override
  String get reportQueryHelp =>
      'Hanya satu statement SELECT yang diperbolehkan. Saat field ini kehilangan fokus, kolom baru ditambahkan otomatis dan label yang sudah ada tetap dipertahankan.';

  @override
  String configuredColumns(Object count) {
    return '$count kolom dikonfigurasi';
  }

  @override
  String removeMissingColumns(Object count) {
    return 'Hapus yang Hilang ($count)';
  }

  @override
  String get noReportColumnsYet =>
      'Belum ada kolom. Input query, lalu keluar dari field query atau klik Deteksi Kolom.';

  @override
  String get inputQueryFirst => 'Input query terlebih dahulu.';

  @override
  String columnsSynchronizedAdded(Object count) {
    return 'Kolom disinkronkan. $count kolom baru ditambahkan.';
  }

  @override
  String columnsSynchronizedMissing(Object added, Object missing) {
    return 'Kolom disinkronkan. $added ditambahkan, $missing ditandai hilang.';
  }

  @override
  String get invalidReportQuery => 'Query laporan tidak valid';

  @override
  String get failedSaveReport => 'Gagal menyimpan laporan';

  @override
  String get reportSettingSubject => 'setting laporan';

  @override
  String get field => 'Field';

  @override
  String get columnLabel => 'Label';

  @override
  String get labelRequired => 'Label wajib diisi';

  @override
  String get align => 'Rata';

  @override
  String get width => 'Lebar';

  @override
  String get show => 'Tampil';

  @override
  String get missing => 'Hilang';

  @override
  String get missingColumnTooltip =>
      'Kolom yang dikonfigurasi ini tidak dikembalikan oleh query saat ini.';

  @override
  String get exportColumn => 'Export';

  @override
  String get exportedAt => 'Diexport Pada';

  @override
  String get totalRows => 'Total Baris';

  @override
  String get logoutTitle => 'Keluar?';

  @override
  String get logoutMessage => 'Anda akan kembali ke layar login.';

  @override
  String get noPermissionCreateUsers =>
      'Anda tidak memiliki akses untuk membuat user.';

  @override
  String get noPermissionUpdateUsers =>
      'Anda tidak memiliki akses untuk mengubah user.';

  @override
  String get noPermissionToggleUsers =>
      'Anda tidak memiliki akses untuk mengaktifkan atau menonaktifkan user.';

  @override
  String get noPermissionViewUserManagement =>
      'Anda tidak memiliki akses untuk melihat user management.';

  @override
  String get userManagementSubtitleAdmin =>
      'Kelola user, role permission, link guru, dan akses khusus.';

  @override
  String get userManagementSubtitleStandard =>
      'Kelola user aplikasi, link guru, dan akses menu tambahan.';

  @override
  String get addUser => 'Tambah User';

  @override
  String get usersTab => 'Users';

  @override
  String get rolesPermissions => 'Roles & Permissions';

  @override
  String get searchUsersHint => 'Cari username, nama lengkap, atau guru';

  @override
  String get user => 'User';

  @override
  String get teacherLink => 'Link Guru';

  @override
  String get extraAccess => 'Akses Tambahan';

  @override
  String extraAccessCount(Object count) {
    return '$count menu';
  }

  @override
  String get editUserTooltip => 'Ubah user';

  @override
  String get activateUser => 'Aktifkan User';

  @override
  String get deactivateUser => 'Nonaktifkan User';

  @override
  String activateUserConfirm(Object name) {
    return 'Aktifkan $name?';
  }

  @override
  String deactivateUserConfirm(Object name) {
    return 'Nonaktifkan $name?';
  }

  @override
  String get rolesPermissionsSubtitle =>
      'Admin selalu memiliki akses penuh. Atur aksi menu untuk role Staff dan Guru.';

  @override
  String rolePermissionsUpdated(Object role) {
    return 'Permission $role diperbarui.';
  }

  @override
  String get noMenuAvailable => 'Tidak ada menu tersedia';

  @override
  String get menuColumn => 'Menu';

  @override
  String get createUser => 'Buat User';

  @override
  String get editUser => 'Ubah User';

  @override
  String get updateUser => 'Update User';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get newPassword => 'Password Baru';

  @override
  String get leaveEmptyToKeep => 'Kosongkan jika tidak ingin mengubah';

  @override
  String get passwordRequired => 'Password wajib diisi';

  @override
  String get passwordMinLength => 'Password minimal 4 karakter';

  @override
  String get passwordMinLengthSix => 'Password minimal 6 karakter';

  @override
  String get passwordMaxLength => 'Password maksimal 64 karakter';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleStaff => 'Staff';

  @override
  String get roleTeacher => 'Guru';

  @override
  String get teacherRequired => 'Guru wajib dipilih';

  @override
  String get extraMenuAccess => 'Akses Menu Tambahan';

  @override
  String get noExtraMenuAccess =>
      'Tidak ada akses menu tambahan untuk role ini.';

  @override
  String get userCreated => 'User dibuat.';

  @override
  String get userUpdated => 'User diperbarui.';

  @override
  String get linkedTeacher => 'Guru terhubung';

  @override
  String requiredField(Object field) {
    return '$field wajib diisi';
  }

  @override
  String fieldTooShort(Object field) {
    return '$field terlalu pendek';
  }

  @override
  String get permissionView => 'Lihat';

  @override
  String get permissionCreate => 'Buat';

  @override
  String get permissionUpdate => 'Ubah';

  @override
  String get permissionDelete => 'Hapus';

  @override
  String get permissionExport => 'Export';

  @override
  String get permissionApprove => 'Setujui';

  @override
  String get login => 'Masuk';

  @override
  String get foundationName => 'Nama Yayasan';

  @override
  String get exportFilePrefix => 'Prefix File Export';

  @override
  String get currencyCode => 'Kode Mata Uang';

  @override
  String get currencySymbol => 'Simbol Mata Uang';

  @override
  String get defaultMinimumAttendance => 'Minimum Kehadiran Bawaan';

  @override
  String get defaultDashboardRange => 'Rentang Dashboard Bawaan';

  @override
  String get weekly => 'Mingguan';

  @override
  String get monthly => 'Bulanan';

  @override
  String get threeMonths => '3 Bulan';

  @override
  String get sixMonths => '6 Bulan';

  @override
  String get oneYear => '1 Tahun';

  @override
  String get storage => 'Penyimpanan';

  @override
  String get storageDescription =>
      'Lokasi database lokal dan penyimpanan dokumen yang diupload.';

  @override
  String get database => 'Database';

  @override
  String get uploads => 'Upload';

  @override
  String get maintenance => 'Pemeliharaan';

  @override
  String get maintenanceDescription =>
      'Alat untuk operasional desktop lokal. Backup membuat salinan database SQLite.';

  @override
  String get backingUp => 'Membuat Backup';

  @override
  String get backupDatabase => 'Backup Database';

  @override
  String get clearCache => 'Bersihkan Cache';

  @override
  String get minimize => 'Minimalkan';

  @override
  String get maximize => 'Maksimalkan';

  @override
  String get restore => 'Pulihkan';

  @override
  String get close => 'Tutup';

  @override
  String get back => 'Kembali';

  @override
  String get remove => 'Hapus';

  @override
  String get clear => 'Bersihkan';

  @override
  String get refresh => 'Refresh';

  @override
  String get edit => 'Ubah';

  @override
  String get delete => 'Hapus';

  @override
  String get continueLabel => 'Lanjutkan';

  @override
  String get browse => 'Telusuri';

  @override
  String get uploadedBy => 'Diupload Oleh';

  @override
  String get remarks => 'Catatan';

  @override
  String get reject => 'Tolak';

  @override
  String get addSelected => 'Tambah Terpilih';

  @override
  String get optional => 'Opsional';

  @override
  String get chooseDate => 'Pilih tanggal';

  @override
  String get clearDate => 'Bersihkan tanggal';

  @override
  String get assessmentNote => 'Catatan Penilaian';

  @override
  String get saveNotes => 'Simpan Catatan';

  @override
  String get noCandidatesSelected => 'Belum ada kandidat terpilih.';

  @override
  String get removeTarget => 'Hapus target';

  @override
  String get removeTargetCandidateTitle => 'Hapus Kandidat Target?';

  @override
  String get removeAllTargetCandidatesTitle => 'Hapus Semua Kandidat Target?';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get markAsSubmitted => 'Tandai Diajukan';

  @override
  String get rejectPeriod => 'Tolak Periode';

  @override
  String get rejectAssistancePeriodTitle => 'Tolak Periode Bantuan?';

  @override
  String get searchRecipientOrRule => 'Cari penerima atau aturan';

  @override
  String get cancelRecipient => 'Batalkan penerima';

  @override
  String get resetStatus => 'Reset status';

  @override
  String get handledBy => 'Ditangani Oleh';

  @override
  String get cancelPeriod => 'Batalkan Periode';

  @override
  String get cancelRecipientDistribution => 'Batalkan Distribusi Penerima';

  @override
  String get cancellationReason => 'Alasan pembatalan';

  @override
  String get cancelAssistancePeriodTitle => 'Batalkan Periode Bantuan?';

  @override
  String get removeZeroQuotaRulesTitle => 'Hapus aturan dengan kuota nol?';

  @override
  String get removeContinue => 'Hapus & Lanjutkan';

  @override
  String get selectAssistanceRule => 'Pilih Aturan Bantuan';

  @override
  String get addCustomRule => 'Tambah Aturan Kustom';

  @override
  String get addPeriod => 'Tambah Periode';

  @override
  String get editPeriod => 'Ubah periode';

  @override
  String get noAssistanceRules => 'Belum ada aturan bantuan';

  @override
  String get noStudentAssistanceRules => 'Belum ada aturan bantuan siswa';

  @override
  String get deleteStudentRule => 'Hapus Aturan Siswa';

  @override
  String get deleteAllocationRule => 'Hapus Aturan Alokasi';

  @override
  String get regenerateAssistancePlan => 'Buat Ulang Rencana Bantuan?';

  @override
  String get generate => 'Buat';

  @override
  String get saveTargetAssistance => 'Simpan Target Bantuan';

  @override
  String get createPeriodFirst => 'Buat periode terlebih dahulu.';

  @override
  String get noRuleAllocation => 'Belum ada alokasi aturan';

  @override
  String get targetStatus => 'Status Target';

  @override
  String get ruleType => 'Tipe Aturan';

  @override
  String get noTargetCandidates => 'Belum ada kandidat target';

  @override
  String get exportAssistancePlan => 'Export rencana bantuan';

  @override
  String get downloadRecipientsHistory => 'Download riwayat penerima';

  @override
  String get noApprovedRecipients => 'Belum ada penerima yang disetujui';

  @override
  String get selectPeriodFirst => 'Pilih periode terlebih dahulu.';

  @override
  String get chooseFile => 'Pilih File';

  @override
  String get uploading => 'Mengupload...';

  @override
  String get uploadApprove => 'Upload & Setujui';

  @override
  String get assistancePeriod => 'Periode Bantuan';

  @override
  String get month => 'Bulan';

  @override
  String get calculationWindowMonths => 'Rentang Perhitungan (bulan)';

  @override
  String get minimumAttendancePercent => 'Minimum Kehadiran (%)';

  @override
  String get allowManagerOverride =>
      'Izinkan manager override di bawah batas kehadiran';

  @override
  String get ruleMaster => 'Master Aturan';

  @override
  String get ruleName => 'Nama Aturan';

  @override
  String get priorityOrder => 'Urutan Prioritas';

  @override
  String get selectionMode => 'Mode Pemilihan';

  @override
  String get minimumScoreOptional => 'Nilai Minimum (opsional)';

  @override
  String get carryUnusedQuota =>
      'Bawa kuota tidak terpakai ke aturan berikutnya';

  @override
  String get active => 'Aktif';

  @override
  String get scoreOverrideOptional => 'Override Nilai (opsional)';

  @override
  String get priorityLevel => 'Level Prioritas';

  @override
  String get priorityReason => 'Alasan Prioritas';

  @override
  String get specialCaseNote => 'Catatan Kasus Khusus';

  @override
  String get approvedAmountSupport => 'Jumlah atau Bantuan Disetujui';

  @override
  String get deleteStrategyTitle => 'Hapus Strategi';

  @override
  String get deleteStrategyConfirm =>
      'Apakah Anda yakin ingin menghapus strategi ini?';

  @override
  String get noStrategiesYet => 'Belum ada strategi. Tambahkan strategi.';

  @override
  String get addSchool => 'Tambah Sekolah';

  @override
  String get editSchool => 'Ubah Sekolah';

  @override
  String get addClass => 'Tambah Kelas';

  @override
  String get deleteClass => 'Hapus Kelas';

  @override
  String get deleteSchool => 'Hapus Sekolah';

  @override
  String get searchSchoolName => 'Cari nama sekolah';

  @override
  String get noClassesForSchool => 'Belum ada kelas untuk sekolah ini.';

  @override
  String get noClassesYet => 'Belum ada kelas. Tambahkan kelas.';

  @override
  String get changeSchoolType => 'Ubah Tipe Sekolah';

  @override
  String get keepType => 'Pertahankan Tipe';

  @override
  String get removeClasses => 'Hapus Kelas';

  @override
  String get clearClasses => 'Bersihkan Kelas';

  @override
  String get clearAll => 'Bersihkan Semua';

  @override
  String get generateClassesTooltip => 'Buat semua level dengan bagian A/B/C';

  @override
  String get section => 'Bagian';

  @override
  String get noCurriculumsFound => 'Kurikulum tidak ditemukan';

  @override
  String get noSyllabusFound => 'Silabus tidak ditemukan';

  @override
  String get noSubjectsFound => 'Mata pelajaran tidak ditemukan';

  @override
  String get noUnitsFound => 'Unit tidak ditemukan';

  @override
  String get noCompetenciesFound => 'Kompetensi tidak ditemukan';

  @override
  String get noStrategiesFound => 'Strategi tidak ditemukan';

  @override
  String get downloadSample => 'Download contoh';

  @override
  String get selectVisible => 'Pilih yang Terlihat';

  @override
  String applySelectedCount(Object count) {
    return 'Terapkan ($count)';
  }

  @override
  String get saveSelected => 'Simpan Terpilih';

  @override
  String get lessonCompletion => 'Penyelesaian pelajaran';

  @override
  String get selectCompletion => 'Pilih penyelesaian';

  @override
  String get noStudentNotesYet => 'Belum ada catatan siswa.';

  @override
  String get followUpNeeded => 'Perlu tindak lanjut';

  @override
  String get evidenceFile => 'File Bukti';

  @override
  String get changeScoreTypeTitle => 'Ubah Tipe Nilai?';

  @override
  String get number => 'No';

  @override
  String get classDetails => 'Detail Kelas';

  @override
  String get generatedClassName => 'Nama Kelas (Dibuat Otomatis)';

  @override
  String get generatedClassHint => 'Dibuat dari tingkat, bagian, dan tahun';

  @override
  String get sampleImplementationFile => 'File Contoh Implementasi';

  @override
  String get allowedDocumentTypes =>
      'Diizinkan: xls, xlsx, doc, docx, txt, md, pdf';

  @override
  String get deleteClassConfirm => 'Yakin ingin menghapus kelas ini?';

  @override
  String deleteItemTitle(Object title) {
    return 'Hapus $title';
  }

  @override
  String get deleteAnyway => 'Tetap Hapus';

  @override
  String deleteItemConfirm(Object subject) {
    return 'Hapus $subject ini?';
  }

  @override
  String deleteConnectedItemConfirm(Object subject) {
    return 'Hapus $subject ini? Data ini terhubung dengan data lain.';
  }

  @override
  String get guardians => 'Wali';

  @override
  String get deleteGuardianTitle => 'Hapus Wali';

  @override
  String get deleteGuardianConfirm => 'Yakin ingin menghapus wali ini?';

  @override
  String get noGuardiansYet => 'Belum ada wali. Tambahkan wali.';

  @override
  String get phone => 'Telepon';

  @override
  String get minimizeAssistanceMenu => 'Kecilkan menu bantuan';

  @override
  String deleteRuleForStudent(Object student) {
    return 'Hapus aturan untuk $student?';
  }

  @override
  String get thisStudent => 'siswa ini';

  @override
  String selectRuleCandidates(Object rule) {
    return 'Pilih Kandidat $rule';
  }

  @override
  String get overrideReasonHint =>
      'Alasan / catatan override untuk siswa yang baru dipilih';

  @override
  String get customRule => 'Aturan Khusus';

  @override
  String get dragToReorder => 'Seret untuk mengubah urutan';

  @override
  String get ready => 'Siap';

  @override
  String get rejectedPeriodAuditNotice =>
      'Periode yang ditolak tidak dapat dilanjutkan ke distribusi. Kandidat target tetap terlihat untuk audit.';

  @override
  String get outOfCityExample =>
      'Contoh: Siswa berada di luar kota selama dua bulan';

  @override
  String get approvedPeriodCancellationHint =>
      'Alasan pembatalan periode bantuan yang telah disetujui';

  @override
  String selectStudentsForRule(Object rule) {
    return 'Pilih Siswa - $rule';
  }

  @override
  String get ruleNameRequired => 'Nama aturan wajib diisi';

  @override
  String get classNameRequired => 'Nama kelas wajib diisi';

  @override
  String get classNameMax40 => 'Nama kelas maksimal 40 karakter';

  @override
  String get duplicateClassYear => 'Kelas dan tahun sudah ada';

  @override
  String get levelRequired => 'Tingkat wajib dipilih';

  @override
  String get sectionRequired => 'Bagian wajib diisi';

  @override
  String get sectionOneLetter => 'Bagian harus berupa satu huruf';

  @override
  String get yearRequired => 'Tahun wajib diisi';

  @override
  String get yearFourDigits => 'Tahun harus terdiri dari 4 digit';

  @override
  String classesForSchool(Object school) {
    return 'Kelas - $school';
  }

  @override
  String deleteNamedItem(Object item) {
    return 'Hapus $item?';
  }

  @override
  String searchItems(Object item) {
    return 'Cari $item';
  }

  @override
  String get schoolsSubtitle => 'Kelola profil sekolah dan struktur kelasnya.';

  @override
  String get noSchoolsYet => 'Belum ada sekolah.';

  @override
  String get noSchoolsMatch => 'Tidak ada sekolah yang cocok dengan pencarian.';

  @override
  String get version => 'Versi';

  @override
  String get effectiveYear => 'Tahun Berlaku';

  @override
  String get sequence => 'Urutan';

  @override
  String get sample => 'Contoh';

  @override
  String get structure => 'Struktur';

  @override
  String get attendanceSectionSubtitle =>
      'Cari dan tandai kehadiran pada tabel.';

  @override
  String get assessmentSectionSubtitle =>
      'Isi nilai untuk tipe penilaian sesi yang dipilih.';

  @override
  String get materialCovered => 'Materi yang dibahas';

  @override
  String get classCondition => 'Kondisi kelas';

  @override
  String get teachingChallenges => 'Kendala pengajaran';

  @override
  String get followUpPlan => 'Rencana tindak lanjut';

  @override
  String get studentNotesReviewSubtitle =>
      'Tinjau observasi sosial yang ditambahkan dari penilaian siswa.';

  @override
  String get socialBehaviorRating => 'Penilaian sosial / perilaku';

  @override
  String get followUpNotes => 'Catatan tindak lanjut';

  @override
  String get settingsSubtitle => 'Kelola preferensi dan pengaturan aplikasi.';

  @override
  String get themeMode => 'Mode Tema';

  @override
  String get uiDensity => 'Kepadatan UI';

  @override
  String get dateFormat => 'Format Tanggal';

  @override
  String get timeFormat => 'Format Waktu';

  @override
  String get numberFormat => 'Format Angka';

  @override
  String get light => 'Terang';

  @override
  String get dark => 'Gelap';

  @override
  String get followSystem => 'Ikuti Sistem';

  @override
  String get compact => 'Ringkas';

  @override
  String get normal => 'Normal';

  @override
  String get comfortable => 'Nyaman';

  @override
  String get indonesian => 'Indonesia';

  @override
  String get englishUs => 'Inggris AS';

  @override
  String get rank => 'Peringkat';

  @override
  String get eligibility => 'Kelayakan';

  @override
  String get file => 'File';

  @override
  String get uploadedAt => 'Diunggah Pada';

  @override
  String get distributionProof => 'Bukti Distribusi';

  @override
  String get pendingRecipientStatus => 'Status Penerima Tertunda';

  @override
  String get noRecipientsYet =>
      'Belum ada penerima. Unggah dokumen persetujuan terlebih dahulu.';

  @override
  String get noRecipientsMatch =>
      'Tidak ada penerima yang cocok dengan filter.';

  @override
  String get markPaid => 'Tandai Dibayar';

  @override
  String get markDistributed => 'Tandai Didistribusikan';

  @override
  String get failedRemoveTargets => 'Gagal menghapus target';

  @override
  String get reportNotAvailable => 'Laporan tidak tersedia.';

  @override
  String get rejectedPeriodNoDistribution =>
      'Periode bantuan yang ditolak tidak dilanjutkan ke distribusi.';

  @override
  String get approvalRequiredFirst => 'Persetujuan diperlukan terlebih dahulu.';

  @override
  String get finalizeDistributionFailed => 'Gagal Menyelesaikan Distribusi';

  @override
  String get createAssistancePeriodFailed => 'Gagal Membuat Periode Bantuan';

  @override
  String get failedSaveManualTargets => 'Gagal menyimpan target manual';

  @override
  String get selectedTargets => 'Target Terpilih';

  @override
  String get waitlistCount => 'Jumlah Daftar Tunggu';

  @override
  String get ineligible => 'Tidak Layak';

  @override
  String get expandAssistanceMenu => 'Perluas menu bantuan';

  @override
  String get workflow => 'Alur Kerja';

  @override
  String get history => 'Riwayat';

  @override
  String get fixed => 'Tetap';

  @override
  String get rolling => 'Bergilir';

  @override
  String get window => 'Rentang';

  @override
  String get defaultLabel => 'Bawaan';

  @override
  String get priority => 'Prioritas';

  @override
  String get improve => 'Peningkatan';

  @override
  String get bonus => 'Bonus';

  @override
  String get monthYear => 'Bulan/Tahun';

  @override
  String get approvedBy => 'Disetujui Oleh';

  @override
  String get document => 'Dokumen';

  @override
  String get targetedAt => 'Ditargetkan Pada';

  @override
  String get newCustomRule => 'Aturan Khusus Baru';

  @override
  String get failedUpdateCandidates => 'Gagal memperbarui kandidat';

  @override
  String get all => 'Semua';

  @override
  String get allocated => 'Dialokasikan';

  @override
  String get code => 'Kode';

  @override
  String get change => 'Ubah';

  @override
  String get failed => 'Gagal';

  @override
  String get createClass => 'Buat Kelas';

  @override
  String get updateClass => 'Perbarui Kelas';

  @override
  String get approvalDocumentTitle => 'Dokumen Persetujuan';

  @override
  String get approvalDocumentUploadedDescription =>
      'Dokumen persetujuan yang ditandatangani telah diunggah. Target sekarang menjadi penerima resmi.';

  @override
  String get assistancePeriodLocked => 'Periode bantuan ini telah dikunci.';

  @override
  String get approvalDocumentUploadDescription =>
      'Unggah dokumen persetujuan yang ditandatangani untuk menyetujui periode ini dan membuat daftar penerima.';

  @override
  String get uploadedDocument => 'Dokumen Terunggah';

  @override
  String get approvalDecision => 'Keputusan Persetujuan';

  @override
  String get chooseApprovalDocument => 'Pilih dokumen persetujuan';

  @override
  String get uploadApprovePeriod => 'Unggah & Setujui Periode';

  @override
  String get noApprovePeriodPermission =>
      'Anda tidak memiliki izin untuk menyetujui periode.';

  @override
  String get assistancePeriodRejectedSuccess =>
      'Periode bantuan berhasil ditolak.';

  @override
  String get rejectAssistancePeriodFailed => 'Gagal menolak periode bantuan';

  @override
  String get approvalDocumentUploadedSuccess =>
      'Dokumen persetujuan berhasil diunggah. Periode disetujui.';

  @override
  String get uploadApprovePeriodFailed =>
      'Gagal mengunggah dan menyetujui periode';

  @override
  String get approvalRequiredDistributionMessage =>
      'Unggah dokumen persetujuan yang ditandatangani pada Review & Approval sebelum mengelola distribusi.';

  @override
  String get bulkRecipientActions => 'Aksi massal penerima';

  @override
  String get markAllPaidDistributed => 'Tandai Semua Dibayar / Didistribusikan';

  @override
  String get cancelAll => 'Batalkan Semua';

  @override
  String get bulkAction => 'Aksi Massal';

  @override
  String get reportFinalized => 'Laporan & Finalisasi';

  @override
  String get assistancePeriodFinalizedMessage =>
      'Periode bantuan ini telah difinalisasi.';

  @override
  String get distributionFinalizeInstruction =>
      'Isi status setiap penerima dan unggah daftar distribusi yang ditandatangani sebelum finalisasi.';

  @override
  String get finalizeActions => 'Aksi finalisasi';

  @override
  String get finalizeDistribution => 'Finalisasi Distribusi';

  @override
  String get finalizing => 'Memfinalisasi...';

  @override
  String get finalizeAction => 'Aksi Finalisasi';

  @override
  String get distributionEvidence => 'Bukti Distribusi';

  @override
  String documentCountOfFive(Object count) {
    return '$count / 5 dokumen';
  }

  @override
  String get chooseEvidence => 'Pilih Bukti';

  @override
  String get uploadEvidence => 'Unggah Bukti';

  @override
  String get evidenceFileRemarks => 'Catatan file bukti';

  @override
  String get evidenceFileRemarksHint => 'Jelaskan file bukti distribusi ini';

  @override
  String get maximumDistributionEvidence =>
      'Maksimal 5 dokumen bukti distribusi telah diunggah.';

  @override
  String get distributionEvidenceDocuments => 'Dokumen Bukti Distribusi';

  @override
  String get noDistributionEvidence =>
      'Belum ada dokumen bukti distribusi yang diunggah.';

  @override
  String get downloadEvidence => 'Unduh bukti';

  @override
  String get deleteEvidence => 'Hapus bukti';

  @override
  String get distributionEvidenceUploaded =>
      'Bukti distribusi berhasil diunggah.';

  @override
  String get uploadDistributionEvidenceFailed =>
      'Gagal mengunggah bukti distribusi';

  @override
  String get deleteDistributionEvidenceTitle => 'Hapus Bukti Distribusi?';

  @override
  String deleteDistributionEvidenceMessage(Object fileName) {
    return 'Hapus \"$fileName\"? File yang tersimpan juga akan dihapus.';
  }

  @override
  String get distributionEvidenceDeleted =>
      'Bukti distribusi berhasil dihapus.';

  @override
  String get deleteDistributionEvidenceFailed =>
      'Gagal menghapus bukti distribusi';

  @override
  String get markAllRecipientsTitle => 'Tandai Semua Penerima?';

  @override
  String get markAllRecipientsMessage =>
      'Bantuan tunai akan ditandai Dibayar. Barang dan bantuan lainnya akan ditandai Didistribusikan.';

  @override
  String get markAll => 'Tandai Semua';

  @override
  String get allRecipientStatusesUpdated =>
      'Semua status penerima berhasil diperbarui.';

  @override
  String get updateAllRecipientsFailed => 'Gagal memperbarui semua penerima';

  @override
  String get cancelAllRecipientsTitle => 'Batalkan Semua Penerima?';

  @override
  String get cancelAllRecipientsHint =>
      'Jelaskan alasan seluruh distribusi penerima dibatalkan.';

  @override
  String get cancellationReasonRequired => 'Alasan pembatalan wajib diisi.';

  @override
  String get allRecipientsCancelled => 'Semua penerima berhasil dibatalkan.';

  @override
  String get cancelAllRecipientsFailed => 'Gagal membatalkan semua penerima';

  @override
  String get resetAllRecipientStatusesTitle => 'Reset Semua Status Penerima?';

  @override
  String get resetAllRecipientStatusesMessage =>
      'Semua status penerima akan kembali menjadi Disetujui dan alasan pembatalan akan dihapus.';

  @override
  String get allRecipientStatusesReset =>
      'Semua status penerima berhasil direset.';

  @override
  String get resetAllRecipientsFailed => 'Gagal mereset semua penerima';

  @override
  String get recipientStatusUpdated => 'Status penerima berhasil diperbarui.';

  @override
  String get assistancePeriodFinalizedSuccess =>
      'Periode bantuan berhasil difinalisasi sebagai didistribusikan.';

  @override
  String get assistancePeriodCancelledSuccess =>
      'Periode bantuan berhasil dibatalkan.';

  @override
  String get startupPreparingWorkspace => 'Menyiapkan ruang kerja Anda...';

  @override
  String get startupFailed => 'Edukita tidak dapat menyelesaikan proses awal.';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get accountSecurity => 'Keamanan Akun';

  @override
  String get accountSecurityDescription =>
      'Jaga kerahasiaan dan perbarui kata sandi akun Edukita Anda.';

  @override
  String get changePassword => 'Ubah Kata Sandi';

  @override
  String get createNewPassword => 'Buat Kata Sandi Baru';

  @override
  String get temporaryPasswordMustBeReplaced =>
      'Kata sandi sementara harus diganti sebelum melanjutkan.';

  @override
  String get strongPasswordDescription =>
      'Gunakan kata sandi kuat yang tidak Anda gunakan di tempat lain.';

  @override
  String get currentPassword => 'Kata Sandi Saat Ini';

  @override
  String get confirmNewPassword => 'Konfirmasi Kata Sandi Baru';

  @override
  String get passwordChangedLoginAgain =>
      'Kata sandi berhasil diubah. Silakan masuk kembali.';

  @override
  String get currentPasswordIncorrect => 'Kata sandi saat ini salah.';

  @override
  String get passwordMinimumEight =>
      'Kata sandi harus berisi minimal 8 karakter.';

  @override
  String get newPasswordMustDiffer => 'Kata sandi baru harus berbeda.';

  @override
  String get passwordsDoNotMatch => 'Kata sandi tidak cocok.';

  @override
  String fieldRequiredMessage(Object field) {
    return '$field wajib diisi.';
  }

  @override
  String fieldMinimumCharacters(Object field, int count) {
    return '$field minimal harus $count karakter.';
  }

  @override
  String fieldMaximumCharacters(Object field, int count) {
    return '$field maksimal boleh $count karakter.';
  }

  @override
  String get mobileNumberRequired => 'Nomor ponsel wajib diisi.';

  @override
  String get mobileNumberLengthInvalid =>
      'Nomor ponsel harus terdiri dari 11 sampai 13 digit.';

  @override
  String get emailFormatInvalid => 'Format email tidak valid.';

  @override
  String guardianNumberName(int number) {
    return 'Nama wali #$number';
  }

  @override
  String guardianNumberError(int number, Object error) {
    return 'Wali #$number: $error';
  }

  @override
  String activityNumberType(int number) {
    return 'Jenis kegiatan #$number';
  }

  @override
  String activityNumberName(int number) {
    return 'Nama kegiatan #$number';
  }

  @override
  String activityNumberStartDateError(int number, Object error) {
    return 'Tanggal mulai kegiatan #$number: $error';
  }

  @override
  String activityNumberEndDateError(int number, Object error) {
    return 'Tanggal selesai kegiatan #$number: $error';
  }

  @override
  String get useDateFormat => 'Gunakan format YYYY-MM-DD.';

  @override
  String get duplicateClassAndYear => 'Kelas dan tahun tidak boleh sama.';

  @override
  String classNumberDuplicateClassAndYear(int number) {
    return 'Kelas #$number: kelas dan tahun tidak boleh sama.';
  }

  @override
  String get alphabetOnly => 'Hanya boleh menggunakan huruf.';

  @override
  String get failedToSaveSchedule => 'Gagal menyimpan jadwal.';

  @override
  String pleaseSelectField(Object field) {
    return 'Silakan pilih $field.';
  }

  @override
  String fieldCannotBeEmpty(Object field) {
    return '$field tidak boleh kosong.';
  }

  @override
  String sortByDescending(Object column) {
    return 'Urutkan $column secara menurun.';
  }

  @override
  String sortedByDescending(Object column) {
    return '$column diurutkan secara menurun.';
  }

  @override
  String sortedByAscending(Object column) {
    return '$column diurutkan secara menaik.';
  }

  @override
  String get removeAllClassesConfirm =>
      'Hapus semua kelas yang telah dimasukkan dari formulir sekolah ini?';

  @override
  String get schoolInfo => 'Informasi Sekolah';

  @override
  String get schoolName => 'Nama Sekolah';

  @override
  String classesCount(int count) {
    return 'Kelas ($count)';
  }

  @override
  String get editClass => 'Ubah Kelas';

  @override
  String duplicateClassEntry(int number) {
    return 'Kelas #$number: kelas dan tahun tidak boleh sama.';
  }

  @override
  String get addCurriculum => 'Tambah Kurikulum';

  @override
  String get editCurriculum => 'Ubah Kurikulum';

  @override
  String get addSyllabus => 'Tambah Silabus';

  @override
  String get editSyllabus => 'Ubah Silabus';

  @override
  String get editSubject => 'Ubah Mata Pelajaran';

  @override
  String get editUnit => 'Ubah Unit';

  @override
  String get addCompetency => 'Tambah Kompetensi';

  @override
  String get editCompetency => 'Ubah Kompetensi';

  @override
  String get addStrategy => 'Tambah Strategi';

  @override
  String get editStrategy => 'Ubah Strategi';

  @override
  String get noSampleFile => 'Tidak ada berkas contoh';

  @override
  String get reviewCannotUndo =>
      'Periksa kembali sebelum melanjutkan. Tindakan ini tidak dapat dibatalkan.';

  @override
  String cancelledWithReason(Object reason) {
    return 'Dibatalkan: $reason';
  }

  @override
  String get noStudentsAvailable => 'Tidak ada siswa yang tersedia.';

  @override
  String get noNoteHistoryForStudent =>
      'Belum ada riwayat catatan untuk siswa ini.';

  @override
  String addedByName(Object name) {
    return 'Ditambahkan oleh $name';
  }

  @override
  String get noActiveStudentsInClass => 'Tidak ada siswa aktif di kelas ini.';

  @override
  String saveAllCount(int count) {
    return 'Simpan Semua ($count)';
  }

  @override
  String deleteAssessmentForStudent(Object student) {
    return 'Hapus penilaian untuk $student?';
  }

  @override
  String get deleteSavedAssessment => 'Hapus penilaian tersimpan';

  @override
  String get noSavedRecord => 'Belum ada data tersimpan';

  @override
  String get deleteStudentNoteConfirm => 'Hapus catatan siswa ini?';

  @override
  String get editStudentNote => 'Ubah Catatan Siswa';

  @override
  String get addStudentNote => 'Tambah Catatan Siswa';

  @override
  String get updateNote => 'Perbarui Catatan';

  @override
  String get addNote => 'Tambah Catatan';

  @override
  String get selectPrimaryGuardian => 'Pilih satu wali utama.';

  @override
  String get studentCannotRelateSelf =>
      'Siswa tidak dapat dihubungkan dengan dirinya sendiri.';

  @override
  String get noActivitiesYet => 'Belum ada kegiatan';

  @override
  String get yes => 'Ya';

  @override
  String get no => 'Tidak';

  @override
  String get scopeSchool => 'Sekolah';

  @override
  String get scopeInternal => 'Internal';

  @override
  String evidenceRequiredForType(Object type) {
    return 'Wajib untuk $type. Format yang diizinkan: PDF, JPG, PNG.';
  }

  @override
  String get selectedFile => 'Berkas terpilih';

  @override
  String get noFile => 'Tidak ada berkas';

  @override
  String get next => 'Berikutnya';

  @override
  String get update => 'Perbarui';

  @override
  String get systemLabel => 'Sistem';

  @override
  String get customLabel => 'Kustom';

  @override
  String get systemRuleToggleOnly =>
      'Aturan sistem hanya dapat diaktifkan atau dinonaktifkan';

  @override
  String get editCustomRule => 'Ubah aturan kustom';

  @override
  String get editCustomRuleTitle => 'Ubah Aturan Kustom';

  @override
  String removeTargetCandidateConfirm(Object student, Object rule) {
    return 'Hapus $student dari target $rule?';
  }

  @override
  String removeAllTargetCandidatesConfirm(int count, Object rule) {
    return 'Hapus semua $count kandidat terpilih dari $rule?';
  }

  @override
  String get removedFromTargetPlan => 'Dihapus dari rencana target';

  @override
  String remainingCount(int count) {
    return 'Sisa $count';
  }

  @override
  String overAllocatedCount(int count) {
    return 'Kelebihan $count';
  }

  @override
  String get minimumAttendanceShort => 'Min. Kehadiran';

  @override
  String get reportNameHint => 'Laporan Nilai Ujian Siswa';

  @override
  String get success => 'Berhasil';

  @override
  String get changesSavedSuccessfully => 'Perubahan berhasil disimpan.';

  @override
  String get failedToSaveChanges => 'Gagal menyimpan perubahan.';

  @override
  String get noDataAvailable => 'Tidak ada data';

  @override
  String get unknownDate => 'Tanggal tidak diketahui';

  @override
  String get assistancePlanTitle => 'Rencana Bantuan';

  @override
  String get assistanceCandidatePlanTitle => 'Rencana Kandidat Bantuan';

  @override
  String get assistanceRecipientsTitle => 'Penerima Bantuan';

  @override
  String get eligible => 'Memenuhi Syarat';

  @override
  String get preparedBy => 'Disiapkan oleh';

  @override
  String get reviewedBy => 'Ditinjau oleh';

  @override
  String get totalRecipients => 'Total Penerima';

  @override
  String get nameDate => 'Nama / Tanggal';

  @override
  String get fixedPriority => 'Prioritas Tetap';

  @override
  String get needBased => 'Berdasarkan Kebutuhan';

  @override
  String get meritBased => 'Berdasarkan Prestasi';

  @override
  String get growthBased => 'Berdasarkan Perkembangan';

  @override
  String get specialCase => 'Kasus Khusus';

  @override
  String get teacherRecommendation => 'Rekomendasi Pengajar';

  @override
  String get rollingAttendance => 'Rotasi Kehadiran';

  @override
  String get manualPriority => 'Prioritas Manual';

  @override
  String get temporarySupport => 'Bantuan Sementara';

  @override
  String get attendanceBased => 'Berdasarkan Kehadiran';

  @override
  String changeSchoolTypeRemovesClasses(Object oldType, Object newType) {
    return 'Mengubah jenis sekolah dari $oldType menjadi $newType akan menghapus kelas yang telah dibuat untuk $oldType.';
  }

  @override
  String get invalidUsernameOrPassword =>
      'Nama pengguna atau kata sandi salah.';

  @override
  String get loginFailedTryAgain => 'Gagal masuk. Silakan coba lagi.';

  @override
  String get linkedTeacherProfile => 'Profil pengajar yang terhubung';

  @override
  String scheduleCount(int count) {
    return '$count jadwal';
  }

  @override
  String eventCount(int count) {
    return '$count acara';
  }

  @override
  String get unnamedSchool => 'Sekolah Tanpa Nama';

  @override
  String starsCount(Object score) {
    return '$score bintang';
  }

  @override
  String followUpWithNotes(Object notes) {
    return 'Tindak lanjut: $notes';
  }

  @override
  String shownCount(int count) {
    return '$count ditampilkan';
  }

  @override
  String get defaultScore => 'Nilai default';

  @override
  String get defaultRating => 'Rating default';

  @override
  String shownSelectedCount(int shown, int selected) {
    return '$shown ditampilkan | $selected dipilih';
  }

  @override
  String get defaultScoreRangeError => 'Nilai default harus antara 0 dan 100.';

  @override
  String get defaultRatingRangeError =>
      'Rating default harus antara 0,5 dan 5.';

  @override
  String assessmentModeDescription(Object type, Object mode) {
    return '$type menggunakan $mode.';
  }

  @override
  String get numericScoreRange => 'nilai angka 0-100';

  @override
  String get starRatingRange => 'rating bintang 0,5-5';

  @override
  String get enterNote => 'Masukkan catatan';

  @override
  String enterField(Object field) {
    return 'Masukkan $field';
  }

  @override
  String get allowedSampleFileTypes =>
      'Hanya berkas Excel, Word, TXT, MD, dan PDF yang diizinkan.';

  @override
  String get unsupportedSampleFileType => 'Jenis berkas contoh tidak didukung.';

  @override
  String get assistanceRulesSubtitle =>
      'Kelola data master aturan bantuan dan aturan manual kustom.';

  @override
  String get thisWillAlsoAffect => 'Ini juga akan berdampak pada:';

  @override
  String get setupStructure => 'Atur struktur';

  @override
  String get planMarkedSubmitted =>
      'Rencana bantuan telah ditandai sebagai diajukan.';

  @override
  String get approvalDocumentFileType => 'PDF, JPG, atau PNG';

  @override
  String get dragRowsPriority => 'Seret baris untuk mengubah prioritas.';

  @override
  String zeroQuotaRulesWarning(Object rules) {
    return 'Beberapa aturan terpilih memiliki kuota 0: $rules.\n\nJika dilanjutkan, aturan tersebut akan dihapus dari pengaturan periode bantuan ini.';
  }

  @override
  String get approvalDocumentFileLabel => 'Dokumen persetujuan';

  @override
  String reviewExportSummary(
    int target,
    int selected,
    int eligible,
    int manual,
    int auto,
  ) {
    return 'Tinjau & Ekspor\nTarget: $target | Terpilih: $selected | Memenuhi Syarat: $eligible | Manual: $manual | Otomatis: $auto';
  }

  @override
  String candidateQuotaSummary(int quota, int selected, int remaining) {
    return 'Kuota: $quota | Terpilih: $selected | Sisa: $remaining | Minimum kehadiran berlaku saat pembuatan target';
  }

  @override
  String impactUnitsDeleted(int count) {
    return '$count unit akan dihapus';
  }

  @override
  String impactSyllabiDetached(int count) {
    return '$count referensi silabus akan dilepas';
  }

  @override
  String impactSchedulesDeleted(int count) {
    return '$count jadwal mengajar akan dihapus';
  }

  @override
  String impactAssessmentsDeleted(int count) {
    return '$count penilaian akan dihapus';
  }

  @override
  String impactCompetenciesDeleted(int count) {
    return '$count data kompetensi akan dihapus';
  }

  @override
  String impactStudentScoresDetached(int count) {
    return '$count referensi nilai siswa akan dilepas';
  }

  @override
  String selectField(Object field) {
    return 'Pilih $field';
  }

  @override
  String get orType => 'atau ketik';

  @override
  String get eventTypeExam => 'Ujian';

  @override
  String get eventTypeHoliday => 'Libur';

  @override
  String get eventTypeReportCard => 'Rapor';

  @override
  String get curriculumSectionDescription =>
      'Kelola versi kurikulum, tahun berlaku, dan kerangka pembelajaran aktif.';

  @override
  String get subjectSectionDescription =>
      'Kelola master mata pelajaran sebelum digunakan pada silabus dan jadwal.';

  @override
  String get syllabusSectionDescription =>
      'Tentukan rencana pembelajaran berdasarkan kurikulum, jenis sekolah, level, dan semester.';

  @override
  String get unitSectionDescription =>
      'Atur unit pembelajaran secara berurutan di bawah setiap mata pelajaran.';

  @override
  String get competencySectionDescription =>
      'Kelola target kompetensi terukur untuk setiap unit pembelajaran.';

  @override
  String get strategySectionDescription =>
      'Kelola strategi mengajar yang digunakan dalam jadwal dan perencanaan pembelajaran.';

  @override
  String get waitlist => 'Daftar Tunggu';

  @override
  String get pending => 'Menunggu';

  @override
  String get overridden => 'Dikecualikan';

  @override
  String get aboutEdukita => 'Tentang Edukita';

  @override
  String get aboutEdukitaDescription =>
      'Identitas aplikasi dan informasi versi yang terpasang.';

  @override
  String get product => 'Produk';

  @override
  String get publisher => 'Penerbit';

  @override
  String get databaseSchema => 'Skema Database';

  @override
  String get loadingValue => 'Memuat...';

  @override
  String get temporaryPassword => 'Kata Sandi Sementara';

  @override
  String get generateTemporaryPassword => 'Buat dan salin kata sandi sementara';

  @override
  String get temporaryPasswordGeneratedCopied =>
      'Kata sandi sementara berhasil dibuat dan disalin.';

  @override
  String get registrationFormUnavailable =>
      'Formulir pendaftaran tidak tersedia.';

  @override
  String get registrationFormNotFound =>
      'Formulir pendaftaran tidak ditemukan di penyimpanan.';

  @override
  String get registrationFormDownloaded =>
      'Formulir pendaftaran berhasil diunduh.';

  @override
  String get registrationFormDownloadFailed =>
      'Gagal mengunduh formulir pendaftaran.';

  @override
  String get loadingRegistrationForm => 'Memuat formulir pendaftaran...';

  @override
  String get noRegistrationFormUploaded =>
      'Belum ada formulir pendaftaran yang diunggah.';

  @override
  String get download => 'Unduh';

  @override
  String errorWithDetails(Object details) {
    return 'Kesalahan: $details';
  }

  @override
  String get createSchoolBeforeAddingStudents =>
      'Buat sekolah sebelum menambahkan siswa.';

  @override
  String get createClassBeforeAddingStudents =>
      'Buat kelas sebelum menambahkan siswa.';

  @override
  String activityEndBeforeStart(int number) {
    return 'Tanggal selesai aktivitas #$number tidak boleh sebelum tanggal mulai.';
  }

  @override
  String get duplicateSibling =>
      'Saudara yang sama tidak dapat ditambahkan lebih dari sekali.';

  @override
  String get birthDateAfterJoinDate =>
      'Tanggal lahir tidak boleh setelah tanggal bergabung.';

  @override
  String get siblingGuardiansCopied =>
      'Data wali saudara disalin ke bagian keluarga.';

  @override
  String get nisMaxTenCharacters => 'NIS maksimal 10 karakter.';

  @override
  String get fullNameMinimumThree => 'Nama lengkap minimal 3 karakter.';

  @override
  String get fullNameMaximumEighty => 'Nama lengkap maksimal 80 karakter.';

  @override
  String get selectSchoolRequired => 'Silakan pilih sekolah.';

  @override
  String get selectClassRequired => 'Silakan pilih kelas.';

  @override
  String get householdEducationProfile => 'Profil Rumah Tangga & Pendidikan';

  @override
  String get homeAddress => 'Alamat Rumah';

  @override
  String get homeAddressHint =>
      'Jalan, RT/RW, nomor rumah, desa, dan kecamatan';

  @override
  String get bloodType => 'Golongan Darah';

  @override
  String get allergies => 'Alergi';

  @override
  String get medicalNotes => 'Catatan Medis';

  @override
  String get disabilities => 'Disabilitas';

  @override
  String get dailySchoolTransportCost =>
      'Biaya Transportasi Sekolah Harian (Rp/hari)';

  @override
  String get housingStatus => 'Status Tempat Tinggal';

  @override
  String get selectHousingStatus => 'Pilih status tempat tinggal';

  @override
  String get housingStatusOwned => 'Milik sendiri';

  @override
  String get housingStatusRented => 'Sewa';

  @override
  String get housingStatusStayingWithFamily => 'Tinggal bersama keluarga';

  @override
  String get housingStatusOther => 'Lainnya';

  @override
  String get activityTypeSchoolExtracurricular => 'Ekstrakurikuler Sekolah';

  @override
  String get activityTypeMartialArts => 'Bela Diri';

  @override
  String get activityTypeArts => 'Seni';

  @override
  String get activityTypeRoboticsClub => 'Klub Robotika';

  @override
  String get activityTypeLanguageClub => 'Klub Bahasa';

  @override
  String get activityTypeCommunityService => 'Kegiatan Sosial';

  @override
  String get activityTypeCompetition => 'Kompetisi';

  @override
  String get activityTypeOtherActivity => 'Aktivitas Lainnya';

  @override
  String get familyRelationMother => 'Ibu';

  @override
  String get familyRelationFather => 'Ayah';

  @override
  String get familyRelationBrother => 'Saudara Laki-laki';

  @override
  String get familyRelationSister => 'Saudara Perempuan';

  @override
  String get familyRelationUncle => 'Paman';

  @override
  String get familyRelationAunt => 'Bibi';

  @override
  String get familyRelationGrandfather => 'Kakek';

  @override
  String get familyRelationGrandmother => 'Nenek';

  @override
  String guardianIncomeFor(Object relation) {
    return 'Penghasilan $relation (Rp/bulan)';
  }

  @override
  String get income => 'Penghasilan (Rp/bulan)';

  @override
  String get agePositionOlder => 'Lebih Tua';

  @override
  String get agePositionYounger => 'Lebih Muda';

  @override
  String get examSourceSchoolReport => 'Laporan Sekolah';

  @override
  String get examSourceTryout => 'Uji Coba';

  @override
  String get examSourceExternal => 'Eksternal';

  @override
  String get householdMemberCount => 'Jumlah Anggota Keluarga (orang)';

  @override
  String get fatherIncome => 'Penghasilan Ayah (Rp/bulan)';

  @override
  String get motherIncome => 'Penghasilan Ibu (Rp/bulan)';

  @override
  String get educationArrears => 'Tunggakan Pendidikan (Rp)';

  @override
  String get academicAchievement => 'Prestasi Akademik';

  @override
  String get academicAchievementHint => 'Peringkat atau kompetisi akademik';

  @override
  String get nonAcademicAchievement => 'Prestasi Non-Akademik';

  @override
  String get nonAcademicAchievementHint => 'Prestasi olahraga atau seni';

  @override
  String fieldMustBeNumber(Object field) {
    return '$field harus berupa angka.';
  }

  @override
  String fieldMustBeAtLeastOne(Object field) {
    return '$field minimal 1.';
  }

  @override
  String get mustBeNumber => 'Harus berupa angka.';

  @override
  String get studentIdNoRequired => 'ID atau nomor siswa wajib diisi.';

  @override
  String get typeRequired => 'Tipe wajib diisi.';

  @override
  String get evidenceNotAttached => 'Tidak ada file bukti yang dilampirkan.';

  @override
  String get evidenceNotFound => 'File bukti tidak ditemukan di penyimpanan.';

  @override
  String get evidenceDownloaded => 'Bukti berhasil diunduh.';

  @override
  String get evidenceDownloadFailed => 'Gagal mengunduh bukti.';

  @override
  String evidenceRequiredForExamType(Object examType) {
    return 'File bukti wajib untuk $examType.';
  }

  @override
  String get examDateRequired => 'Tanggal ujian wajib diisi.';

  @override
  String get allowedPdfJpgPng =>
      'Hanya file PDF, JPG, dan PNG yang diperbolehkan.';

  @override
  String get evidenceMaxTwentyMb => 'File bukti maksimal 20 MB.';

  @override
  String get inputAtLeastOneScore => 'Masukkan minimal satu nilai.';

  @override
  String fieldMustNotExceedMax(Object field) {
    return '$field tidak boleh melebihi nilai maksimum.';
  }

  @override
  String get studentPhotoUnavailable => 'Foto siswa tidak tersedia.';

  @override
  String get studentPhotoNotFound => 'File foto siswa tidak ditemukan.';

  @override
  String get studentPhotoDownloaded => 'Foto siswa berhasil diunduh.';

  @override
  String get studentPhotoDownloadFailed => 'Gagal mengunduh foto siswa.';

  @override
  String get attendanceSaved => 'Kehadiran berhasil disimpan.';

  @override
  String scoreRequiredFor(Object item) {
    return 'Nilai $item wajib diisi.';
  }

  @override
  String scoreMustBeZeroToHundred(Object item) {
    return '$item harus antara 0-100.';
  }

  @override
  String scoreMustBeHalfToFiveStars(Object item) {
    return '$item harus antara 0,5-5 bintang.';
  }

  @override
  String studentReportingSaved(Object student) {
    return 'Laporan $student berhasil disimpan.';
  }

  @override
  String get assessmentDeleted => 'Penilaian berhasil dihapus.';

  @override
  String get selectAtLeastOneStudent =>
      'Pilih minimal satu siswa terlebih dahulu.';

  @override
  String assessmentRowsSaved(int count) {
    return '$count baris penilaian berhasil disimpan.';
  }

  @override
  String get sessionNotesSaved => 'Catatan sesi berhasil disimpan.';

  @override
  String get studentNoteDeleted => 'Catatan siswa berhasil dihapus.';

  @override
  String get commentRequired => 'Komentar wajib diisi.';

  @override
  String get studentNoteAdded => 'Catatan siswa berhasil ditambahkan.';

  @override
  String get studentNoteUpdated => 'Catatan siswa berhasil diperbarui.';

  @override
  String get enterLevel => 'Silakan masukkan level.';

  @override
  String levelMustMatch(Object hint) {
    return 'Level harus $hint.';
  }

  @override
  String get yearMustFourDigits => 'Tahun harus terdiri dari 4 digit.';

  @override
  String get schoolNameRequired => 'Nama sekolah wajib diisi.';

  @override
  String get schoolNameMinimumThree => 'Nama sekolah minimal 3 karakter.';

  @override
  String get schoolNameMaximumEighty => 'Nama sekolah maksimal 80 karakter.';

  @override
  String get addressRequired => 'Alamat wajib diisi.';

  @override
  String get addressMinimumFive => 'Alamat minimal 5 karakter.';

  @override
  String get addressMaximumOneSixty => 'Alamat maksimal 160 karakter.';

  @override
  String get curriculumNameRequired => 'Nama kurikulum wajib diisi.';

  @override
  String get syllabusTitleRequired => 'Judul silabus wajib diisi.';

  @override
  String get subjectNameRequired => 'Nama mata pelajaran wajib diisi.';

  @override
  String get unitNameRequired => 'Nama unit wajib diisi.';

  @override
  String get competencyDescriptionRequired =>
      'Deskripsi kompetensi wajib diisi.';

  @override
  String get strategyNameRequired => 'Nama strategi wajib diisi.';

  @override
  String get sampleFileNotAttached =>
      'Tidak ada file contoh yang dilampirkan pada strategi ini.';

  @override
  String get sampleFileNotFound =>
      'File contoh tidak ditemukan di penyimpanan.';

  @override
  String get sampleFileDownloaded => 'File contoh berhasil diunduh.';

  @override
  String get sampleFileDownloadFailed => 'Gagal mengunduh file contoh.';

  @override
  String get minimumAttendanceRangeError =>
      'Kehadiran minimum harus antara 0 dan 100.';

  @override
  String databaseBackupCreated(Object path) {
    return 'Cadangan database berhasil dibuat: $path';
  }

  @override
  String get applicationCacheCleared => 'Cache aplikasi berhasil dibersihkan.';

  @override
  String get selectOption => 'Pilih opsi';

  @override
  String get periodCreateDenied =>
      'Anda tidak memiliki izin untuk membuat periode.';

  @override
  String get targetCandidateRemoved => 'Kandidat target berhasil dihapus.';

  @override
  String get targetCandidatesRemoved => 'Kandidat target berhasil dihapus.';

  @override
  String get manualTargetsSaved => 'Target manual berhasil disimpan.';

  @override
  String get allocatedQuotaMustEqualTargetQuota =>
      'Kuota yang dialokasikan harus sama dengan target kuota.';

  @override
  String get assistancePeriodCreated => 'Periode bantuan berhasil dibuat.';

  @override
  String get approvalDocumentNotFound =>
      'File dokumen persetujuan tidak ditemukan.';

  @override
  String get approvalDocumentDownloaded =>
      'Dokumen persetujuan berhasil diunduh.';

  @override
  String get planExportedSubmitted =>
      'Rencana berhasil diekspor dan ditandai sebagai diajukan.';

  @override
  String get planExported => 'Rencana berhasil diekspor.';

  @override
  String get recipientListExported => 'Daftar penerima berhasil diekspor.';

  @override
  String get filter => 'Filter';

  @override
  String get activeFilters => 'Filter aktif';

  @override
  String get noFiltersYet => 'Belum ada filter.';

  @override
  String get addFilter => 'Tambah Filter';

  @override
  String get filterOperator => 'Operator';

  @override
  String get filterIsEqual => 'Sama dengan';

  @override
  String get filterIsNot => 'Tidak sama dengan';

  @override
  String get filterContains => 'Memuat';

  @override
  String get filterHasAnyValue => 'Memiliki nilai';

  @override
  String get value => 'Nilai';

  @override
  String get done => 'Selesai';

  @override
  String get locationTeaching => 'Lokasi Pengajaran';

  @override
  String get locationTeachingDescription =>
      'Kelola lokasi pengajaran yang digunakan untuk jadwal dan sesi mengajar.';

  @override
  String get teachingLocation => 'Lokasi pengajaran';

  @override
  String get addTeachingLocation => 'Tambah Lokasi';

  @override
  String get editTeachingLocation => 'Ubah Lokasi';

  @override
  String get locationType => 'Tipe Lokasi';

  @override
  String get locationTypeClassroom => 'Ruang Kelas';

  @override
  String get locationTypeHall => 'Aula';

  @override
  String get locationTypeMosque => 'Masjid';

  @override
  String get locationTypeOnline => 'Online';

  @override
  String get locationTypeStudentHome => 'Rumah Siswa';

  @override
  String get locationTypeOutdoor => 'Luar Ruangan';

  @override
  String get locationTypeOther => 'Lainnya';

  @override
  String get searchTeachingLocation => 'Cari kode, nama, alamat...';

  @override
  String get noTeachingLocations => 'Belum ada lokasi pengajaran.';

  @override
  String get teachingLocationNameRequired =>
      'Nama lokasi pengajaran wajib diisi.';

  @override
  String get teachingLocationActivated => 'Lokasi pengajaran diaktifkan.';

  @override
  String get teachingLocationDeactivated => 'Lokasi pengajaran dinonaktifkan.';

  @override
  String get failedUpdateTeachingLocationStatus =>
      'Gagal memperbarui status lokasi pengajaran.';

  @override
  String get studentLocation => 'Lokasi Binaan';

  @override
  String get selectStudentLocation => 'Pilih lokasi siswa';

  @override
  String get selectStudentLocationRequired => 'Silakan pilih lokasi siswa.';

  @override
  String get createTeachingLocationBeforeStudents =>
      'Buat lokasi pengajaran sebelum menambahkan siswa.';

  @override
  String get deceased => 'Almarhum';

  @override
  String get parentDeceased => 'Orang tua sudah almarhum';

  @override
  String get parentDeceasedHelp =>
      'Digunakan untuk mengidentifikasi status yatim, piatu, atau yatim piatu.';

  @override
  String get atLeastOneGuardianRequired => 'Minimal satu wali wajib diisi.';

  @override
  String get onlyOnePrimaryGuardianPermitted =>
      'Hanya satu wali utama yang diperbolehkan.';

  @override
  String get teachers => 'Pengajar';

  @override
  String get specialNotes => 'Catatan Khusus';

  @override
  String get specialNotesDescription =>
      'Riwayat interview, survey, kunjungan rumah, atau observasi management.';

  @override
  String get addSpecialNote => 'Tambah Catatan';

  @override
  String get loadingSpecialNotes => 'Memuat catatan khusus...';

  @override
  String get failedLoadSpecialNotes => 'Gagal memuat catatan khusus.';

  @override
  String get noSpecialNotes => 'Belum ada catatan khusus management.';

  @override
  String get addedBy => 'Ditambahkan Oleh';

  @override
  String get archiveNote => 'Archive catatan';

  @override
  String get archiveSpecialNoteTitle => 'Archive catatan khusus?';

  @override
  String get archiveSpecialNoteMessage =>
      'Catatan ini akan disembunyikan dari history aktif dan tidak dipakai dalam Student Story.';

  @override
  String get specialNoteArchived => 'Catatan khusus berhasil di-archive.';

  @override
  String get failedArchiveSpecialNote => 'Gagal archive catatan khusus.';

  @override
  String get addSpecialNoteTitle => 'Tambah Catatan Khusus';

  @override
  String get noteDate => 'Tanggal Catatan';

  @override
  String get noteType => 'Tipe Catatan';

  @override
  String get specialNote => 'Catatan Khusus';

  @override
  String get needsFollowUp => 'Perlu tindak lanjut';

  @override
  String get followUpNote => 'Catatan Tindak Lanjut';

  @override
  String get saveNote => 'Simpan Catatan';

  @override
  String get specialNoteRequired => 'Catatan khusus wajib diisi.';

  @override
  String get followUpNoteRequired =>
      'Catatan tindak lanjut wajib diisi jika tindak lanjut ditandai.';

  @override
  String get specialNoteSaved => 'Catatan khusus berhasil disimpan.';

  @override
  String get failedSaveSpecialNote => 'Gagal menyimpan catatan khusus.';

  @override
  String get noFollowUpMarked => 'Tidak ada tindak lanjut';

  @override
  String get specialNoteTypeInterview => 'Interview';

  @override
  String get specialNoteTypeParentSurvey => 'Survey Orang Tua';

  @override
  String get specialNoteTypeStudentSurvey => 'Survey Siswa';

  @override
  String get specialNoteTypeHomeVisit => 'Kunjungan Rumah';

  @override
  String get specialNoteTypeManagementObservation => 'Observasi Management';

  @override
  String get specialNoteTypeOther => 'Lainnya';

  @override
  String get studentStoryReportTitle => 'Cerita Siswa & Laporan Perkembangan';

  @override
  String get studentStoryExecutiveSummary => 'Ringkasan Utama';

  @override
  String get downloadPdf => 'Unduh PDF';

  @override
  String get studentStoryLoadFailed => 'Student Story gagal dimuat';

  @override
  String get generatingStudentStory => 'Membuat cerita siswa terbaru';

  @override
  String get generatingStudentStoryDescription =>
      'Mengambil profil, keluarga, nilai, kehadiran, catatan guru, dan data bantuan terbaru.';

  @override
  String get dataCompleteness => 'Kelengkapan Data';

  @override
  String get documentNo => 'Nomor Dokumen';

  @override
  String get generatedBy => 'Dibuat Oleh';

  @override
  String get parentGuardian => 'Orang Tua / Wali';

  @override
  String get nameSignature => 'Nama / Tanda Tangan';

  @override
  String get generated => 'Dibuat';

  @override
  String get studentStoryPdfDisclaimer =>
      'Catatan: Report ini merangkum data observasi dan administrasi yang tercatat di Edukita. Report tidak menambahkan diagnosis atau fakta di luar data aplikasi.';

  @override
  String get studentStoryDefaultDraftNote => 'Draft dari daftar cepat';

  @override
  String get studentStoryDefaultGeneratedNote =>
      'Dibuat dari data siswa terbaru';

  @override
  String get reportVersionNoteTitle => 'Catatan versi report';

  @override
  String get versionNote => 'Catatan versi';

  @override
  String get versionNoteHint =>
      'Contoh: Review bulanan, draft untuk pertemuan orang tua';

  @override
  String get reportDataIncompleteTitle => 'Data report belum lengkap';

  @override
  String get reportDataIncompleteMessage =>
      'PDF tetap bisa dibuat, tetapi sebaiknya dipakai sebagai draft sampai data siswa lengkap.';

  @override
  String get downloadDraftPdf => 'Unduh Draft PDF';

  @override
  String confirmActionForSubject(Object action, Object subject) {
    return '$action $subject?';
  }
}
