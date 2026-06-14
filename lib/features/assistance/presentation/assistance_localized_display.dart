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

String translateAssistanceRuleType(
  BuildContext context,
  AssistanceRuleType type,
) {
  return switch (type) {
    AssistanceRuleType.fixedPriority => context.l10n.fixedPriority,
    AssistanceRuleType.needBased => context.l10n.needBased,
    AssistanceRuleType.meritBased => context.l10n.meritBased,
    AssistanceRuleType.growthBased => context.l10n.growthBased,
    AssistanceRuleType.specialCase => context.l10n.specialCase,
    AssistanceRuleType.teacherRecommendation =>
      context.l10n.teacherRecommendation,
    AssistanceRuleType.rollingAttendance => context.l10n.rollingAttendance,
    AssistanceRuleType.customRule => context.l10n.customRule,
    AssistanceRuleType.manualOverride => context.l10n.manualOverride,
    AssistanceRuleType.manualPriority => context.l10n.manualPriority,
    AssistanceRuleType.temporarySupport => context.l10n.temporarySupport,
    AssistanceRuleType.attendanceBased => context.l10n.attendanceBased,
  };
}

String translateAssistanceDecisionStatus(
  BuildContext context,
  AssistanceDecisionStatus status,
) {
  return switch (status) {
    AssistanceDecisionStatus.draft => context.l10n.draft,
    AssistanceDecisionStatus.approved => context.l10n.selected,
    AssistanceDecisionStatus.waitlist => context.l10n.waitlist,
    AssistanceDecisionStatus.rejected => context.l10n.rejected,
    AssistanceDecisionStatus.cancelled => context.l10n.cancelled,
  };
}

String translateAssistanceEligibilityStatus(
  BuildContext context,
  AssistanceEligibilityStatus status,
) {
  return switch (status) {
    AssistanceEligibilityStatus.pending => context.l10n.pending,
    AssistanceEligibilityStatus.eligible => context.l10n.eligible,
    AssistanceEligibilityStatus.ineligible => context.l10n.ineligible,
    AssistanceEligibilityStatus.overridden => context.l10n.overridden,
  };
}

String translateAssistanceRecipientStatus(
  BuildContext context,
  AssistanceRecipientStatus status,
) {
  return switch (status) {
    AssistanceRecipientStatus.approved => context.l10n.approved,
    AssistanceRecipientStatus.paid => context.l10n.statusPaid,
    AssistanceRecipientStatus.distributed => context.l10n.distributed,
    AssistanceRecipientStatus.cancelled => context.l10n.cancelled,
  };
}
