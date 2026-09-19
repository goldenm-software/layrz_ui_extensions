import 'package:layrz_sdk/layrz_sdk.dart';
import 'package:layrz_ui/layrz_ui.dart';

/// Bridges the SDK's [Connection] thresholds into layrz_ui's
/// [LayrzConnectionTimes], the config type [LayrzConnectionIndicator] reads
/// to resolve its 5-state connectivity band.
extension LayrzConnectionTimesConverterX on Connection? {
  /// Converts this SDK [Connection] into a [LayrzConnectionTimes].
  ///
  /// [Connection.online] and [Connection.hibernation] map to
  /// [LayrzConnectionTimes.online] and [LayrzConnectionTimes.idle]
  /// respectively, falling back to [LayrzConnectionTimes.defaults] for either
  /// field when it is `null`. [LayrzConnectionTimes.offline] has no SDK
  /// counterpart on [Connection], so it always takes the default value.
  ///
  /// Returns `null` if the receiver is `null`.
  LayrzConnectionTimes? get toUi {
    if (this == null) return null;
    final defaults = LayrzConnectionTimes.defaults();
    return LayrzConnectionTimes(
      online: this!.online ?? defaults.online,
      idle: this!.hibernation ?? defaults.idle,
      offline: defaults.offline,
    );
  }
}
