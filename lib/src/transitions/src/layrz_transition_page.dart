import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:layrz_ui/layrz_ui.dart';

/// A [CustomTransitionPage] pre-wired with one of `layrz_ui`'s
/// [LayrzPageTransitions] builders, so a go_router caller no longer has to
/// repeat the `transitionsBuilder` / `transitionDuration` boilerplate on
/// every route.
///
/// `layrz_ui` intentionally ships its page transitions as bare
/// [LayrzTransitionBuilder] functions rather than as a go_router type,
/// because the design system has exactly three dependencies and must not
/// take on `go_router` as a fourth. `layrz_ui_extensions` is allowed to
/// depend on `go_router`, so this class is the natural home for the missing
/// convenience layer — see the package README's "Page transitions" section
/// for the before/after this class is meant to replace.
///
/// ### Usage
///
/// Prefer the named constructors when the transition is chosen at the call
/// site:
///
/// ```dart
/// GoRoute(
///   path: '/detail',
///   pageBuilder: (context, state) => LayrzTransitionPage.slide(
///     key: state.pageKey,
///     child: const DetailPage(),
///   ),
/// );
/// ```
///
/// Use the unnamed constructor with [type] when the transition is instead
/// held as a runtime value — for example, a single app-wide setting a user
/// can change:
///
/// ```dart
/// GoRoute(
///   path: '/detail',
///   pageBuilder: (context, state) => LayrzTransitionPage(
///     type: settings.transitionType,
///     key: state.pageKey,
///     child: const DetailPage(),
///   ),
/// );
/// ```
///
/// ### Why the type parameter is preserved
///
/// [CustomTransitionPage] is generic over `T`, the type a route resolves to
/// when popped with a result (`Navigator.pop<T>(context, result)`). This
/// class preserves that generic rather than erasing it to `Object`, so a
/// route pushed with `context.push<T>(...)` and later popped with a typed
/// result still type-checks all the way through.
///
/// ### How the transition duration is resolved
///
/// [CustomTransitionPage.transitionDuration] is a plain field read eagerly
/// by go_router's underlying [PageRoute] — it is fixed at the moment this
/// page is constructed, unlike [transitionsBuilder], which is a callback
/// invoked later with a live [BuildContext]. That means the design system's
/// token-based duration (`LayrzPageTransitions.durationOf`, which requires a
/// [BuildContext] positioned under an installed [LayrzTheme]) cannot be
/// resolved lazily inside the builder the way the transition *widget* is —
/// it must be resolved right here, at construction time, from whatever
/// context the caller has on hand.
///
/// go_router's own `GoRoute.pageBuilder: (context, state) => ...` always
/// hands back exactly such a context: it is produced from inside the
/// [Navigator] that `LayrzApp.router`'s `builder` installs [LayrzTheme]
/// above, so it is always themed in a normal app. Passing that context as
/// [context] resolves the real token value
/// (`LayrzMotionTokens.dPageTransition`, 250ms by default). When [context]
/// is omitted, or when no [LayrzTheme] ancestor is found above it (for
/// example, a page constructed in a test with no app theme installed), this
/// class falls back to the raw [kPageTransitionDuration] constant rather
/// than throwing — the same 250ms value the token would have resolved to
/// under a default theme, just read directly instead of through
/// [BuildContext.dependOnInheritedWidgetOfExactType].
///
/// A caller who already knows the exact duration it wants — for instance to
/// intentionally deviate from the design system's default — can bypass both
/// paths by passing [transitionDuration] explicitly.
class LayrzTransitionPage<T> extends CustomTransitionPage<T> {
  /// Creates a [CustomTransitionPage] using the [LayrzPageTransitions]
  /// builder matching [type].
  ///
  /// [type] selects which [LayrzPageTransitions] static builder is used via
  /// [LayrzPageTransitions.resolve]. Prefer this constructor when the
  /// transition is chosen from a runtime value; prefer the named
  /// constructors ([LayrzTransitionPage.fade], [LayrzTransitionPage.slide],
  /// [LayrzTransitionPage.scale], [LayrzTransitionPage.rotation],
  /// [LayrzTransitionPage.none]) when it is a fixed choice at the call site.
  ///
  /// [child] is the page content, forwarded to
  /// [CustomTransitionPage.child].
  ///
  /// [context] is an optional [BuildContext], used once at construction time
  /// to resolve the design system's page-transition duration token via
  /// [LayrzPageTransitions.durationOf]. Pass the `context` argument of a
  /// go_router `pageBuilder` here. When omitted, or when no [LayrzTheme]
  /// ancestor is found above it, the raw [kPageTransitionDuration] constant
  /// is used instead. Ignored entirely when [transitionDuration] is
  /// explicitly provided.
  ///
  /// [transitionDuration] overrides the resolved duration outright, for a
  /// caller that wants a specific value regardless of [context] or the
  /// active theme. Defaults to the value resolved as described above.
  ///
  /// [reverseTransitionDuration] is the duration used when the route is
  /// popped. Defaults to [transitionDuration] so the transition runs at the
  /// same speed in both directions unless a caller deliberately asks for
  /// asymmetric timing.
  ///
  /// [key] is forwarded to [Page.key].
  /// [name] is forwarded to [Page.name].
  /// [arguments] is forwarded to [Page.arguments].
  /// [restorationId] is forwarded to [Page.restorationId].
  /// [maintainState] is forwarded to [CustomTransitionPage.maintainState].
  /// [fullscreenDialog] is forwarded to
  /// [CustomTransitionPage.fullscreenDialog].
  /// [opaque] is forwarded to [CustomTransitionPage.opaque].
  /// [barrierDismissible] is forwarded to
  /// [CustomTransitionPage.barrierDismissible].
  /// [barrierColor] is forwarded to [CustomTransitionPage.barrierColor].
  /// [barrierLabel] is forwarded to [CustomTransitionPage.barrierLabel].
  LayrzTransitionPage({
    required LayrzTransitionType type,
    required super.child,
    BuildContext? context,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    super.maintainState,
    super.fullscreenDialog,
    super.opaque,
    super.barrierDismissible,
    super.barrierColor,
    super.barrierLabel,
  }) : super(
         transitionsBuilder: LayrzPageTransitions.resolve(type),
         transitionDuration: transitionDuration ?? _resolveDuration(context),
         reverseTransitionDuration:
             reverseTransitionDuration ??
             transitionDuration ??
             _resolveDuration(context),
       );

