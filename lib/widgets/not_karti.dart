import 'package:flutter/material.dart';
import '../models/not_model.dart';

class NotKarti extends StatelessWidget {
  final Not not;
  final int index;
  final VoidCallback onEdit;
  final void Function(int from, int to) onMove;

  const NotKarti({
    super.key,
    required this.not,
    required this.index,
    required this.onEdit,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) {
        onMove(details.data, index);
      },
      builder: (context, candidateData, rejectedData) {
        return Card(
          color: not.renk,
          elevation: not.sabit ? 8 : 3,
          child: InkWell(
            onLongPress: onEdit,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (not.sabit)
                        const Icon(Icons.push_pin, size: 16),
                      Text(
                        not.baslik,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          not.icerik,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!not.sabit)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Draggable<int>(
                      data: index,
                      feedback: _dragFeedback(),
                      childWhenDragging: const SizedBox.shrink(),
                      child: const Icon(Icons.drag_handle, size: 20),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dragFeedback() {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      child: Card(
        color: not.renk,
        child: SizedBox(
          width: 160,
          height: 120,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  not.baslik,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    not.icerik,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
