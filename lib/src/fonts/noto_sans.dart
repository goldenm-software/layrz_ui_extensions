// Font family definitions for variable fonts hosted on the Layrz CDN.
//
// Four variable fonts are available via https://cdn.layrz.com/fonts/:
// - Roboto: A clean sans-serif with excellent readability
// - Open Sans: A friendly, open design optimized for web and print
// - Noto Sans: Google's multilingual sans-serif covering extensive Unicode ranges
// - Inter: A modern sans-serif designed for computer screens
//
// Each font supports a full `wght` (weight) axis and is available as a single
// .ttf variable font file. Use these definitions with LayrzCdnFontHandler
// to load fonts from the CDN with automatic caching and preload support.
//
// Example usage:
//   final handler = LayrzCdnFontHandler();
//   await handler.preload(kLayrzFontRoboto);

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:layrz_ui/layrz_ui.dart';
import 'package:http/http.dart' as http;

class NotoSansFont extends LayrzFont {
  const NotoSansFont() : super(name: 'Noto Sans');

  @override
  TextStyle get display => TextStyle(
    fontFamily: 'Noto Sans',
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800)],
  );

  @override
  TextStyle get headline => TextStyle(
    fontFamily: 'Noto Sans',
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  @override
  TextStyle get title => TextStyle(
    fontFamily: 'Noto Sans',
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
  );

  @override
  TextStyle get body => TextStyle(
    fontFamily: 'Noto Sans',
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
  );

  @override
  TextStyle get label => TextStyle(
    fontFamily: 'Noto Sans',
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
  );

  @override
  Future<void> load() async {
    final response = await http.get(
      Uri.parse('https://cdn.layrz.com/fonts/Noto-Sans.ttf'),
    );
    if (response.statusCode != 200) {
      Exception('Failed to load Noto Sans font from CDN');
    }

    final loader = FontLoader('Noto Sans');
    loader.addFont(Future.value(ByteData.view(response.bodyBytes.buffer)));
    await loader.load();
  }

  /// Registers the Noto Sans CDN font as a browser `@font-face`.
  ///
  /// [load] only makes the font available to the Flutter engine canvas; DOM-rendered
  /// content (such as native `<input>` elements) resolves CSS `font-family` against the
  /// browser's own font registry, which [load] never touches. This override registers
  /// the same CDN file there too, so DOM-rendered text on web also uses Noto Sans instead
  /// of silently falling back to a generic sans-serif.
  @override
  Future<void> registerOnWeb() async {
    await registerWebFont(
      family: name,
      url: 'https://cdn.layrz.com/fonts/Noto-Sans.ttf',
    );
  }
}

/// Noto Sans font from the Layrz CDN.
///
/// Google's comprehensive multilingual sans-serif covering extensive Unicode ranges.
/// Supports a full `wght` (weight) axis from 100 to 900.
/// Useful for applications requiring broad language support.
const LayrzFont kLayrzFontNotoSans = NotoSansFont();
