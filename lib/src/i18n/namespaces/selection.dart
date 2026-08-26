import 'package:layrz_i18n/layrz_i18n.dart';
import 'package:layrz_ui/layrz_ui.dart';

/// Selection toolbar namespace.
mixin LayrzUiI18nSelectionMixin on LayrzUiL10n {
  LayrzI18n get i18n;
  @override
  String get selectionCopy => i18n.t('selection.copy');

  @override
  String get selectionCut => i18n.t('selection.cut');

  @override
  String get selectionPaste => i18n.t('selection.paste');

  @override
  String get selectionSelectAll => i18n.t('selection.selectAll');
}
