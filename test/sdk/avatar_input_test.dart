import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layrz_sdk/layrz_sdk.dart';
import 'package:layrz_ui/layrz_ui.dart';
import 'package:layrz_ui_extensions/layrz_ui_extensions.dart';

void main() {
  group('LayrzAvatarInputConverterX.toLayrzUi()', () {
    // ===== AvatarType.url Tests =====
    group('AvatarType.url', () {
      test('returns LayrzAvatarUrl when url is set', () {
        final input = AvatarInput(
          type: AvatarType.url,
          url: 'https://example.com/avatar.jpg',
        );

        final result = input.toLayrzUi();

        expect(result, isA<LayrzAvatarUrl>());
        expect(
          (result as LayrzAvatarUrl).url,
          'https://example.com/avatar.jpg',
        );
      });

      test('returns null when url is null', () {
        final input = AvatarInput(type: AvatarType.url, url: null);

        final result = input.toLayrzUi();

        expect(result, isNull);
      });

      test('returns null when url is empty string', () {
        final input = AvatarInput(type: AvatarType.url, url: '');

        final result = input.toLayrzUi();

        expect(result, isNull);
      });
    });

    // ===== AvatarType.base64 Tests =====
    group('AvatarType.base64', () {
      test('returns LayrzAvatarBase64 when base64 is set', () {
        const base64Data = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ';
        final input = AvatarInput(type: AvatarType.base64, base64: base64Data);

        final result = input.toLayrzUi();

        expect(result, isA<LayrzAvatarBase64>());
        expect((result as LayrzAvatarBase64).base64, base64Data);
      });

      test('returns null when base64 is null', () {
        final input = AvatarInput(type: AvatarType.base64, base64: null);

        final result = input.toLayrzUi();

        expect(result, isNull);
      });

      test('returns null when base64 is empty string', () {
        final input = AvatarInput(type: AvatarType.base64, base64: '');

        final result = input.toLayrzUi();

        expect(result, isNull);
      });
    });

    // ===== AvatarType.icon Tests =====
    group('AvatarType.icon', () {
      const icon = MdiRemapIcon(
        name: 'mdi-account',
        tags: ['user', 'profile'],
        data: MdiIcons.account,
      );

      test('returns LayrzAvatarIcon when icon is set', () {
        final input = AvatarInput(type: AvatarType.icon, icon: icon);

        final result = input.toLayrzUi();

        expect(result, isA<LayrzAvatarIcon>());
        final layrzIcon = result as LayrzAvatarIcon;
        expect(layrzIcon.icon.iconData.codePoint, 983044);
        expect(layrzIcon.icon.iconData.fontFamily, 'Material Design Icons');
      });

      test('returns null when icon is null', () {
        final input = AvatarInput(type: AvatarType.icon, icon: null);

        final result = input.toLayrzUi();

        expect(result, isNull);
      });
    });

    // ===== AvatarType.emoji Tests =====
    group('AvatarType.emoji', () {
      test('returns LayrzAvatarEmoji when emoji is set', () {
        final input = AvatarInput(type: AvatarType.emoji, emoji: '🎉');

        final result = input.toLayrzUi();

        expect(result, isA<LayrzAvatarEmoji>());
        expect((result as LayrzAvatarEmoji).emoji, '🎉');
      });

      test('returns null when emoji is null', () {
        final input = AvatarInput(type: AvatarType.emoji, emoji: null);

        final result = input.toLayrzUi();

        expect(result, isNull);
      });

      test('returns null when emoji is empty string', () {
        final input = AvatarInput(type: AvatarType.emoji, emoji: '');

        final result = input.toLayrzUi();

        expect(result, isNull);
      });
    });

    // ===== AvatarType.none Tests =====
    group('AvatarType.none', () {
      test('returns null for AvatarType.none', () {
        final input = AvatarInput();

        final result = input.toLayrzUi();

        expect(result, isNull);
      });

      test('returns null for AvatarType.none with all fields null', () {
        final input = AvatarInput(
          type: AvatarType.none,
          emoji: null,
          icon: null,
          url: null,
          base64: null,
        );

        final result = input.toLayrzUi();

        expect(result, isNull);
      });
    });

    // ===== Null Receiver Tests =====
    group('null receiver', () {
      test('returns null when called on null AvatarInput', () {
        const AvatarInput? input = null;

        final result = input.toLayrzUi();

        expect(result, isNull);
      });
    });

    // ===== Type/Payload Mismatch Tests =====
    group('type/payload mismatch fallback', () {
      test('url type with missing url returns null', () {
        final input = AvatarInput(
          type: AvatarType.url,
          emoji: '🎉', // Wrong field set
          url: null,
        );

        final result = input.toLayrzUi();

        expect(result, isNull);
      });

      test('base64 type with missing base64 returns null', () {
        final input = AvatarInput(
          type: AvatarType.base64,
          emoji: '🎉', // Wrong field set
          base64: null,
        );

        final result = input.toLayrzUi();

        expect(result, isNull);
      });

      test('icon type with missing icon returns null', () {
        final input = AvatarInput(
          type: AvatarType.icon,
          emoji: '🎉', // Wrong field set
          icon: null,
        );

        final result = input.toLayrzUi();

        expect(result, isNull);
      });

      test('emoji type with missing emoji returns null', () {
        final input = AvatarInput(
          type: AvatarType.emoji,
          url: 'https://example.com/image.jpg', // Wrong field set
          emoji: null,
        );

        final result = input.toLayrzUi();

        expect(result, isNull);
      });
    });
  });

  group('LayrzAvatarSourceToInputX.toAvatarInput()', () {
    test('null receiver returns AvatarInput with type none and no payload', () {
      const LayrzAvatarSource? source = null;

      final result = source.toAvatarInput();

      expect(result.type, AvatarType.none);
      expect(result.url, isNull);
      expect(result.base64, isNull);
      expect(result.icon, isNull);
      expect(result.emoji, isNull);
    });

    test(
      'LayrzAvatarUrl converts to AvatarInput with type url and url payload',
      () {
        const source = LayrzAvatarUrl('https://example.com/avatar.jpg');

        final result = source.toAvatarInput();

        expect(result.type, AvatarType.url);
        expect(result.url, 'https://example.com/avatar.jpg');
        expect(result.base64, isNull);
        expect(result.icon, isNull);
        expect(result.emoji, isNull);
      },
    );

    test('LayrzAvatarBase64 converts to AvatarInput with type base64 and base64 payload', () {
      const base64Data = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ';
      const source = LayrzAvatarBase64(base64Data);

      final result = source.toAvatarInput();

      expect(result.type, AvatarType.base64);
      expect(result.base64, base64Data);
      expect(result.url, isNull);
      expect(result.icon, isNull);
      expect(result.emoji, isNull);
    });

    test(
      'LayrzAvatarIcon converts to AvatarInput with type icon and icon payload',
      () {
        const icon = MdiRemapIcon(
          name: 'mdi-account',
          tags: ['user', 'profile'],
          data: MdiIcons.account,
        );
        const source = LayrzAvatarIcon(icon);

        final result = source.toAvatarInput();

        expect(result.type, AvatarType.icon);
        expect(result.icon, isNotNull);
        expect(result.icon!.iconData.codePoint, icon.iconData.codePoint);
        expect(result.icon!.iconData.fontFamily, 'Material Design Icons');
        expect(result.url, isNull);
        expect(result.base64, isNull);
        expect(result.emoji, isNull);
      },
    );

    test('LayrzAvatarEmoji converts to AvatarInput with type emoji and emoji payload', () {
      const source = LayrzAvatarEmoji('🎉');

      final result = source.toAvatarInput();

      expect(result.type, AvatarType.emoji);
      expect(result.emoji, '🎉');
      expect(result.url, isNull);
      expect(result.base64, isNull);
      expect(result.icon, isNull);
    });
  });

  group('round-trip conversion', () {
    test('LayrzAvatarUrl survives toAvatarInput -> toLayrzUi', () {
      const original = LayrzAvatarUrl('https://example.com/user.jpg');

      final result = original.toAvatarInput().toLayrzUi();

      expect(result, isA<LayrzAvatarUrl>());
      expect((result as LayrzAvatarUrl).url, original.url);
    });

    test('LayrzAvatarBase64 survives toAvatarInput -> toLayrzUi', () {
      const original = LayrzAvatarBase64('data:image/png;base64,iVBORw0KGgo=');

      final result = original.toAvatarInput().toLayrzUi();

      expect(result, isA<LayrzAvatarBase64>());
      expect((result as LayrzAvatarBase64).base64, original.base64);
    });

    test('LayrzAvatarIcon survives toAvatarInput -> toLayrzUi', () {
      const icon = MdiRemapIcon(
        name: 'mdi-account',
        tags: ['user', 'profile'],
        data: MdiIcons.account,
      );
      const original = LayrzAvatarIcon(icon);

      final result = original.toAvatarInput().toLayrzUi();

      expect(result, isA<LayrzAvatarIcon>());
      expect(
        (result as LayrzAvatarIcon).icon.iconData.codePoint,
        original.icon.iconData.codePoint,
      );
    });

    test('LayrzAvatarEmoji survives toAvatarInput -> toLayrzUi', () {
      const original = LayrzAvatarEmoji('🌟');

      final result = original.toAvatarInput().toLayrzUi();

      expect(result, isA<LayrzAvatarEmoji>());
      expect((result as LayrzAvatarEmoji).emoji, original.emoji);
    });

    test(
      'null LayrzAvatarSource survives toAvatarInput -> toLayrzUi as null',
      () {
        const LayrzAvatarSource? original = null;

        final result = original.toAvatarInput().toLayrzUi();

        expect(result, isNull);
      },
    );

    test('AvatarInput url preserves type and payload through toLayrzUi -> toAvatarInput', () {
      final original = AvatarInput(
        type: AvatarType.url,
        url: 'https://example.com/avatar.jpg',
      );

      final result = original.toLayrzUi().toAvatarInput();

      expect(result.type, AvatarType.url);
      expect(result.url, original.url);
    });

    test('AvatarInput base64 preserves type and payload through toLayrzUi -> toAvatarInput', () {
      final original = AvatarInput(
        type: AvatarType.base64,
        base64: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ',
      );

      final result = original.toLayrzUi().toAvatarInput();

      expect(result.type, AvatarType.base64);
      expect(result.base64, original.base64);
    });

    test('AvatarInput icon preserves type and payload through toLayrzUi -> toAvatarInput', () {
      const icon = MdiRemapIcon(
        name: 'mdi-account',
        tags: ['user', 'profile'],
        data: MdiIcons.account,
      );
      final original = AvatarInput(type: AvatarType.icon, icon: icon);

      final result = original.toLayrzUi().toAvatarInput();

      expect(result.type, AvatarType.icon);
      expect(result.icon!.iconData.codePoint, icon.iconData.codePoint);
    });

    test('AvatarInput emoji preserves type and payload through toLayrzUi -> toAvatarInput', () {
      final original = AvatarInput(type: AvatarType.emoji, emoji: '🎉');

      final result = original.toLayrzUi().toAvatarInput();

      expect(result.type, AvatarType.emoji);
      expect(result.emoji, original.emoji);
    });

    test(
      'AvatarInput none maps through toLayrzUi -> toAvatarInput back to none',
      () {
        final original = AvatarInput();

        final result = original.toLayrzUi().toAvatarInput();

        expect(result.type, AvatarType.none);
        expect(result.url, isNull);
        expect(result.base64, isNull);
        expect(result.icon, isNull);
        expect(result.emoji, isNull);
      },
    );
  });
}
