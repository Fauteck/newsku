import 'package:app/utils/views/components/main_color_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  final double? size;
  final Color? color;

  const AppLogo({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return MainColorProvider(
      builder: (context, mainColor) {
        return SvgPicture.asset(
          'assets/newsku.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color ?? mainColor, BlendMode.srcIn),
        );
      },
    );
  }
}
