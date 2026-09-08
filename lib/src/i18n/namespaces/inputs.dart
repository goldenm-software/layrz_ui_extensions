import 'package:layrz_i18n/layrz_i18n.dart';
import 'package:layrz_ui/layrz_ui.dart';

/// Inputs namespace — localized strings for input components and pickers.
mixin LayrzUiI18nInputsMixin on LayrzUiL10n {
  LayrzI18n get i18n;

  @override
  String get inputsSearchHint => i18n.t('helpers.search');

  @override
  String get inputsSearchClear => i18n.t('helpers.clear');

  @override
  String get durationUnitDaySingular => i18n.t('duration.unit.day.singular');

  @override
  String get durationUnitDayPlural => i18n.t('duration.unit.day.plural');

  @override
  String get durationUnitHourSingular => i18n.t('duration.unit.hour.singular');

  @override
  String get durationUnitHourPlural => i18n.t('duration.unit.hour.plural');

  @override
  String get durationUnitMinuteSingular =>
      i18n.t('duration.unit.minute.singular');

  @override
  String get durationUnitMinutePlural => i18n.t('duration.unit.minute.plural');

  @override
  String get durationUnitSecondSingular =>
      i18n.t('duration.unit.second.singular');

  @override
  String get durationUnitSecondPlural => i18n.t('duration.unit.second.plural');

  @override
  String get durationUnitDayShortSingular =>
      i18n.t('duration.unit.day.short.singular');

  @override
  String get durationUnitDayShortPlural =>
      i18n.t('duration.unit.day.short.plural');

  @override
  String get durationUnitHourShortSingular =>
      i18n.t('duration.unit.hour.short.singular');

  @override
  String get durationUnitHourShortPlural =>
      i18n.t('duration.unit.hour.short.plural');

  @override
  String get durationUnitMinuteShortSingular =>
      i18n.t('duration.unit.minute.short.singular');

  @override
  String get durationUnitMinuteShortPlural =>
      i18n.t('duration.unit.minute.short.plural');

  @override
  String get durationUnitSecondShortSingular =>
      i18n.t('duration.unit.second.short.singular');

  @override
  String get durationUnitSecondShortPlural =>
      i18n.t('duration.unit.second.short.plural');

  @override
  String get durationReset => i18n.t('duration.reset');

  @override
  String get durationFieldDay => i18n.t('duration.field.day');

  @override
  String get durationFieldHour => i18n.t('duration.field.hour');

  @override
  String get durationFieldMinute => i18n.t('duration.field.minute');

  @override
  String get durationFieldSecond => i18n.t('duration.field.second');

  @override
  String get inputsRequiredIndicator => i18n.t('inputs.requiredIndicator');

  @override
  String get inputsCharacterCountOf => i18n.t('inputs.characterCount.of');

  @override
  String get inputsCharacterCountCharacters =>
      i18n.t('inputs.characterCount.characters');

  @override
  String get inputsNumberIncrement => i18n.t('inputs.number.increment');

  @override
  String get inputsNumberDecrement => i18n.t('inputs.number.decrement');
}
