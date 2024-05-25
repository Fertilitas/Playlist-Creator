import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../riverpod/dashboard.dart';

class OrderableCard extends ConsumerWidget {
  const OrderableCard({
    super.key,
    required this.index,
    this.elevation,
  });
  final int index;
  final double? elevation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listMusicP = ref.watch(listMusicProvider);
    return Card(
      elevation: elevation,
      color: Colors.lime.shade100,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                listMusicP[index].path.split('/').last,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            GestureDetector(
              onTap: () async {
                listMusicP.removeAt(index);
                ref.refresh(listMusicProvider.notifier).state = listMusicP;
              },
              child: Icon(
                Icons.delete,
                size: 20,
                color: Colors.red.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
