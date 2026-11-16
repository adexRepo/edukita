import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'dart:async';
import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/students/persentation/quick_student_form_dialog.dart';
import 'package:edukita/features/students/persentation/student_form_dialog.dart';
import 'package:edukita/features/students/persentation/students_page.dart';
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/widgets/multi_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'students_desktop_test.dart' as fixture;

final demoClass = SchoolClass(
  id: 'demo-class',
  name: 'Synthetic Class',
  level: 1,
  year: '2026',
  schoolId: 'demo-school',
);
final demoLocation = TeachingLocation(
  id: 'demo-location',
  code: 'SYN',
  name: 'Synthetic Teaching Location',
  address: 'Synthetic address',
);
final demoSchool = School(
  id: 'demo-school',
  name: 'Synthetic School',
  type: SchoolType.sd,
);
const demoStudent = Student(
  id: 'synthetic-a',
  studentId: 'SYN-A001',
  classId: 'demo-class',
  teachingLocationId: 'demo-location',
  fullName: 'Synthetic Student',
  joinAt: '2026-11-16',
  birthDate: '2016-01-01',
  gender: Gender.male,
  status: StudentStatus.active,
);
const demoGuardians = [
  StudentGuardianFormData(
    fullName: 'Synthetic Father',
    relationship: 'FATHER',
    isPrimary: true,
    isDeceased: false,
    income: 0,
    mobileNo: '081234567890',
  ),
  StudentGuardianFormData(
    fullName: 'Synthetic Mother',
    relationship: 'MOTHER',
    isDeceased: false,
    income: 0,
    mobileNo: '081234567891',
  ),
];
final filterField = FilterField(
  code: 'name',
  label: 'Synthetic full name field',
  inputType: FilterInputType.text,
);
Future<void> tapStudents(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Widget formHost(Widget form, {double scale = 1}) => fixture.studentsHost(
  Builder(
    builder: (context) => TextButton(
      onPressed: () => showDialog<void>(context: context, builder: (_) => form),
      child: const Text('Open form'),
    ),
  ),
  scale: scale,
);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final size in [const Size(800, 600), const Size(1280, 800)]) {
    for (final scale in [1.0, 1.25, 1.5, 2.0]) {
      testWidgets('Student filter, quick and full forms $size text $scale', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final forms = <Widget>[
          StudentFilterDialogV2(
            title: 'Student filters',
            field: filterField,
            fields: [filterField],
          ),
          QuickStudentFormDialog(
            availableClasses: [demoClass],
            availableTeachingLocations: [demoLocation],
            generatedStudentNo: 'SYN-001',
            onSubmit: (_, _) async {},
          ),
          StudentFormDialog(
            availableSchools: [demoSchool],
            availableClasses: [demoClass],
            availableTeachingLocations: [demoLocation],
            generatedStudentNo: 'SYN-001',
            initialStudent: demoStudent,
            initialGuardians: demoGuardians,
            initialAdvancedData: const StudentAdvancedFormData(
              householdProfile: StudentHouseholdProfileFormData(
                housingStatus: StudentHousingStatusOptions.owned,
                householdMemberCount: 4,
                homeAddress: "Synthetic address",
                dailySchoolTransportCost: 0,
                educationArrears: 0,
                fatherIncome: 0,
                motherIncome: 0,
              ),
            ),
            onSubmit: (_, _, _, _) async {},
          ),
        ];
        for (final form in forms) {
          await tester.pumpWidget(formHost(form, scale: scale));
          await tapStudents(tester, find.text('Open form'));
          fixture.noStudentLayoutErrors(tester);
          if (form is StudentFormDialog) {
            final tiles = tester
                .widgetList<ExpansionTile>(find.byType(ExpansionTile))
                .toList();
            for (final tile in tiles) {
              if (!tile.initiallyExpanded) {
                await tapStudents(tester, find.byWidget(tile));
                fixture.noStudentLayoutErrors(tester);
              }
            }
          }
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          fixture.noStudentLayoutErrors(tester);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        }
      });
    }
  }
  testWidgets(
    'Filter cancel preserves original; Done returns draft and fields remain labelled',
    (tester) async {
      final original = MultiFilterItem(
        fieldCode: 'name',
        label: 'Name',
        operator: FilterOperator.contains,
        value: 'Synthetic',
      );
      List<MultiFilterItem>? result;
      Widget host() => fixture.studentsHost(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showDialog<List<MultiFilterItem>>(
                context: context,
                builder: (_) => StudentFilterDialog(
                  title: 'Filters',
                  field: filterField,
                  fields: [filterField],
                  initialFilters: [original],
                ),
              );
            },
            child: const Text('Open filter'),
          ),
        ),
      );
      await tester.pumpWidget(host());
      await tapStudents(tester, find.text('Open filter'));
      await tapStudents(tester, find.text('Clear'));
      await tapStudents(tester, find.text('Cancel'));
      expect(result, isNull);
      expect(original.value, 'Synthetic');
      await tapStudents(tester, find.text('Open filter'));
      await tapStudents(tester, find.text('Done'));
      expect(result, hasLength(1));
      expect(result!.first.value, 'Synthetic');
      fixture.noStudentLayoutErrors(tester);
    },
  );
  for (final quick in [false, true]) {
    testWidgets(
      'Student save failure retains input and busy prevents duplicate/dismiss: quick=$quick',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 600));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var saves = 0;
        Completer<void>? pending;
        Future<void> save() async {
          saves++;
          if (saves == 1) throw Exception('Synthetic internal save failure');
          pending = Completer<void>();
          await pending!.future;
        }

        final form = quick
            ? QuickStudentFormDialog(
                availableClasses: [demoClass],
                availableTeachingLocations: [demoLocation],
                generatedStudentNo: 'SYN-001',
                onSubmit: (_, _) => save(),
              )
            : StudentFormDialog(
                availableSchools: [demoSchool],
                availableClasses: [demoClass],
                availableTeachingLocations: [demoLocation],
                generatedStudentNo: 'SYN-001',
                initialStudent: demoStudent,
                initialGuardians: demoGuardians,
                initialAdvancedData: const StudentAdvancedFormData(
                  householdProfile: StudentHouseholdProfileFormData(
                    housingStatus: StudentHousingStatusOptions.owned,
                    householdMemberCount: 4,
                    homeAddress: "Synthetic address",
                    dailySchoolTransportCost: 0,
                    educationArrears: 0,
                    fatherIncome: 0,
                    motherIncome: 0,
                  ),
                ),
                onSubmit: (_, _, _, _) => save(),
              );
        await tester.pumpWidget(formHost(form, scale: 2));
        await tapStudents(tester, find.text('Open form'));
        if (quick) {
          final name = find.byWidgetPredicate(
            (w) =>
                w is ShadInputFormField && w.controller != null && !w.readOnly,
          );
          await tester.ensureVisible(name);
          await tester.enterText(name, 'Synthetic Student');
          final classSelect = find.byType(ShadSelectFormField<String>).first;
          await tapStudents(
            tester,
            find.descendant(
              of: classSelect,
              matching: find.byType(ShadSelect<String>),
            ),
          );
          await tapStudents(tester, find.text(demoClass.className).last);
          final locationSelect = find.byType(ShadSelectFormField<String>).last;
          await tapStudents(
            tester,
            find.descendant(
              of: locationSelect,
              matching: find.byType(ShadSelect<String>),
            ),
          );
          await tapStudents(
            tester,
            find.textContaining(demoLocation.name).last,
          );
        }
        final nameField = find.byWidgetPredicate(
          (widget) =>
              widget is ShadInputFormField &&
              widget.controller?.text == 'Synthetic Student',
        );
        await tapStudents(
          tester,
          find.descendant(of: nameField, matching: find.byType(EditableText)),
        );
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();
        expect(saves, 1);
        expect(find.byType(Dialog), findsOneWidget);
        expect(find.text('Synthetic Student'), findsWidgets);
        expect(
          AppToast.instance.current!.message,
          contains('Your input has been kept.'),
        );
        final button = find.text(quick ? 'Save' : 'Update Student');
        await Scrollable.ensureVisible(tester.element(button));
        await tester.tap(button);
        await tester.pump();
        expect(saves, 2);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();
        expect(find.byType(Dialog), findsOneWidget);
        // The busy form deliberately absorbs pointer events.
        await tester.tap(button, warnIfMissed: false);
        await tester.pump();
        expect(saves, 2);
        pending!.complete();
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        fixture.noStudentLayoutErrors(tester);
        AppToast.instance.dismiss();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  }
}
