import 'package:layrz_i18n/layrz_i18n.dart';
import 'package:layrz_ui/layrz_ui.dart';

mixin LayrzUiI18nSteppersMixin on LayrzUiL10n {
  LayrzI18n get i18n;

  /// Localized text for the "Previous" / back button in a stepper.
  ///
  /// Default: "Back"
  @override
  String get steppersPreviousButtonLabel => i18n.t('steppers.previousButtonLabel');

  /// Localized text for the "Next" / forward button in a stepper.
  ///
  /// Default: "Next"
  @override
  String get steppersNextButtonLabel => i18n.t('steppers.nextButtonLabel');
}
