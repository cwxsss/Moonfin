import 'package:flutter/material.dart';

import '../../../util/idiom/app_ui_idiom.dart';

const String kCleanSettingsFontFamily = 'NotoSans';
const List<String> kChineseFontFallbacks = [
  'Microsoft YaHei',
  'PingFang SC',
  'Source Han Sans SC',
  'Noto Sans SC',
];

Widget withCleanSettingsTypography(BuildContext context, Widget child) {
  final theme = Theme.of(context);
  final apple = AppUiIdiomResolver.isApple;
  final cleanTextTheme = theme.textTheme.apply(
    fontFamily: kCleanSettingsFontFamily,
    fontFamilyFallback: kChineseFontFallbacks,
  );
  final cleanPrimaryTextTheme = theme.primaryTextTheme.apply(
    fontFamily: kCleanSettingsFontFamily,
    fontFamilyFallback: kChineseFontFallbacks,
  );

  TextStyle? cleanStyle(TextStyle? style, TextStyle? fallback) {
    final base = style ?? fallback;
    if (base == null) return null;
    return base.copyWith(
      fontFamily: kCleanSettingsFontFamily,
      fontFamilyFallback: kChineseFontFallbacks,
    );
  }

  return Theme(
    data: theme.copyWith(
      scaffoldBackgroundColor: apple
          ? Color.alphaBlend(
              Colors.white.withValues(alpha: 0.05),
              theme.scaffoldBackgroundColor,
            )
          : null,
      textTheme: cleanTextTheme,
      primaryTextTheme: cleanPrimaryTextTheme,
      listTileTheme: theme.listTileTheme.copyWith(
        titleTextStyle: cleanStyle(
          theme.listTileTheme.titleTextStyle,
          cleanTextTheme.bodyLarge,
        ),
        subtitleTextStyle: cleanStyle(
          theme.listTileTheme.subtitleTextStyle,
          cleanTextTheme.bodyMedium,
        ),
      ),
      dialogTheme: theme.dialogTheme.copyWith(
        titleTextStyle: cleanStyle(
          theme.dialogTheme.titleTextStyle,
          cleanTextTheme.titleLarge,
        ),
        contentTextStyle: cleanStyle(
          theme.dialogTheme.contentTextStyle,
          cleanTextTheme.bodyMedium,
        ),
      ),
    ),
    child: DefaultTextStyle.merge(
      style: const TextStyle(fontFamily: kCleanSettingsFontFamily),
      child: child,
    ),
  );
}