import 'package:layrz_i18n/layrz_i18n.dart';
import 'package:layrz_ui/layrz_ui.dart';

mixin LayrzUiI18nSheetsMixin on LayrzUiL10n {
  LayrzI18n get i18n;

  @override
  String get sheetsBarrierLabel => i18n.t('sheets.barrierLabel');
}
