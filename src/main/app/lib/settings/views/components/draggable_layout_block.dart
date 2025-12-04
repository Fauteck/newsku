import 'package:app/layouts/models/layout_block_types.dart';
import 'package:app/settings/views/components/dragged_layout_block.dart';
import 'package:flutter/material.dart';

class DraggableLayoutBlock extends StatelessWidget {
  final Function(bool dragging) setDragging;
  final LayoutBlockTypes type;

  const DraggableLayoutBlock({super.key, required this.setDragging, required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Draggable<LayoutBlockTypes>(
      onDragStarted: () => setDragging(true),
      onDragEnd: (details) => setDragging(false),
      feedback: DraggedLayoutBlock(type: type),
      data: type,
      child: Column(
        spacing: 4,
        children: [
          Text(type.name, style: TextStyle(color: colors.primary)),
          type.smallPreview,
        ],
      ),
    );
  }
}
