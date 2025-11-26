import 'package:app/feed/models/feed.dart';
import 'package:app/feed/models/feed_item.dart';
import 'package:app/identity/states/identity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeedImage extends StatelessWidget {
  final double? width;
  final double? height;
  final Feed item;

  const FeedImage({super.key, required this.item, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    if ((item.image ?? '').isEmpty) {
      return SizedBox.shrink();
    }

    var cubit = context.read<IdentityCubit>();
    return CachedNetworkImage(
      imageUrl: '${cubit.state.serverUrl!}/api/feeds/${item.id}/image',
      width: width,
      height: height,
      fit: BoxFit.cover,
      imageRenderMethodForWeb: .HttpGet,
      httpHeaders: {'Authorization': 'Bearer ${cubit.state.token}'},
    );
  }
}
