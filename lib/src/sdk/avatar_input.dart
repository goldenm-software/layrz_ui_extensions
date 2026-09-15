import 'package:layrz_sdk/layrz_sdk.dart';
import 'package:layrz_ui/layrz_ui.dart';

/// Extends the SDK's [AvatarInput] class to provide model conversion to layrz_ui.
///
/// This is the write-model counterpart to [LayrzAvatarSourceConverterX.toLayrzUi]
/// (defined on [Avatar] in `avatar.dart`): [AvatarInput] is the mutable payload
/// sent back to the API when editing an avatar, while [Avatar] is the read-only
/// value returned by it.
extension LayrzAvatarInputConverterX on AvatarInput? {
  /// Converts this SDK [AvatarInput] into layrz_ui's [LayrzAvatarSource].
  ///
  /// Returns the appropriate [LayrzAvatarSource] subtype based on the input's
  /// [type] and payload:
  /// - [AvatarType.url] → [LayrzAvatarUrl] (if [url] is set)
  /// - [AvatarType.base64] → [LayrzAvatarBase64] (if [base64] is set)
  /// - [AvatarType.icon] → [LayrzAvatarIcon] (if [icon] is set)
  /// - [AvatarType.emoji] → [LayrzAvatarEmoji] (if [emoji] is set)
  /// - [AvatarType.none] → `null`
  /// - `null` receiver → `null`
  /// - Any type/payload mismatch (e.g. type is URL but no URL is set) → `null`
  ///
  /// A null result is equivalent to no avatar and triggers the fallback behavior
  /// (displaying initials) in [LayrzAvatar]. This applies to:
  /// - A `null` [AvatarInput] receiver
  /// - [AvatarType.none]
  /// - A type/payload mismatch where the expected field is null or empty
  ///
  /// Example usage:
  /// ```dart
  /// final input = AvatarInput(type: AvatarType.emoji, emoji: '🎉');
  /// final layrzSource = input.toLayrzUi();
  /// // layrzSource is LayrzAvatarEmoji('🎉')
  ///
  /// final emptyInput = AvatarInput(type: AvatarType.url, url: null);
  /// final nullSource = emptyInput.toLayrzUi();
  /// // nullSource is null (type/payload mismatch fallback)
  /// ```
  LayrzAvatarSource? toLayrzUi() {
    // Null receiver → null result
    if (this == null) return null;

    final self = this!;

    // Exhaustive switch over AvatarType to ensure every value is handled.
    // Adding a new AvatarType will produce a compile error here.
    switch (self.type) {
      case AvatarType.url:
        // Guard: url field must be set and non-empty
        if (self.url != null && self.url!.isNotEmpty) {
          return LayrzAvatarUrl(self.url!);
        }
        return null;

      case AvatarType.base64:
        // Guard: base64 field must be set and non-empty
        if (self.base64 != null && self.base64!.isNotEmpty) {
          return LayrzAvatarBase64(self.base64!);
        }
        return null;

      case AvatarType.icon:
        // Guard: icon field must be set; the MdiRemapIcon passes through unchanged
        if (self.icon != null) {
          return LayrzAvatarIcon(self.icon!);
        }
        return null;

      case AvatarType.emoji:
        // Guard: emoji field must be set and non-empty
        if (self.emoji != null && self.emoji!.isNotEmpty) {
          return LayrzAvatarEmoji(self.emoji!);
        }
        return null;

      case AvatarType.none:
        // Explicit no-avatar marker → null
        return null;
    }
  }
}

/// Extends layrz_ui's [LayrzAvatarSource] to provide model conversion back to
/// the SDK's [AvatarInput].
///
/// This is the reverse of [LayrzAvatarInputConverterX.toLayrzUi] above, and is
/// intended for consuming the value produced by `LayrzDynamicAvatarInput` (the
/// layrz_ui widget that lets a user choose an avatar source) and turning it back
/// into the write-model payload the API expects.
extension LayrzAvatarSourceToInputX on LayrzAvatarSource? {
  /// Converts this [LayrzAvatarSource] into the SDK's [AvatarInput].
  ///
  /// Returns an [AvatarInput] with the [AvatarType] and payload field matching
  /// the concrete [LayrzAvatarSource] subtype:
  /// - `null` → `AvatarInput()` (defaults to [AvatarType.none] with every
  ///   payload field left `null`)
  /// - [LayrzAvatarUrl] → `AvatarInput(type: AvatarType.url, url: ...)`
  /// - [LayrzAvatarBase64] → `AvatarInput(type: AvatarType.base64, base64: ...)`
  /// - [LayrzAvatarIcon] → `AvatarInput(type: AvatarType.icon, icon: ...)`
  /// - [LayrzAvatarEmoji] → `AvatarInput(type: AvatarType.emoji, emoji: ...)`
  ///
  /// Example usage:
  /// ```dart
  /// const source = LayrzAvatarEmoji('🎉');
  /// final input = source.toAvatarInput();
  /// // input is AvatarInput(type: AvatarType.emoji, emoji: '🎉')
  ///
  /// const LayrzAvatarSource? emptySource = null;
  /// final noneInput = emptySource.toAvatarInput();
  /// // noneInput is AvatarInput(type: AvatarType.none)
  /// ```
  AvatarInput toAvatarInput() {
    return switch (this) {
      null => AvatarInput(),
      LayrzAvatarUrl(:final url) => AvatarInput(type: AvatarType.url, url: url),
      LayrzAvatarBase64(:final base64) => AvatarInput(
        type: AvatarType.base64,
        base64: base64,
      ),
      LayrzAvatarIcon(:final icon) => AvatarInput(
        type: AvatarType.icon,
        icon: icon,
      ),
      LayrzAvatarEmoji(:final emoji) => AvatarInput(
        type: AvatarType.emoji,
        emoji: emoji,
      ),
    };
  }
}
