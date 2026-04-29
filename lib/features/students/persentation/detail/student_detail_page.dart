import 'dart:math' as math;

import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/core/helper/image_helper.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/attendance_line_chart.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentDetailPage extends StatefulWidget {
  final String studentId;
  const StudentDetailPage({super.key, required this.studentId});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentDetailCubit, FeatureState<StudentDetailData>>(
      builder: (context, state) {
        // 1. Loading (initial)
        if (state.loading && state.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Error state
        if (!state.loading && state.data == null) {
          return Center(child: Text(state.message ?? "Failed to load student"));
        }

        final student = state.data!;

        // 3. Success
        var boxDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        );
        return Scaffold(
          appBar: AppBar(title: const Text("Student Detail")),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  headerDetail(boxDecoration, student),
                  const SizedBox(height: 10),
                  studentInformationSection(boxDecoration, student),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  LayoutBuilder headerDetail(
    BoxDecoration boxDecoration,
    StudentDetailData student,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isNarrow = availableWidth < 520;
        final isMedium = availableWidth < 920;
        final cardHeight = (availableWidth * 0.24)
            .clamp(190.0, 260.0)
            .toDouble();
        final studentFlex = isMedium ? 2 : 1;
        final chartFlex = isMedium ? 4 : 3;

        return Container(
          decoration: boxDecoration,
          width: double.infinity,
          height: isNarrow ? 430 : cardHeight,
          child: isNarrow
              ? Column(
                  children: [
                    SizedBox(height: 165, child: studentInfoTile(student)),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE5E7EB),
                    ),
                    Expanded(child: AttendanceLineChart()),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: studentFlex,
                      child: studentInfoTile(student),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Color(0xFFE5E7EB),
                    ),
                    Expanded(flex: chartFlex, child: AttendanceLineChart()),
                  ],
                ),
        );
      },
    );
  }

  Widget studentInfoTile(StudentDetailData student) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final photoSize = math
              .min(constraints.maxWidth * 0.55, constraints.maxHeight * 0.58)
              .clamp(56.0, 120.0)
              .toDouble();

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(photoSize / 2),
                child: Image(
                  image: getImageByLocalPath(student.photoPath),
                  width: photoSize,
                  height: photoSize,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    student.nickName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${student.age} years',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget studentInformationSection(
    BoxDecoration boxDecoration,
    StudentDetailData student,
  ) {
    final items = [
      MapEntry('ID', student.id),
      MapEntry('Student No', student.studentNo),
      MapEntry('NIS', _textOrDash(student.nis)),
      MapEntry('Join At', student.joinAt),
      MapEntry('Gender', student.gender.name.toUpperCase()),
      MapEntry('Birth Date', student.birthDate),
      MapEntry('Class Name', student.className),
      MapEntry('School Name', student.schoolName),
      MapEntry('Mobile No', _textOrDash(student.mobileNo)),
      MapEntry('Email', _textOrDash(student.emailAddr)),
      MapEntry('Shoes Size', _numberOrDash(student.shoesSize)),
      MapEntry('Uniform Size', _numberOrDash(student.uniformSize)),
      MapEntry('Pants Size', _numberOrDash(student.pantsSize)),
      MapEntry('Height', _decimalOrDash(student.height, suffix: ' cm')),
      MapEntry('Weight', _decimalOrDash(student.weight, suffix: ' kg')),
      MapEntry('Status', student.status.name.toUpperCase()),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: boxDecoration.copyWith(color: Colors.white),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          var columnCount = 1;
          if (width >= 1100) {
            columnCount = 4;
          } else if (width >= 760) {
            columnCount = 3;
          } else if (width >= 520) {
            columnCount = 2;
          }
          const spacing = 10.0;
          final itemWidth =
              (width - (spacing * (columnCount - 1))) / columnCount;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Student Information',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: spacing,
                runSpacing: 8,
                children: items
                    .map(
                      (item) => SizedBox(
                        width: itemWidth,
                        child: _studentInfoItem(item.key, item.value),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _studentInfoItem(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _textOrDash(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value;
  }

  String _numberOrDash(num? value) {
    return value?.toString() ?? '-';
  }

  String _decimalOrDash(double? value, {required String suffix}) {
    if (value == null) {
      return '-';
    }
    return '${value.toStringAsFixed(1)}$suffix';
  }

  Widget parentInfoCard({
    required String name,
    required String role, // e.g. MOTHER
    required String job,
    required String phone,
    required String whatsapp,
    required String email,
    required Gender gender,
    String? imagePath,
  }) {
    Widget buildRow(String label, String value, IconData icon) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 76,
              child: Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 11))),
            Icon(icon, size: 14, color: Colors.grey[500]),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Gender.male == gender
            ? AppColors.primaryLight.withValues(alpha: 0.1)
            : AppColors.error.withValues(
                alpha: 0.1,
              ), // soft background like design
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image(
                  image: getImageByLocalPath(imagePath),
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.verified, size: 14, color: Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      job,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Role badge
              Text(
                role.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 4),

          // Info rows
          buildRow("Phone", phone, Icons.phone_outlined),
          buildRow("WhatsApp", whatsapp, Icons.chat_bubble_outline),
          buildRow("E-Mail", email, Icons.copy_outlined),
        ],
      ),
    );
  }
}

