import 'package:layrz_i18n/layrz_i18n.dart';
import 'package:layrz_ui/layrz_ui.dart';

/// Routes the Connection namespace to the i18n engine.
mixin LayrzUiI18nConnectionMixin on LayrzUiL10n {
  /// The translation engine. Abstract here; supplied by [LayrzUiI18n].
  LayrzI18n get i18n;

  @override
  String get connectionStateOnline => i18n.t('connection.state.online');

  @override
  String get connectionStateIdle => i18n.t('connection.state.idle');

  @override
  String get connectionStateOffline => i18n.t('connection.state.offline');

  @override
  String get connectionStateDisconnected =>
      i18n.t('connection.state.disconnected');

  @override
  String get connectionStateNoData => i18n.t('connection.state.noData');

  @override
  String connectionStateWithTimeAgo(String stateLabel, String timeAgo) {
    return i18n.t('connection.stateWithTimeAgo', {
      'state': stateLabel,
      'timeAgo': timeAgo,
    });
  }

  @override
  String get connectionTimeAgoJustNow => i18n.t('connection.timeAgo.justNow');

  @override
  String connectionTimeAgo(String value) {
    return i18n.t('connection.timeAgo.value', {'value': value});
  }
}
