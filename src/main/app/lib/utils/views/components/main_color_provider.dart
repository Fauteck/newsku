import 'package:app/utils/utils.dart';
import 'package:flutter/cupertino.dart';

class MainColorProvider extends StatelessWidget {
  final Widget Function(BuildContext context, Color color) builder;

  const MainColorProvider({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Color>(
      future: localPreferences.color,
      builder: (context, snapshot) {
        return builder(context, snapshot.data ?? localPreferences.themeColor);
      },
    );
  }
}
