import 'package:layrz_ui/layrz_ui.dart' as ui;
import 'package:layrz_sdk/layrz_sdk.dart' as sdk;

extension UiColorblindConverterX on ui.ColorblindMode {
  sdk.ColorblindMode toSdk(double strength) {
    switch (this) {
      case .protanopia:
        return sdk.ColorblindMode.protanopia;
      case .protanomaly:
        return sdk.ColorblindMode.protanomaly;
      case .deuteranopia:
        return sdk.ColorblindMode.deuteranopia;
      case .deuteranomaly:
        return sdk.ColorblindMode.deuteranomaly;
      case .tritanopia:
        return sdk.ColorblindMode.tritanopia;
      case .tritanomaly:
        return sdk.ColorblindMode.tritanomaly;
      case .normal:
        return sdk.ColorblindMode.normal;
    }
  }
}

extension SdkColorblindConverterX on sdk.ColorblindMode {
  ui.ColorblindMode toUi(double strength) {
    switch (this) {
      case sdk.ColorblindMode.protanopia:
        return ui.ColorblindMode.protanopia;
      case sdk.ColorblindMode.protanomaly:
        return ui.ColorblindMode.protanomaly;
      case sdk.ColorblindMode.deuteranopia:
        return ui.ColorblindMode.deuteranopia;
      case sdk.ColorblindMode.deuteranomaly:
        return ui.ColorblindMode.deuteranomaly;
      case sdk.ColorblindMode.tritanopia:
        return ui.ColorblindMode.tritanopia;
      case sdk.ColorblindMode.tritanomaly:
        return ui.ColorblindMode.tritanomaly;
      case sdk.ColorblindMode.normal:
        return ui.ColorblindMode.normal;
    }
  }
}
