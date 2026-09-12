import 'package:flutter/widgets.dart';
import 'package:layrz_i18n/layrz_i18n.dart';

/// [LayrzOrm] is a static helper that stores field-level validation errors
/// reported by the Layrz ORM/backend and translates them into human-readable
/// strings.
///
/// Unlike `layrz_theme`'s `ThemedOrm`, this port is deliberately independent of
/// `layrz_ui`'s own localization surface (`LayrzUiL10n`/`LayrzUiI18n`). Instead,
/// translations are resolved directly from [LayrzI18n] (the `layrz_i18n`
/// package engine) when a [BuildContext] is supplied to [getErrors]. When no
/// context is available, [getErrors] falls back to an untranslated
/// representation of the error instead of throwing.
///
/// Errors are stored in a single static map keyed by field name, where each
/// value is a `List<dynamic>` of `Map<String, dynamic>` entries. Each entry
/// must contain an `error['code']` (`String`) key, and may contain additional
/// parameters used to interpolate the translated message (for example,
/// `minLength` errors carry a `min` value).
class LayrzOrm {
  /// The static store of raw errors, keyed by field name. Populate it via
  /// [setErrors]. Never mutate this map directly from outside this class.
  static Map<String, dynamic> _errors = {};

  /// Sets (or clears) the errors known to [LayrzOrm].
  ///
  /// Arguments:
  /// - [errors] is the new error map, keyed by field name. Passing `null`
  ///   clears the store entirely (equivalent to setting it to an empty map).
  static void setErrors(Map<String, dynamic>? errors) {
    _errors = errors ?? {};
  }

  /// Clears all stored validation errors.
  ///
  /// Equivalent to [setErrors] with `null`. After this, [getErrors] returns an
  /// empty list for every key and [hasErrors]/[hasGroupedErrors] return false.
  static void clearErrors() {
    _errors = {};
  }

  /// Returns the translated list of errors for the given field [key].
  ///
  /// Arguments:
  /// - [key] is the field name to look up in the error store.
  /// - [context] is an optional [BuildContext] used to resolve a [LayrzI18n]
  ///   instance for translation. When omitted (or when no [LayrzI18n]
  ///   ancestor is found), each error falls back to an untranslated
  ///   representation instead of being translated.
  ///
  /// For `minLength`/`maxLength` codes, the fallback is a constructed string
  /// of the shape `"<code>:key=value:..."` built from the error map's
  /// non-`code` entries, and the translation (when available) is looked up at
  /// `"errors.<code>"` with the whole error map passed as interpolation args.
  /// For every other code, the fallback is the raw `error['code']`, and the
  /// translation (when available) is looked up at `"errors.<code>"` with no
  /// interpolation args.
  ///
  /// Returns:
  /// A `List<String>` of translated (or fallback) error messages. Never
  /// `null`; empty when [key] has no recorded errors.
  static List<String> getErrors(String key, {BuildContext? context}) {
    final List<dynamic> raw = _errors[key] ?? [];
    final List<String> errors = [];

    final LayrzI18n? i18n = context != null ? LayrzI18n.maybeOf(context) : null;

    for (final Map<String, dynamic> error in raw) {
      if (['minLength', 'maxLength'].contains(error['code'])) {
        String fallback = error['code'];
        error.forEach((key, value) {
          if (key != 'code') {
            fallback += ':$key=$value';
          }
        });

        final String msg =
            i18n?.t('errors.${error['code']}', error) ?? fallback;
        errors.add(msg);
      } else {
        final String msg = i18n?.t('errors.${error['code']}') ?? error['code'];
        errors.add(msg);
      }
    }

    return errors;
  }

  /// Returns `true` when the given field [key] currently has one or more
  /// recorded errors.
  ///
  /// Arguments:
  /// - [key] is the field name to look up in the error store.
  ///
  /// Translation is irrelevant to emptiness (a key with only fallback/raw-code
  /// strings is still non-empty), so no [BuildContext] is required.
  static bool hasErrors(String key) {
    return getErrors(key).isNotEmpty;
  }

  /// Returns `true` when any field name in [keys] has one or more recorded
  /// errors.
  ///
  /// Arguments:
  /// - [keys] is the list of field names to check.
  ///
  /// This does not perform prefix matching against the error store's keys;
  /// it strictly checks each of [keys] individually via [hasErrors].
  static bool hasGroupedErrors(List<String> keys) {
    return keys.any((k) => hasErrors(k));
  }
}

/// Convenience [BuildContext] extension exposing [LayrzOrm]'s static methods
/// without requiring callers to reference the class explicitly.
///
/// [getErrors] flows `this` through as the translation context, so errors
/// translate via [LayrzI18n] whenever an ancestor is available.
extension LayrzOrmExtension on BuildContext {
  /// Sets (or clears) the errors known to [LayrzOrm].
  ///
  /// Arguments:
  /// - [errors] is the new error map, keyed by field name. Passing `null`
  ///   clears the store entirely.
  void setErrors(Map<String, dynamic>? errors) => LayrzOrm.setErrors(errors);

  /// Clears all stored validation errors. See [LayrzOrm.clearErrors].
  void clearErrors() => LayrzOrm.clearErrors();

  /// Returns the translated list of errors for the given field [key],
  /// resolving translations against this context's [LayrzI18n] ancestor.
  ///
  /// Arguments:
  /// - [key] is the field name to look up in the error store.
  List<String> getErrors(String key) => LayrzOrm.getErrors(key, context: this);

  /// Returns `true` when the given field [key] currently has one or more
  /// recorded errors.
  ///
  /// Arguments:
  /// - [key] is the field name to look up in the error store.
  bool hasErrors(String key) => LayrzOrm.hasErrors(key);

  /// Returns `true` when any field name in [keys] has one or more recorded
  /// errors.
  ///
  /// Arguments:
  /// - [keys] is the list of field names to check.
  bool hasGroupedErrors(List<String> keys) => LayrzOrm.hasGroupedErrors(keys);
}
