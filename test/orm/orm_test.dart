import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layrz_i18n/layrz_i18n.dart';
import 'package:layrz_ui_extensions/layrz_ui_extensions.dart';

/// Builds a minimal widget tree that installs a real, loaded [LayrzI18n]
/// instance as a [Localizations] ancestor, so [LayrzOrm.getErrors] can
/// resolve translations exactly the way it would inside a real app.
///
/// [messages] seeds the `en` locale's translation table. [child] is wrapped
/// so its [BuildContext] can resolve [LayrzI18n] via `LayrzI18n.maybeOf`.
Widget _pumpedI18n({
  required Map<String, String> messages,
  required WidgetBuilder child,
}) {
  final language = AvailableLanguage(
    id: 'en',
    name: 'English',
    code: 'en',
    messages: messages,
  );

  return Localizations(
    locale: const Locale('en'),
    delegates: [
      LayrzI18nDelegate(
        languages: [language],
        supportedLocales: const [Locale('en')],
        fallbackLocale: const Locale('en'),
      ),
      DefaultWidgetsLocalizations.delegate,
    ],
    child: Builder(builder: child),
  );
}

void main() {
  setUp(() {
    // LayrzOrm is a static store; reset it before every test so tests are
    // order-independent.
    LayrzOrm.setErrors(null);
  });

  group('LayrzOrm.setErrors', () {
    test('null clears the store', () {
      LayrzOrm.setErrors({
        'name': [
          {'code': 'required'},
        ],
      });
      expect(LayrzOrm.hasErrors('name'), isTrue);

      LayrzOrm.setErrors(null);
      expect(LayrzOrm.hasErrors('name'), isFalse);
      expect(LayrzOrm.getErrors('name'), isEmpty);
    });

    test('sets the store to the given map', () {
      LayrzOrm.setErrors({
        'email': [
          {'code': 'invalid'},
        ],
      });
      expect(LayrzOrm.getErrors('email'), ['invalid']);
    });
  });

  group('LayrzOrm.clearErrors', () {
    test('empties the store', () {
      LayrzOrm.setErrors({
        'name': [
          {'code': 'required'},
        ],
        'email': [
          {'code': 'invalid'},
        ],
      });
      expect(LayrzOrm.hasErrors('name'), isTrue);

      LayrzOrm.clearErrors();
      expect(LayrzOrm.getErrors('name'), isEmpty);
      expect(LayrzOrm.hasErrors('name'), isFalse);
      expect(LayrzOrm.hasGroupedErrors(['name', 'email']), isFalse);
    });

    test('is a safe no-op on an already-empty store', () {
      expect(LayrzOrm.hasErrors('name'), isFalse);
      expect(() => LayrzOrm.clearErrors(), returnsNormally);
      expect(LayrzOrm.getErrors('name'), isEmpty);
    });
  });

  group('LayrzOrm.getErrors', () {
    test('unknown key returns an empty list', () {
      expect(LayrzOrm.getErrors('unknownKey'), isEmpty);
    });

    test('without context: normal code falls back to the raw code', () {
      LayrzOrm.setErrors({
        'email': [
          {'code': 'invalid'},
        ],
      });
      expect(LayrzOrm.getErrors('email'), ['invalid']);
    });

    test('without context: minLength falls back to a constructed string', () {
      LayrzOrm.setErrors({
        'password': [
          {'code': 'minLength', 'min': 5},
        ],
      });
      expect(LayrzOrm.getErrors('password'), ['minLength:min=5']);
    });

    test('without context: maxLength falls back to a constructed string', () {
      LayrzOrm.setErrors({
        'bio': [
          {'code': 'maxLength', 'max': 280},
        ],
      });
      expect(LayrzOrm.getErrors('bio'), ['maxLength:max=280']);
    });

    test(
      'without context: multiple errors for the same key are all returned',
      () {
        LayrzOrm.setErrors({
          'password': [
            {'code': 'required'},
            {'code': 'minLength', 'min': 8},
          ],
        });
        expect(LayrzOrm.getErrors('password'), [
          'required',
          'minLength:min=8',
        ]);
      },
    );

    test('does not throw when context is null', () {
      expect(() => LayrzOrm.getErrors('anything'), returnsNormally);
    });

    testWidgets('with context: normal code translates via LayrzI18n', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      LayrzOrm.setErrors({
        'email': [
          {'code': 'invalid'},
        ],
      });

      late BuildContext capturedContext;
      await tester.pumpWidget(
        _pumpedI18n(
          messages: {'errors.invalid': 'This field is invalid'},
          child: (context) {
            capturedContext = context;
            return const SizedBox();
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(LayrzOrm.getErrors('email', context: capturedContext), [
        'This field is invalid',
      ]);
    });

    testWidgets('with context: minLength translates with interpolated args', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      LayrzOrm.setErrors({
        'password': [
          {'code': 'minLength', 'min': 5},
        ],
      });

      late BuildContext capturedContext;
      await tester.pumpWidget(
        _pumpedI18n(
          messages: {'errors.minLength': 'Must be at least {min} characters'},
          child: (context) {
            capturedContext = context;
            return const SizedBox();
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(LayrzOrm.getErrors('password', context: capturedContext), [
        'Must be at least 5 characters',
      ]);
    });

    testWidgets(
      'with context: missing translation key falls through to fallback',
      (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        LayrzOrm.setErrors({
          'email': [
            {'code': 'unmapped_code'},
          ],
        });

        late BuildContext capturedContext;
        await tester.pumpWidget(
          _pumpedI18n(
            messages: const {},
            child: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(
          () => LayrzOrm.getErrors('email', context: capturedContext),
          returnsNormally,
        );
        // LayrzI18n.t returns a "Translation missing <key>" placeholder rather
        // than throwing when a key is absent, so the translated branch is still
        // taken (no fallback to the raw code in this case) — assert it does not
        // silently return the raw code, proving the context path was exercised.
        expect(
          LayrzOrm.getErrors('email', context: capturedContext).single,
          contains('errors.unmapped_code'),
        );
      },
    );
  });

  group('LayrzOrm.hasErrors', () {
    test('true when the key has errors', () {
      LayrzOrm.setErrors({
        'name': [
          {'code': 'required'},
        ],
      });
      expect(LayrzOrm.hasErrors('name'), isTrue);
    });

    test('false when the key has no errors', () {
      LayrzOrm.setErrors({
        'name': [
          {'code': 'required'},
        ],
      });
      expect(LayrzOrm.hasErrors('email'), isFalse);
    });
  });

  group('LayrzOrm.hasGroupedErrors', () {
    test('true when any key in the list has errors', () {
      LayrzOrm.setErrors({
        'b': [
          {'code': 'required'},
        ],
      });
      expect(LayrzOrm.hasGroupedErrors(['a', 'b']), isTrue);
    });

    test('false when none of the keys have errors', () {
      LayrzOrm.setErrors({
        'c': [
          {'code': 'required'},
        ],
      });
      expect(LayrzOrm.hasGroupedErrors(['a', 'b']), isFalse);
    });

    test('false for an empty key list', () {
      expect(LayrzOrm.hasGroupedErrors([]), isFalse);
    });
  });

  group('LayrzOrmExtension on BuildContext', () {
    testWidgets('setErrors delegates to LayrzOrm.setErrors', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      late BuildContext capturedContext;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      capturedContext.setErrors({
        'name': [
          {'code': 'required'},
        ],
      });
      expect(LayrzOrm.hasErrors('name'), isTrue);

      capturedContext.setErrors(null);
      expect(LayrzOrm.hasErrors('name'), isFalse);
    });

    testWidgets(
      'getErrors delegates to LayrzOrm.getErrors with this as context',
      (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        LayrzOrm.setErrors({
          'email': [
            {'code': 'invalid'},
          ],
        });

        late BuildContext capturedContext;
        await tester.pumpWidget(
          _pumpedI18n(
            messages: {'errors.invalid': 'Translated via extension'},
            child: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(capturedContext.getErrors('email'), [
          'Translated via extension',
        ]);
      },
    );

    testWidgets('hasErrors delegates to LayrzOrm.hasErrors', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      LayrzOrm.setErrors({
        'name': [
          {'code': 'required'},
        ],
      });

      late BuildContext capturedContext;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedContext.hasErrors('name'), isTrue);
      expect(capturedContext.hasErrors('email'), isFalse);
    });

    testWidgets('clearErrors delegates to LayrzOrm.clearErrors', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      LayrzOrm.setErrors({
        'name': [
          {'code': 'required'},
        ],
      });

      late BuildContext capturedContext;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedContext.hasErrors('name'), isTrue);

      capturedContext.clearErrors();
      expect(capturedContext.hasErrors('name'), isFalse);
      expect(LayrzOrm.getErrors('name'), isEmpty);
    });

    testWidgets('hasGroupedErrors delegates to LayrzOrm.hasGroupedErrors', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      LayrzOrm.setErrors({
        'b': [
          {'code': 'required'},
        ],
      });

      late BuildContext capturedContext;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedContext.hasGroupedErrors(['a', 'b']), isTrue);
      expect(capturedContext.hasGroupedErrors(['a', 'c']), isFalse);
    });
  });
}
