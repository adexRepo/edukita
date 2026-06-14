import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/presentation/class_form_dialog.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  @override
  void initState() {
    super.initState();
    context.read<ClassCubit>().loadClasses();
  }

  Future<void> _showClassFormDialog(
    BuildContext context, {
    SchoolClass? existingClass,
  }) async {
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'class_form_${existingClass?.id ?? 'new'}',
      builder: (context) => ClassFormDialog(
        schoolClass: existingClass,
        onSave: (schoolClass) async {
          final cubit = context.read<ClassCubit>();
          if (existingClass != null) {
            await cubit.updateClass(schoolClass);
          } else {
            await cubit.addClass(schoolClass);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final cubit = context.read<ClassCubit>();
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_class_$id',
      builder: (context) {
        return AlertDialog(
          title: AppDialogTitle(context.l10n.deleteClass),
          content: Text(context.l10n.deleteClassConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.buttonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await cubit.deleteClass(id);
        AppToast.showSubmissionSuccess(
          action: SubmissionAction.delete,
          subject: 'class',
        );
      } catch (_) {
        AppToast.showSubmissionFailed(
          action: SubmissionAction.delete,
          subject: 'class',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassCubit, ClassState>(
      builder: (context, state) {
        if (state.error != null) {
          return Center(
            child: Text(context.l10n.errorWithDetails(state.error!)),
          );
        } else {
          final classes = state.classes;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                context.l10n.classes,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showClassFormDialog(context),
                ),
              ],
            ),
            body: Column(
              children: [
                AppLoadingStrip(isLoading: state.isLoading, topPadding: 0),
                Expanded(
                  child: classes.isEmpty
                ? Center(child: Text(context.l10n.noClassesYet))
                : ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final schoolClass = classes[index];
                      final section = SchoolClass.normalizeSection(
                        schoolClass.section,
                      );
                      return ListTile(
                        title: Text(schoolClass.className),
                        subtitle: Text(
                          [
                            '${context.l10n.level} ${schoolClass.level}',
                            if (section != null)
                              '${context.l10n.section} $section',
                            '${context.l10n.year} ${schoolClass.year}',
                          ].join(' | '),
                        ),
                        onTap: () => {},
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showClassFormDialog(
                                context,
                                existingClass: schoolClass,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.error,
                              ),
                              onPressed: () =>
                                  _confirmDelete(context, schoolClass.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
