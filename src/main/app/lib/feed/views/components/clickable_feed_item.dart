import 'package:app/feed/models/feed.dart';
import 'package:app/feed/models/feed_item.dart';
import 'package:app/utils/states/simple_cubit.dart';
import 'package:app/utils/views/components/simple_cubit_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motor/motor.dart';
import 'package:url_launcher/url_launcher.dart';

class ClickableFeedItem extends StatelessWidget {
  final FeedItem item;
  final Widget child;

  const ClickableFeedItem({super.key, required this.item, required this.child});

  @override
  Widget build(BuildContext context) {
    return SimpleCubitView<bool>(
      builder: (context, hovered) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (event) => context.read<SimpleCubit<bool>>().setValue(true),
          onExit: (event) => context.read<SimpleCubit<bool>>().setValue(false),

          child: SingleMotionBuilder(
            motion: MaterialSpringMotion.expressiveSpatialDefault(),
            from: 1,
            value: hovered ? 1.02 : 1,
            builder: (context, value, child) => Opacity(
                opacity: value.clamp(0, 1),
                child: Transform.scale(scale: value, child: child)),
            child: GestureDetector(onTap: () => launchUrl(Uri.parse(item.url!)), child: child),
          ),
        );
      },
      initialValue: false,
    );
  }
}
