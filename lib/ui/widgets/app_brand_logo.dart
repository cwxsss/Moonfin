import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../l10n/app_localizations.dart';

class AppBrandLogo extends StatelessWidget {
  final double height;
  final double spacing;
  final TextStyle? textStyle;

  const AppBrandLogo({
    super.key,
    this.height = 64,
    this.spacing = 16,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n.appTitle;
    final fontSize = height * 0.46;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/moonfin_logo.svg',
          height: height,
          width: height,
        ),
        SizedBox(width: spacing),
        Text(
          title,
          style: textStyle ??
              TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
        ),
      ],
    );
  }
}