  /// Creates a [LayrzTransitionPage] using [LayrzPageTransitions.fade].
  ///
  /// See the unnamed constructor for the meaning of every parameter; this
  /// constructor only fixes [type] to [LayrzTransitionType.fade].
  LayrzTransitionPage.fade({
    required Widget child,
    BuildContext? context,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool opaque = true,
    bool barrierDismissible = false,
    Color? barrierColor,
    String? barrierLabel,
  }) : this(
         type: LayrzTransitionType.fade,
         child: child,
         context: context,
         transitionDuration: transitionDuration,
         reverseTransitionDuration: reverseTransitionDuration,
         key: key,
         name: name,
         arguments: arguments,
         restorationId: restorationId,
         maintainState: maintainState,
         fullscreenDialog: fullscreenDialog,
         opaque: opaque,
         barrierDismissible: barrierDismissible,
         barrierColor: barrierColor,
         barrierLabel: barrierLabel,
       );

  /// Creates a [LayrzTransitionPage] using [LayrzPageTransitions.slide].
  ///
  /// See the unnamed constructor for the meaning of every parameter; this
  /// constructor only fixes [type] to [LayrzTransitionType.slide].
  LayrzTransitionPage.slide({
    required Widget child,
    BuildContext? context,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool opaque = true,
    bool barrierDismissible = false,
    Color? barrierColor,
    String? barrierLabel,
  }) : this(
         type: LayrzTransitionType.slide,
         child: child,
         context: context,
         transitionDuration: transitionDuration,
         reverseTransitionDuration: reverseTransitionDuration,
         key: key,
         name: name,
         arguments: arguments,
         restorationId: restorationId,
         maintainState: maintainState,
         fullscreenDialog: fullscreenDialog,
         opaque: opaque,
         barrierDismissible: barrierDismissible,
         barrierColor: barrierColor,
         barrierLabel: barrierLabel,
       );

