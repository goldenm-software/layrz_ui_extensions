import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layrz_sdk/layrz_sdk.dart';
import 'package:layrz_ui/layrz_ui.dart';
import 'package:layrz_ui_extensions/layrz_ui_extensions.dart';

void main() {
  group('LayrzAvatarSourceConverterX.toLayrzUi()', () {
    // ===== AvatarType.url Tests =====
    group('AvatarType.url', () {
      test('returns LayrzAvatarUrl when url is set', () {
        const avatar = Avatar(
          type: AvatarType.url,
          url: 'https://example.com/avatar.jpg',
        );

        final result = avatar.toLayrzUi();

        expect(result, isA<LayrzAvatarUrl>());
        expect(
          (result as LayrzAvatarUrl).url,
          'https://example.com/avatar.jpg',
        );
      });

      test('returns null when url is null', () {
        const avatar = Avatar(type: AvatarType.url, url: null);

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });

      test('returns null when url is empty string', () {
        const avatar = Avatar(type: AvatarType.url, url: '');

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });

      test('returns LayrzAvatarUrl for data URI', () {
        const dataUri = 'data:image/png;base64,iVBORw0KGgo';
        const avatar = Avatar(type: AvatarType.url, url: dataUri);

        final result = avatar.toLayrzUi();

        expect(result, isA<LayrzAvatarUrl>());
        expect((result as LayrzAvatarUrl).url, dataUri);
      });

      test('returns LayrzAvatarUrl for bare base64 string', () {
        const base64Url =
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
        const avatar = Avatar(type: AvatarType.url, url: base64Url);

        final result = avatar.toLayrzUi();

        expect(result, isA<LayrzAvatarUrl>());
        expect((result as LayrzAvatarUrl).url, base64Url);
      });
    });

    // ===== AvatarType.base64 Tests =====
    group('AvatarType.base64', () {
      test('returns LayrzAvatarBase64 when base64 is set', () {
        const base64Data = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ';
        const avatar = Avatar(type: AvatarType.base64, base64: base64Data);

        final result = avatar.toLayrzUi();

        expect(result, isA<LayrzAvatarBase64>());
        expect((result as LayrzAvatarBase64).base64, base64Data);
      });

      test('returns null when base64 is null', () {
        const avatar = Avatar(type: AvatarType.base64, base64: null);

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });

      test('returns null when base64 is empty string', () {
        const avatar = Avatar(type: AvatarType.base64, base64: '');

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });
    });

    // ===== AvatarType.icon Tests =====
    group('AvatarType.icon', () {
      test('returns LayrzAvatarIcon when icon is set', () {
        const icon = MdiRemapIcon(
          name: 'mdi-account',
          tags: ['user', 'profile'],
          data: MdiIcons.account,
        );
        const avatar = Avatar(type: AvatarType.icon, icon: icon);

        final result = avatar.toLayrzUi();

        expect(result, isA<LayrzAvatarIcon>());
        final layrzIcon = result as LayrzAvatarIcon;
        expect(layrzIcon.icon.codePoint, 983044);
        expect(layrzIcon.icon.fontFamily, 'Material Design Icons');
      });

      test('converts LayrzIcon.iconData correctly', () {
        const icon = MdiRemapIcon(
          name: 'mdi-account',
          tags: ['user', 'profile'],
          data: MdiIcons.account,
        );
        const avatar = Avatar(type: AvatarType.icon, icon: icon);

        final result = avatar.toLayrzUi() as LayrzAvatarIcon;
        final iconData = result.icon;

        expect(iconData.codePoint, 983044);
        expect(iconData.fontFamily, 'Material Design Icons');
      });

      test('returns null when icon is null', () {
        const avatar = Avatar(type: AvatarType.icon, icon: null);

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });
    });

    // ===== AvatarType.emoji Tests =====
    group('AvatarType.emoji', () {
      test('returns LayrzAvatarEmoji when emoji is set', () {
        const avatar = Avatar(type: AvatarType.emoji, emoji: '🎉');

        final result = avatar.toLayrzUi();

        expect(result, isA<LayrzAvatarEmoji>());
        expect((result as LayrzAvatarEmoji).emoji, '🎉');
      });

      test('handles multi-character emoji sequences', () {
        const avatar = Avatar(type: AvatarType.emoji, emoji: '👨‍👩‍👧‍👦');

        final result = avatar.toLayrzUi();

        expect(result, isA<LayrzAvatarEmoji>());
        expect((result as LayrzAvatarEmoji).emoji, '👨‍👩‍👧‍👦');
      });

      test('returns null when emoji is null', () {
        const avatar = Avatar(type: AvatarType.emoji, emoji: null);

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });

      test('returns null when emoji is empty string', () {
        const avatar = Avatar(type: AvatarType.emoji, emoji: '');

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });

      test('preserves various emoji types', () {
        const emojis = ['😀', '❤️', '🌟', '🚀', '🎯'];

        for (final emoji in emojis) {
          final avatar = Avatar(type: AvatarType.emoji, emoji: emoji);
          final result = avatar.toLayrzUi() as LayrzAvatarEmoji;
          expect(result.emoji, emoji);
        }
      });
    });

    // ===== AvatarType.none Tests =====
    group('AvatarType.none', () {
      test('returns null for AvatarType.none', () {
        const avatar = Avatar(type: AvatarType.none);

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });

      test('returns null for AvatarType.none with all fields null', () {
        const avatar = Avatar(
          type: AvatarType.none,
          emoji: null,
          icon: null,
          url: null,
          base64: null,
        );

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });
    });

    // ===== Null Receiver Tests =====
    group('null receiver', () {
      test('returns null when called on null Avatar', () {
        const Avatar? avatar = null;

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });
    });

    // ===== Type/Payload Mismatch Tests =====
    group('type/payload mismatch fallback', () {
      test('url type with missing url returns null', () {
        const avatar = Avatar(
          type: AvatarType.url,
          emoji: '🎉', // Wrong field set
          url: null,
        );

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });

      test('base64 type with missing base64 returns null', () {
        const avatar = Avatar(
          type: AvatarType.base64,
          emoji: '🎉', // Wrong field set
          base64: null,
        );

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });

      test('icon type with missing icon returns null', () {
        const avatar = Avatar(
          type: AvatarType.icon,
          emoji: '🎉', // Wrong field set
          icon: null,
        );

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });

      test('emoji type with missing emoji returns null', () {
        const avatar = Avatar(
          type: AvatarType.emoji,
          url: 'https://example.com/image.jpg', // Wrong field set
          emoji: null,
        );

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });

      test('url type with empty url returns null', () {
        const avatar = Avatar(
          type: AvatarType.url,
          url: '', // Empty is still a mismatch
        );

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });

      test('base64 type with empty base64 returns null', () {
        const avatar = Avatar(
          type: AvatarType.base64,
          base64: '', // Empty is still a mismatch
        );

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });

      test('emoji type with empty emoji returns null', () {
        const avatar = Avatar(
          type: AvatarType.emoji,
          emoji: '', // Empty is still a mismatch
        );

        final result = avatar.toLayrzUi();

        expect(result, isNull);
      });
    });

    // ===== Round-Trip and Identity Tests =====
    group('conversion identity and round-trip', () {
      test('URL conversion preserves original value', () {
        const original = 'https://example.com/user.jpg';
        const avatar = Avatar(type: AvatarType.url, url: original);

        final result = avatar.toLayrzUi() as LayrzAvatarUrl;

        expect(result.url, original);
      });

      test('base64 conversion preserves original value', () {
        const original = 'data:image/png;base64,iVBORw0KGgo=';
        const avatar = Avatar(type: AvatarType.base64, base64: original);

        final result = avatar.toLayrzUi() as LayrzAvatarBase64;

        expect(result.base64, original);
      });

      test('icon conversion preserves name and codePoint', () {
        const icon = MdiRemapIcon(
          name: 'mdi-account',
          tags: ['user', 'profile'],
          data: MdiIcons.account,
        );
        const avatar = Avatar(type: AvatarType.icon, icon: icon);

        final result = avatar.toLayrzUi() as LayrzAvatarIcon;

        // Note: we compare the converted IconData properties
        expect(result.icon.codePoint, icon.data.codePoint);
        expect(result.icon.fontFamily, 'Material Design Icons');
      });

      test('emoji conversion preserves original value', () {
        const original = '🌟';
        const avatar = Avatar(type: AvatarType.emoji, emoji: original);

        final result = avatar.toLayrzUi() as LayrzAvatarEmoji;

        expect(result.emoji, original);
      });
    });

    // ===== Type Narrowing Tests =====
    group('exhaustive switch type narrowing', () {
      test('all Avatar types handled without default', () {
        // This is a compile-time guarantee: if a new AvatarType is added,
        // the switch will not compile. This test documents the behavior.
        final avatars = [
          const Avatar(type: AvatarType.none),
          const Avatar(type: AvatarType.url, url: 'https://example.com'),
          const Avatar(type: AvatarType.base64, base64: 'base64data'),
          const Avatar(
            type: AvatarType.icon,
            icon: MdiRemapIcon(
              name: 'mdi-account',
              tags: ['user', 'profile'],
              data: MdiIcons.account,
            ),
          ),
          const Avatar(type: AvatarType.emoji, emoji: '🎉'),
        ];

        final expectedTypes = [
          null, // AvatarType.none
          LayrzAvatarUrl,
          LayrzAvatarBase64,
          LayrzAvatarIcon,
          LayrzAvatarEmoji,
        ];

        for (int i = 0; i < avatars.length; i++) {
          final avatar = avatars[i];
          final expected = expectedTypes[i];
          final result = avatar.toLayrzUi();

          if (expected == null) {
            expect(
              result,
              isNull,
              reason: 'Should handle ${avatar.type} and return null',
            );
          } else {
            expect(
              result,
              isA<LayrzAvatarSource>(),
              reason: 'Should handle ${avatar.type} without error',
            );
            expect(
              result.runtimeType,
              expected,
              reason: 'Should return $expected for ${avatar.type}',
            );
          }
        }
      });
    });
  });
}
