import 'package:layrz_sdk/layrz_sdk.dart';
import 'package:layrz_ui/layrz_ui.dart';

extension LayrzTimeOfDayConverterX on TimeOfDay? {
  /// Converts this SDK [TimeOfDay] into layrz_ui's [LayrzTimeOfDay].
  ///
  /// Returns `null` if the receiver is `null`.
  LayrzTimeOfDay? toLayrzUi() {
    if (this == null) return null;
    final self = this!;
    return LayrzTimeOfDay(hour: self.hour, minute: self.minute, second: self.second);
  }
}

extension TimeOfDayConverterX on LayrzTimeOfDay? {
  /// Converts this layrz_ui [LayrzTimeOfDay] into SDK's [TimeOfDay].
  ///
  /// Returns `null` if the receiver is `null`.
  TimeOfDay? toSdk() {
    if (this == null) return null;
    final self = this!;
    return TimeOfDay(hour: self.hour, minute: self.minute, second: self.second);
  }
}
