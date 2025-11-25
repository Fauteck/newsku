import 'package:app/feed/states/main_feed.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainFeedCubit(MainFeedState()),
      child: BlocBuilder<MainFeedCubit, MainFeedState>(
        builder: (context, state) {
          return Text(state.items.totalElements.toString());
        },
      ),
    );
  }
}
