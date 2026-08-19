import 'package:layrz_sdk/layrz_sdk.dart';
import 'package:layrz_ui/layrz_ui.dart';

/// Extends the SDK's [Avatar] class to provide model conversion to layrz_ui.
extension LayrzAvatarSourceConverterX on Avatar? {
  /// Converts this SDK [Avatar] into layrz_ui's [LayrzAvatarSource].
  ///
  /// Returns the appropriate [LayrzAvatarSource] subtype based on the avatar's
  /// [type] and payload:
  /// - [AvatarType.url] → [LayrzAvatarUrl] (if [url] is set)
  /// - [AvatarType.base64] → [LayrzAvatarBase64] (if [base64] is set)
  /// - [AvatarType.icon] → [LayrzAvatarIcon] (if [icon] is set and has [iconData])
  /// - [AvatarType.emoji] → [LayrzAvatarEmoji] (if [emoji] is set)
  /// - [AvatarType.none] → `null`
  /// - `null` receiver → `null`
  /// - Any type/payload mismatch (e.g. type is URL but no URL is set) → `null`
  ///
  /// A null result is equivalent to no avatar and triggers the fallback behavior
  /// (displaying initials) in [LayrzAvatar]. This applies to:
  /// - A `null` avatar receiver
  /// - [AvatarType.none]
  /// - A type/payload mismatch where the expected field is null or empty
  ///
  /// Example usage:
  /// ```dart
  /// final sdkAvatar = Avatar(type: AvatarType.emoji, emoji: '🎉');
  /// final layrzSource = sdkAvatar.toLayrzUi();
  /// // layrzSource is LayrzAvatarEmoji('🎉')
  ///
  /// final emptyAvatar = Avatar(type: AvatarType.url, url: null);
  /// final nullSource = emptyAvatar.toLayrzUi();
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
        // Guard: icon field must be set; LayrzIcon.iconData converts to IconData
        if (self.icon != null) {
          return LayrzAvatarIcon(self.icon!.iconData);
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
