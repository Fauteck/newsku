import 'package:app/feed/models/feed_item.dart';
import 'package:flutter/material.dart';

class Headlines extends StatelessWidget {
  final List<FeedItem> items;
  const Headlines({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Text('Headlines');
  }
}
