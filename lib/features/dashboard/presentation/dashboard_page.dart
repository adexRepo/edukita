import 'package:edukita/features/dashboard/domain/dashboard_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/step_process.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardStat>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          body: StepProcessCard(
            title: 'Create order',
            onClose: () {
              Navigator.pop(context);
            },
            onCompleted: () {
              debugPrint('Order completed');
            },
            steps: const [
              ProcessStepItem(title: 'Order Info', content: OrderInfoForm()),
              ProcessStepItem(
                title: 'Order quantity',
                content: OrderQuantityForm(),
              ),
              ProcessStepItem(title: 'Payment', content: PaymentForm()),
              ProcessStepItem(title: 'Location', content: LocationForm()),
            ],
          ),
        );

        // return Padding(
        //   padding: AppPageHeaderStyle.pagePadding,
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       // 🔹 Header
        //       const AppPageHeader(
        //         title: 'Dashboard',
        //         subtitle:
        //             'Overview of education management for the foundation.',
        //       ),

        //       const SizedBox(height: AppPageHeaderStyle.bottomGap),

        //       // 🔹 Grid Content
        //       Expanded(
        //         child: LayoutBuilder(
        //           builder: (context, constraints) {
        //             int crossAxisCount = 2;

        //             if (constraints.maxWidth > 1200) {
        //               crossAxisCount = 4;
        //             } else if (constraints.maxWidth > 800) {
        //               crossAxisCount = 3;
        //             }

        //             return GridView.count(
        //               crossAxisCount: crossAxisCount,
        //               crossAxisSpacing: 16,
        //               mainAxisSpacing: 16,
        //               childAspectRatio: 1.4,
        //               children: [
        //                 _StatCard(
        //                   label: 'Management',
        //                   value: 0,
        //                   icon: Icons.manage_accounts,
        //                   onTap: () => {},
        //                 ),
        //                 _StatCard(
        //                   label: 'Users',
        //                   value: state.userCount,
        //                   icon: Icons.person,
        //                   onTap: () => {},
        //                 ),
        //                 _StatCard(
        //                   label: 'Students',
        //                   value: state.studentCount,
        //                   icon: Icons.school,
        //                   onTap: () => {},
        //                 ),
        //                 _StatCard(
        //                   label: 'Curriculum',
        //                   value: state.syllabusCount,
        //                   icon: Icons.account_tree,
        //                   onTap: () => context.go('/curriculum'),
        //                 ),
        //                 _StatCard(
        //                   label: 'Strategy',
        //                   value: state.strategyCount,
        //                   icon: Icons.lightbulb,
        //                   onTap: () => context.go('/strategies'),
        //                 ),
        //                 _StatCard(
        //                   label: 'Schedule',
        //                   value: state.scheduleCount,
        //                   icon: Icons.schedule,
        //                   onTap: () => context.go('/schedules'),
        //                 ),
        //                 _StatCard(
        //                   label: 'Reports',
        //                   value: state.reportCount,
        //                   icon: Icons.bar_chart,
        //                   onTap: () => context.go('/reports'),
        //                 ),
        //               ],
        //             );
        //           },
        //         ),
        //       ),
        //     ],
        //   ),
        // );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 🔹 Value
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormTextField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? suffixIcon;
  final double minHeight;

  const _FormTextField({
    required this.label,
    required this.value,
    this.suffixIcon,
    this.minHeight = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: minHeight,
      child: TextFormField(
        initialValue: value,
        maxLines: minHeight > 60 ? null : 1,
        expands: minHeight > 60,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF061A40),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon == null
              ? null
              : Icon(suffixIcon, size: 20, color: const Color(0xFF9CA3AF)),
          labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.only(bottom: 8),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF059669), width: 1.4),
          ),
        ),
      ),
    );
  }
}

class OrderInfoForm extends StatelessWidget {
  const OrderInfoForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
              child: _FormTextField(
                label: 'Order name',
                value: 'Md. Shamsul Alam',
              ),
            ),
            SizedBox(width: 40),
            Expanded(
              child: _FormTextField(
                label: 'Priority',
                value: 'High',
                suffixIcon: Icons.keyboard_arrow_down,
              ),
            ),
          ],
        ),
        SizedBox(height: 18),
        Row(
          children: const [
            Expanded(
              child: _FormTextField(
                label: 'Delivery email',
                value: 'hello@fibo.studio',
              ),
            ),
            SizedBox(width: 40),
            Expanded(
              child: _FormTextField(
                label: 'Phone number',
                value: 'Md. Shamsul Alam',
              ),
            ),
          ],
        ),
        SizedBox(height: 18),
        Row(
          children: const [
            Expanded(
              child: _FormTextField(
                label: 'Delivery date',
                value: '1 March, 2023',
                suffixIcon: Icons.keyboard_arrow_down,
              ),
            ),
            SizedBox(width: 40),
            Expanded(
              child: _FormTextField(
                label: 'Delivery time',
                value: '8 March, 2023',
                suffixIcon: Icons.keyboard_arrow_down,
              ),
            ),
          ],
        ),
        SizedBox(height: 28),
        const _FormTextField(
          label: 'Task description',
          value: '',
          minHeight: 80,
        ),
      ],
    );
  }
}

class OrderQuantityForm extends StatelessWidget {
  const OrderQuantityForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 260,
      child: Center(child: Text('Order quantity form here')),
    );
  }
}

class PaymentForm extends StatelessWidget {
  const PaymentForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 260,
      child: Center(child: Text('Payment form here')),
    );
  }
}

class LocationForm extends StatelessWidget {
  const LocationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 360,
      child: Center(child: Text('Location form / map here')),
    );
  }
}
