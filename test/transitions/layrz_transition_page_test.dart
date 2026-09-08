import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:layrz_ui/layrz_ui.dart';
import 'package:layrz_ui_extensions/layrz_ui_extensions.dart';

/// Builds a minimal themed widget tree — [LayrzApp.router] over a two-route
/// [GoRouter] — so tests can push a route built with [LayrzTransitionPage]
/// through a real [Navigator] and pump intermediate animation frames.
///
/// [firstPageBuilder] and [secondPageBuilder] build the pages for `/` and
/// `/second` respectively; the caller supplies these so each test can wrap
/// its page under test with whichever [LayrzTransitionPage] constructor it
/// wants to exercise.
GoRouter _buildRouter({
  required Page<void> Function(BuildContext, GoRouterState) firstPageBuilder,
  required Page<void> Function(BuildContext, GoRouterState) secondPageBuilder,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', pageBuilder: firstPageBuilder),
      GoRoute(path: '/second', pageBuilder: secondPageBuilder),
    ],
  );
}

/// Pumps [router] under a real [LayrzApp.router], so descendants can resolve
/// [LayrzTheme] the same way they would in a full app.
Widget _pumpedApp(GoRouter router) {
  return LayrzApp.router(routerConfig: router, theme: LayrzThemeData.light());
}