// class _StudentDetailView extends StatelessWidget {
  // final StudentDetailData studentData;

  // const _StudentDetailView({required this.studentData});

  // @override
  // Widget build(BuildContext context) {
    // return
    // your design code here (no logic)
    // return Scaffold(
    //   body: SingleChildScrollView(
    //     padding: const EdgeInsets.all(20),
    //     child: Column(
    //       children: [
    //         Container(
    //           width: double.infinity,
    //           height: 400,
    //           padding: const EdgeInsets.only(bottom: 20),
    //           child: _buildCardProfile(student: studentData),
    //         ),
    //         Container(
    //           color: Colors.amber,
    //           width: double.infinity,
    //           child: Text(
    //             "data\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasadata\nsasasa",
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
//   }

//   Widget _buildSection(List<Widget> children) {
//     return Wrap(spacing: 1, runSpacing: 2, children: children);
//   }

//   Widget _item(String label, dynamic value, {bool fullWidth = false}) {
//     return Container(
//       color: Colors.amber,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 1,
//             child: Text(
//               label,
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 12, color: Colors.black87),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCardProfile({required StudentDetailData student}) {
//     return ClayCard(
//       boxBorder: Border.all(color: const Color(0xFFE5E7EB)),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 1,

//             child: Column(
//               children: [
//                 const Align(
//                   alignment: Alignment.topLeft,
//                   child: Text(
//                     "STUDENT",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 CircleAvatar(
//                   radius: 45,
//                   backgroundColor: Colors.grey.shade200,
//                   backgroundImage: getImageByLocalPath(student.photoPath),
//                   child: student.photoPath == null || student.photoPath!.isEmpty
//                       ? Text(
//                           student.fullName.isNotEmpty
//                               ? student.fullName[0].toUpperCase()
//                               : '?',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         )
//                       : null,
//                 ),

//                 const SizedBox(height: 12),

//                 Text(
//                   student.nickName,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 4),

//                 Text(
//                   "${student.fullName} class",
//                   style: const TextStyle(color: Colors.grey),
//                 ),

//                 const SizedBox(height: 12),

//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE9E7FF),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     student.className,
//                     style: const TextStyle(
//                       color: Color(0xFF5B5FC7),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           const VerticalDivider(
//             width: 1,
//             thickness: 1,
//             color: Color(0xFFE5E7EB),
//           ),
//           const SizedBox(width: 12),

//           Expanded(
//             flex: 2,
//             child: Column(
//               children: [
//                 const Align(
//                   alignment: Alignment.topLeft,
//                   child: Text(
//                     "Detail information",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildSection([
//                   _item("Nick name", studentData.nickName),
//                   _item("Full name", studentData.fullName),
//                 ]),
//                 _buildSection([
//                   _item("Nick name", studentData.nickName),
//                   _item("Full name", studentData.fullName),
//                   _item("Gender", studentData.gender.name),
//                   _item("Join At", studentData.joinAt),
//                   _item("Student ID", studentData.studentNo),
//                   _item("NIS", studentData.nis ?? "-"),
//                   _item("Class Name", studentData.className),
//                   _item("School", studentData.schoolName),
//                   _item("Birth date", studentData.birthDate),
//                   _item("Mobile no", studentData.mobileNo ?? "-"),
//                   _item("Email", studentData.emailAddr ?? "-"),
//                   _item("Height", studentData.height?.toString() ?? "-"),
//                   _item("Weight", studentData.weight?.toString() ?? "-"),
//                   _item("Shoes size", studentData.shoesSize?.toString() ?? "-"),
//                   _item(
//                     "Uniform size",
//                     studentData.uniformSize?.toString() ?? "-",
//                   ),
//                   _item("Pants size", studentData.pantsSize?.toString() ?? "-"),
//                   _item("Address", studentData.joinAt),
//                 ]),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
