import 'package:flutter_test/flutter_test.dart';
import 'package:layrz_ui_extensions/layrz_ui_extensions.dart';

void main() {
  group('NotoSansFont', () {
    test('name matches the engine family used by the text styles', () {
      const font = NotoSansFont();
      expect(font.name, 'Noto Sans');
    });

    test(
      'registerOnWeb completes without throwing on the native (VM) target',
      () async {
        // On native targets `registerWebFont` resolves to the no-op stub (there is no DOM
        // to register a @font-face with), so the realistic assertion here is only that the
        // call completes cleanly — a browser FontFace cannot be observed under the VM
        // test runner.
        const font = NotoSansFont();
        await expectLater(font.registerOnWeb(), completes);
      },
    );

    test('kLayrzFontNotoSans exposes a NotoSansFont instance', () {
      expect(kLayrzFontNotoSans, isA<NotoSansFont>());
      expect(kLayrzFontNotoSans.name, 'Noto Sans');
    });
  });
}