  /// Creates a [LayrzTransitionPage] using [LayrzPageTransitions.scale].
  ///
  /// See the unnamed constructor for the meaning of every parameter; this
  /// constructor only fixes [type] to [LayrzTransitionType.scale].
  LayrzTransitionPage.scale({
    required Widget child,
    BuildContext? context,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool opaque = true,
    bool barrierDismissible = false,
    Color? barrierColor,
    String? barrierLabel,
  }) : this(
         type: LayrzTransitionType.scale,
         child: child,
         context: context,
         transitionDuration: transitionDuration,
         reverseTransitionDuration: reverseTransitionDuration,
         key: key,
         name: name,
         arguments: arguments,
         restorationId: restorationId,
         maintainState: maintainState,
         fullscreenDialog: fullscreenDialog,
         opaque: opaque,
         barrierDismissible: barrierDismissible,
         barrierColor: barrierColor,
         barrierLabel: barrierLabel,
       );

  /// Creates a [LayrzTransitionPage] using [LayrzPageTransitions.rotation].
  ///
  /// See the unnamed constructor for the meaning of every parameter; this
  /// constructor only fixes [type] to [LayrzTransitionType.rotation].
  LayrzTransitionPage.rotation({
    required Widget child,
    BuildContext? context,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool opaque = true,
    bool barrierDismissible = false,
    Color? barrierColor,
    String? barrierLabel,
  }) : this(
         type: LayrzTransitionType.rotation,
         child: child,
         context: context,
         transitionDuration: transitionDuration,
         reverseTransitionDuration: reverseTransitionDuration,
         key: key,
         name: name,
         arguments: arguments,
         restorationId: restorationId,
         maintainState: maintainState,
         fullscreenDialog: fullscreenDialog,
         opaque: opaque,
         barrierDismissible: barrierDismissible,
         barrierColor: barrierColor,
         barrierLabel: barrierLabel,
       );

  /// Creates a [LayrzTransitionPage] using [LayrzPageTransitions.none].
  ///
  /// See the unnamed constructor for the meaning of every parameter; this
  /// constructor only fixes [type] to [LayrzTransitionType.none]. Since
  /// [LayrzPageTransitions.none] renders instantly regardless of duration,
  /// [transitionDuration] and [reverseTransitionDuration] have no visible
  /// effect here, but are still accepted and forwarded for API symmetry with
  /// the other named constructors.
  LayrzTransitionPage.none({
    required Widget child,
    BuildContext? context,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool opaque = true,
    bool barrierDismissible = false,
    Color? barrierColor,
    String? barrierLabel,
  }) : this(
         type: LayrzTransitionType.none,
         child: child,
         context: context,
         transitionDuration: transitionDuration,
         reverseTransitionDuration: reverseTransitionDuration,
         key: key,
         name: name,
         arguments: arguments,
         restorationId: restorationId,
         maintainState: maintainState,
         fullscreenDialog: fullscreenDialog,
         opaque: opaque,
         barrierDismissible: barrierDismissible,
         barrierColor: barrierColor,
         barrierLabel: barrierLabel,
       );

  /// Resolves the design system's page-transition duration from [context].
  ///
  /// Returns [LayrzPageTransitions.durationOf] when [context] is non-null and
  /// has a [LayrzTheme] ancestor (checked via [LayrzTheme.maybeOf] first, so
  /// this never throws the way [LayrzTheme.of] would). Falls back to the raw
  /// [kPageTransitionDuration] constant — the same 250ms value the token
  /// resolves to under a default theme — in every other case: a `null`
  /// [context], or a [context] with no [LayrzTheme] above it.
  static Duration _resolveDuration(BuildContext? context) {
    if (context != null && LayrzTheme.maybeOf(context) != null) {
      return LayrzPageTransitions.durationOf(context);
    }
    return kPageTransitionDuration;
  }
}
