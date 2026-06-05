import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/assistance/plans/data/assistance_plan_models.dart';
import 'package:edukita/features/assistance/programs/data/assistance_program_model.dart';
import 'package:flutter/widgets.dart';

String translateAssistanceCategory(
  BuildContext context,
  AssistanceProgramCategory category,
) {
  return switch (category) {
    AssistanceProgramCategory.education => context.l10n.categoryEducation,
    AssistanceProgramCategory.seasonal => context.l10n.categorySeasonal,
    AssistanceProgramCategory.uniform => context.l10n.categoryUniform,
    AssistanceProgramCategory.transport => context.l10n.categoryTransport,
    AssistanceProgramCategory.food => context.l10n.categoryFood,
    AssistanceProgramCategory.emergency => context.l10n.categoryEmergency,
    AssistanceProgramCategory.health => context.l10n.categoryHealth,
    AssistanceProgramCategory.other => context.l10n.categoryOther,
  };
}

String translateAssistanceBenefitType(
  BuildContext context,
  AssistanceBenefitType type,
) {
  return switch (type) {
    AssistanceBenefitType.cash => context.l10n.benefitCash,
    AssistanceBenefitType.goods => context.l10n.benefitGoods,
    AssistanceBenefitType.voucher => context.l10n.benefitVoucher,
    AssistanceBenefitType.service => context.l10n.benefitService,
    AssistanceBenefitType.mixed => context.l10n.benefitMixed,
  };
}

String translateAssistanceFrequency(
  BuildContext context,
  AssistanceFrequency frequency,
) {
  return switch (frequency) {
    AssistanceFrequency.monthly => context.l10n.frequencyMonthly,
    AssistanceFrequency.yearly => context.l10n.frequencyYearly,
    AssistanceFrequency.seasonal => context.l10n.frequencySeasonal,
    AssistanceFrequency.oneTime => context.l10n.frequencyOneTime,
    AssistanceFrequency.asNeeded => context.l10n.frequencyAsNeeded,
  };
}

String translateAssistanceSchoolType(
  BuildContext context,
  AssistanceBenefitSchoolType schoolType,
) {
  return switch (schoolType) {
    AssistanceBenefitSchoolType.all => context.l10n.schoolTypeAll,
    AssistanceBenefitSchoolType.univ => context.l10n.schoolTypeUniversity,
    _ => schoolType.label,
  };
}

String translateAssistancePeriodStatus(
  BuildContext context,
  AssistancePeriodStatus status,
) {
  return switch (status) {
    AssistancePeriodStatus.draft => context.l10n.draft,
    AssistancePeriodStatus.targeted => context.l10n.targeted,
    AssistancePeriodStatus.submitted => context.l10n.submitted,
    AssistancePeriodStatus.approved => context.l10n.approved,
    AssistancePeriodStatus.rejected => context.l10n.rejected,
    AssistancePeriodStatus.distributed => context.l10n.distributed,
    AssistancePeriodStatus.cancelled => context.l10n.cancelled,
  };
}

String translateAssistanceSelectionMode(
  BuildContext context,
  AssistanceSelectionMode mode,
) {
  return switch (mode) {
    AssistanceSelectionMode.manual => context.l10n.manual,
    AssistanceSelectionMode.auto => context.l10n.auto,
  };
}
