import 'package:layrz_i18n/layrz_i18n.dart';
import 'package:layrz_ui/layrz_ui.dart';

/// Combobox Input namespace.
mixin LayrzUiI18nComboboxMixin on LayrzUiL10n {
  /// The translation engine. Abstract here; supplied by [LayrzUiI18n].
  LayrzI18n get i18n;

  @override
  String get comboboxEmpty => i18n.t('combobox.empty');
}
