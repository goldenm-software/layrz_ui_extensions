# Changelog

## 0.0.3

### Added

- Fonts! We added support for `Inter`, `Noto Sans`, `Open Sans` and `Roboto` fonts for `layrz_ui` through our CDNs.
- Extended `LayrzUiI18n` to include new keys required on `layrz_ui 0.0.13`

## 0.0.2

**First release under the `layrz_ui_extensions` name, and the scope widens past i18n.**

### Added

- **`Avatar.toLayrzUi()`** — an extension on `layrz_sdk`'s `Avatar?` converting it to `layrz_ui`'s `LayrzAvatarSource` sealed hierarchy (`LayrzAvatarUrl`, `LayrzAvatarBase64`, `LayrzAvatarIcon`, `LayrzAvatarEmoji`). Declared on the **nullable** type, so a null avatar, `AvatarType.none`, and a type/payload mismatch all yield `null` — which is exactly how `LayrzAvatar` triggers its initials fallback. Callers write `LayrzAvatar(source: entity.avatar.toLayrzUi())` with no null check.

- **`layrz_sdk: ^4.4.3`** as a dependency, required by the avatar conversion.

### Changed

- **`layrz_ui` raised to `^0.0.9`** — the version that introduced `LayrzUiL10n`.

- **`lib/` restructured by concern.** The i18n binding moved to `lib/src/i18n/`, and the avatar conversion lives in `lib/src/sdk/`. The barrel `lib/layrz_ui_extensions.dart` exports both. Class names are unchanged — `LayrzUiI18n`, `LayrzUiI18nDelegate` and the 17 namespace mixins still describe the i18n concern; only the package grew broader.

### Design Notes

- **This package is why `layrz_ui` needs no `layrz_sdk` dependency.** `layrz_ui` defines its own `LayrzAvatarSource`; this package supplies the bridge. Apps holding SDK models convert at the boundary, and apps that do not never inherit the SDK's dependency tree.

- **Type and payload can disagree, and that is handled.** The SDK's `Avatar` carries a `type` alongside four independently-nullable payload fields, so `Avatar(type: AvatarType.url, url: null)` is representable. The conversion returns `null` in that case rather than throwing, matching how `layrz_ui` previously rendered such avatars as initials. Empty strings are treated the same as missing.

- **`layrz_icons` stays on 1.x.** `layrz_sdk 4.4.3` pins `layrz_icons: ^1.1.1`, and this package depends on both it and `layrz_ui`, so `layrz_ui` deliberately holds the same 1.x constraint. Raising either side alone would make this package unresolvable.

## 0.0.1

**Initial release.** An adapter binding `layrz_ui`'s `LayrzUiL10n` contract to the `layrz_i18n` translation engine.

### Added

- **`LayrzUiI18n`** — adapter implementing `LayrzUiL10n` by delegating all 133 keys through `LayrzI18n.t()` and `LayrzI18n.tc()`. Covers 17 namespaces: actions, about, calendar, date-time pickers, dual list, dynamic avatar, editor, files, helpers, map, notifications, password, required fields, select, table, taskbar, and weekdays. All keys are derived from the contract member names with a dotted prefix pattern (e.g., `actionCancel` → `'actions.cancel'`).

- **`LayrzUiI18nDelegate`** — a `LocalizationsDelegate<LayrzUiL10n>` that loads `LayrzUiI18n` instances. Typed over the contract base class `LayrzUiL10n` (not the subclass) to ensure `Localizations.of<LayrzUiL10n>()` correctly resolves this delegate. Must be registered before the default `LayrzUiL10nDelegate` in `LayrzApp.localizationsDelegates` to take precedence.

- Complete test coverage mirroring the adapter implementation across all 17 namespaces.

### Design Notes

- **Translation keys are derived, not verified.** The 133 dotted keys are generated from the contract member names and **have not been verified against real translation data** in the `layrz_i18n` engine. The implementation is correct; the key naming convention is derived and should be validated during integration.

- **Unresolved keys fall back gracefully.** Any key not present in the translation engine is handled by `layrz_i18n`'s fallback behavior. Missing keys will not break rendering; partial translation is fully supported.

- **English defaults are inherited.** When a key is not overridden, `LayrzUiI18n` inherits the English default from `LayrzUiL10n`. This allows the adapter to remain compatible with new keys added to `layrz_ui` without requiring immediate translation updates.

- **Pluralization support.** Eight duration-related keys use `tc(String key, int? val)` for singular/plural selection. These keys expect `' | '`-separated singular and plural forms in the translation engine (e.g., `'1 day | %count% days'`). The `tc()` call passes `val = 1` for singular, `val = count` for plural, and the engine selects the appropriate form.

- **No dependency between layrz_ui and layrz_i18n.** `layrz_ui` declares no dependency on `layrz_i18n`. This adapter exists to bridge the two, enabling both to remain independently published and versioned. The decoupling allows `layrz_ui` to be used standalone in apps that have no i18n requirement.

---

## Installation

Add both `layrz_ui` and `layrz_ui_extensions` to your `pubspec.yaml`:

```yaml
dependencies:
  layrz_ui: ^0.0.9
  layrz_ui_extensions: ^0.0.2
```

`layrz_ui_extensions` requires `layrz_ui >= 0.0.9` because that is where `LayrzUiL10n` was introduced. Both packages version independently.

## Usage

Register the delegate and initialize the engine:

```dart
import 'package:layrz_i18n/layrz_i18n.dart';
import 'package:layrz_ui/layrz_ui.dart';
import 'package:layrz_ui_extensions/layrz_ui_extensions.dart';

void main() async {
  final i18n = LayrzI18n(languages: [...]);
  await i18n.load();
  
  runApp(MyApp(i18n: i18n));
}

class MyApp extends StatelessWidget {
  final LayrzI18n i18n;
  const MyApp({required this.i18n});

  @override
  Widget build(BuildContext context) {
    return LayrzApp(
      title: 'My App',
      theme: LayrzThemeData.light(),
      localizationsDelegates: [
        LayrzUiI18nDelegate(i18n),      // Your translations
        const LayrzUiL10nDelegate(),    // English fallback
      ],
      home: const HomePage(),
    );
  }
}
```

Once registered, every `layrz_ui` component reading `context.l10n` automatically picks up your translations with no additional wiring.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
