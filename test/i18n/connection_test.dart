import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layrz_i18n/layrz_i18n.dart';
import 'package:layrz_ui_extensions/layrz_ui_extensions.dart';

void main() {
  group('LayrzUiI18nConnectionMixin', () {
    late LayrzI18n engine;
    late LayrzUiI18n adapter;

    setUp(() {
      engine = LayrzI18n(languages: [], currentLocale: const Locale('en'));
      LayrzI18n.setDeveloperMode(true);
      adapter = LayrzUiI18n(i18n: engine);
    });

    tearDown(() {
      LayrzI18n.setDeveloperMode(false);
    });

    test('connectionStateOnline routes to connection.state.online', () {
      expect(adapter.connectionStateOnline, 'connection.state.online : {}');
    });

    test('connectionStateIdle routes to connection.state.idle', () {
      expect(adapter.connectionStateIdle, 'connection.state.idle : {}');
    });

    test('connectionStateOffline routes to connection.state.offline', () {
      expect(adapter.connectionStateOffline, 'connection.state.offline : {}');
    });

    test(
      'connectionStateDisconnected routes to connection.state.disconnected',
      () {
        expect(
          adapter.connectionStateDisconnected,
          'connection.state.disconnected : {}',
        );
      },
    );

    test('connectionStateNoData routes to connection.state.noData', () {
      expect(adapter.connectionStateNoData, 'connection.state.noData : {}');
    });

    test('connectionTimeAgoJustNow routes to connection.timeAgo.justNow', () {
      expect(
        adapter.connectionTimeAgoJustNow,
        'connection.timeAgo.justNow : {}',
      );
    });

    test(
      'connectionStateWithTimeAgo routes to connection.stateWithTimeAgo with '
      'state/timeAgo args',
      () {
        final result = adapter.connectionStateWithTimeAgo(
          'Connected',
          '5 minutes ago',
        );
        expect(
          result,
          'connection.stateWithTimeAgo : '
          '{"state":"Connected","timeAgo":"5 minutes ago"}',
        );
      },
    );

    test(
      'connectionTimeAgo routes to connection.timeAgo.value with value arg',
      () {
        final result = adapter.connectionTimeAgo('5 minutes');
        expect(
          result,
          'connection.timeAgo.value : {"value":"5 minutes"}',
        );
      },
    );
  });
}