void main() {
  group('LayrzTransitionPage', () {
    setUp(() {
      // A 250ms fallback assumption is used throughout; keep the design
      // system's constant in view so a token change surfaces here too.
      expect(kPageTransitionDuration, const Duration(milliseconds: 250));
    });

    group('named constructors resolve the matching builder', () {
      test('.fade uses LayrzPageTransitions.fade', () {
        final page = LayrzTransitionPage.fade(child: const SizedBox());
        expect(page.transitionsBuilder, same(LayrzPageTransitions.fade));
      });

      test('.slide uses LayrzPageTransitions.slide', () {
        final page = LayrzTransitionPage.slide(child: const SizedBox());
        expect(page.transitionsBuilder, same(LayrzPageTransitions.slide));
      });

      test('.scale uses LayrzPageTransitions.scale', () {
        final page = LayrzTransitionPage.scale(child: const SizedBox());
        expect(page.transitionsBuilder, same(LayrzPageTransitions.scale));
      });

      test('.rotation uses LayrzPageTransitions.rotation', () {
        final page = LayrzTransitionPage.rotation(child: const SizedBox());
        expect(page.transitionsBuilder, same(LayrzPageTransitions.rotation));
      });

      test('.none uses LayrzPageTransitions.none', () {
        final page = LayrzTransitionPage.none(child: const SizedBox());
        expect(page.transitionsBuilder, same(LayrzPageTransitions.none));
      });

      test(
        'unnamed constructor resolves via type for every LayrzTransitionType',
        () {
          for (final type in LayrzTransitionType.values) {
            final page = LayrzTransitionPage(
              type: type,
              child: const SizedBox(),
            );
            expect(
              page.transitionsBuilder,
              same(LayrzPageTransitions.resolve(type)),
              reason: 'type: $type',
            );
          }
        },
      );
    });

    group('generic type preservation', () {
      test('unnamed constructor preserves <T>', () {
        final page = LayrzTransitionPage<int>(
          type: LayrzTransitionType.fade,
          child: const SizedBox(),
        );
        expect(page, isA<CustomTransitionPage<int>>());
      });

      test('named constructor preserves <T>', () {
        final page = LayrzTransitionPage<String>.slide(child: const SizedBox());
        expect(page, isA<CustomTransitionPage<String>>());
      });
    });

    group('forwarded parameters', () {
      test('reach the constructed CustomTransitionPage', () {
        const key = ValueKey('detail-page');
        const child = SizedBox(width: 10, height: 10);
        const barrierColor = Color(0xFF000000);

        final page = LayrzTransitionPage.fade(
          key: key,
          child: child,
          name: 'detail',
          arguments: {'id': 42},
          restorationId: 'detail-restoration',
          maintainState: false,
          fullscreenDialog: true,
          opaque: false,
          barrierDismissible: true,
          barrierColor: barrierColor,
          barrierLabel: 'detail-barrier',
          transitionDuration: const Duration(milliseconds: 400),
        );

        expect(page.key, key);
        expect(page.child, child);
        expect(page.name, 'detail');
        expect(page.arguments, {'id': 42});
        expect(page.restorationId, 'detail-restoration');
        expect(page.maintainState, isFalse);
        expect(page.fullscreenDialog, isTrue);
        expect(page.opaque, isFalse);
        expect(page.barrierDismissible, isTrue);
        expect(page.barrierColor, barrierColor);
        expect(page.barrierLabel, 'detail-barrier');
        expect(page.transitionDuration, const Duration(milliseconds: 400));
      });

      test(
        'unset boolean/opaque parameters keep CustomTransitionPage defaults',
        () {
          final page = LayrzTransitionPage.fade(child: const SizedBox());

          expect(page.maintainState, isTrue);
          expect(page.fullscreenDialog, isFalse);
          expect(page.opaque, isTrue);
          expect(page.barrierDismissible, isFalse);
          expect(page.barrierColor, isNull);
          expect(page.barrierLabel, isNull);
        },
      );
    });

    group('transitionDuration resolution', () {
      test('explicit transitionDuration wins over context resolution', () {
        final page = LayrzTransitionPage.fade(
          child: const SizedBox(),
          transitionDuration: const Duration(milliseconds: 999),
        );
        expect(page.transitionDuration, const Duration(milliseconds: 999));
      });

      test(
        'reverseTransitionDuration defaults to transitionDuration when unset',
        () {
          final page = LayrzTransitionPage.fade(
            child: const SizedBox(),
            transitionDuration: const Duration(milliseconds: 123),
          );
          expect(
            page.reverseTransitionDuration,
            const Duration(milliseconds: 123),
          );
        },
      );

      test('reverseTransitionDuration honors its own explicit override', () {
        final page = LayrzTransitionPage.fade(
          child: const SizedBox(),
          transitionDuration: const Duration(milliseconds: 123),
          reverseTransitionDuration: const Duration(milliseconds: 456),
        );
        expect(page.transitionDuration, const Duration(milliseconds: 123));
        expect(
          page.reverseTransitionDuration,
          const Duration(milliseconds: 456),
        );
      });

      test('falls back to kPageTransitionDuration when context is null', () {
        final page = LayrzTransitionPage.fade(child: const SizedBox());
        expect(page.transitionDuration, kPageTransitionDuration);
      });

      testWidgets(
        'falls back to kPageTransitionDuration when context has no LayrzTheme',
        (tester) async {
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

          final page = LayrzTransitionPage.fade(
            child: const SizedBox(),
            context: capturedContext,
          );
          expect(page.transitionDuration, kPageTransitionDuration);
        },
      );

      testWidgets(
        'resolves LayrzPageTransitions.durationOf(context) under a LayrzTheme',
        (tester) async {
          tester.view.physicalSize = const Size(1600, 1200);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          late BuildContext themedContext;

          await tester.pumpWidget(
            LayrzApp(
              theme: LayrzThemeData.light(),
              home: Builder(
                builder: (context) {
                  themedContext = context;
                  return const SizedBox();
                },
              ),
            ),
          );
          await tester.pumpAndSettle();

          final page = LayrzTransitionPage.fade(
            child: const SizedBox(),
            context: themedContext,
          );
          expect(
            page.transitionDuration,
            LayrzPageTransitions.durationOf(themedContext),
          );
          expect(page.transitionDuration, const Duration(milliseconds: 250));
        },
      );
    });

    group('animates through a real GoRouter push', () {
      testWidgets(
        'fade: transitionsBuilder actually runs, and an intermediate frame differs from both ends',
        (
          tester,
        ) async {
          tester.view.physicalSize = const Size(1600, 1200);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          final router = _buildRouter(
            firstPageBuilder: (context, state) => LayrzTransitionPage.fade(
              key: state.pageKey,
              context: context,
              child: const ColoredBox(
                color: Color(0xFFFF0000),
                child: SizedBox.expand(),
              ),
            ),
            secondPageBuilder: (context, state) => LayrzTransitionPage.fade(
              key: state.pageKey,
              context: context,
              child: const ColoredBox(
                color: Color(0xFF00FF00),
                child: SizedBox.expand(),
              ),
            ),
          );

          await tester.pumpWidget(_pumpedApp(router));
          await tester.pumpAndSettle();

          router.push('/second');
          await tester.pump();

          // Immediately after the push, the incoming page's FadeTransition
          // opacity animation has started but not completed.
          await tester.pump(const Duration(milliseconds: 125));

          final fadeTransitionFinder = find.byType(FadeTransition);
          expect(fadeTransitionFinder, findsWidgets);

          final opacities = tester
              .widgetList<FadeTransition>(fadeTransitionFinder)
              .map((widget) => widget.opacity.value)
              .toList();

          // At the midpoint, at least one FadeTransition must be mid-flight —
          // neither fully transparent nor fully opaque. A transition that does
          // nothing in between would leave every value at 0.0 or 1.0 here.
          expect(
            opacities.any((value) => value > 0.0 && value < 1.0),
            isTrue,
            reason:
                'expected an in-flight opacity value at the midpoint, got: $opacities',
          );

          await tester.pumpAndSettle();

          // Once settled, the second page is fully in and visually present.
          expect(find.byType(ColoredBox), findsWidgets);
        },
      );

      testWidgets(
        'slide: incoming page position animates from offscreen to Offset.zero',
        (tester) async {
          tester.view.physicalSize = const Size(1600, 1200);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          final router = _buildRouter(
            firstPageBuilder: (context, state) => LayrzTransitionPage.slide(
              key: state.pageKey,
              context: context,
              child: const SizedBox.expand(),
            ),
            secondPageBuilder: (context, state) => LayrzTransitionPage.slide(
              key: state.pageKey,
              context: context,
              child: const SizedBox.expand(),
            ),
          );

          await tester.pumpWidget(_pumpedApp(router));
          await tester.pumpAndSettle();

          router.push('/second');
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 125));

          final slideTransition = tester.widget<SlideTransition>(
            find.byType(SlideTransition).last,
          );
          final midpointOffset = slideTransition.position.value;

          // Midway through a rightward slide-in, the incoming page must be
          // strictly between its offscreen start and Offset.zero.
          expect(midpointOffset.dx, greaterThan(0.0));
          expect(midpointOffset.dx, lessThan(1.0));

          await tester.pumpAndSettle();
        },
      );

      testWidgets(
        'none: no animation runs and the incoming page appears without an intermediate state',
        (
          tester,
        ) async {
          tester.view.physicalSize = const Size(1600, 1200);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          final router = _buildRouter(
            firstPageBuilder: (context, state) => LayrzTransitionPage.none(
              key: state.pageKey,
              context: context,
              child: const ColoredBox(color: Color(0xFFFF0000)),
            ),
            secondPageBuilder: (context, state) => LayrzTransitionPage.none(
              key: state.pageKey,
              context: context,
              child: const ColoredBox(color: Color(0xFF00FF00)),
            ),
          );

          await tester.pumpWidget(_pumpedApp(router));
          await tester.pumpAndSettle();

          router.push('/second');
          // `.none` has a zero-duration transition, so no settling frames are
          // needed to reach the final page — only the two pumps every route
          // push needs regardless of transition: one to process the
          // navigation request, one to build the pushed page.
          await tester.pump();
          await tester.pump();

          final coloredBoxes = tester.widgetList<ColoredBox>(
            find.byType(ColoredBox),
          );
          expect(
            coloredBoxes.any((box) => box.color == const Color(0xFF00FF00)),
            isTrue,
          );
        },
      );
    });
  });
}
