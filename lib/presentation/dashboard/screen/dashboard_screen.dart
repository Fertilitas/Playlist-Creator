import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playlist_creator/presentation/dashboard/riverpod/dashboard.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listMusicP = ref.watch(listMusicProvider);

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(1, 6, animValue)!;
          final double scale = lerpDouble(1, 1.02, animValue)!;
          return Transform.scale(
            scale: scale,
            child: OrderableCard(
              index: index,
              elevation: elevation,
            ),
          );
        },
        child: child,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Screen')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: [
                    'mp3',
                    'wav',
                    'aac',
                  ],
                );

                if (result != null) {
                  List<File> files =
                      result.paths.map((path) => File(path!)).toList();
                  ref.read(listMusicProvider.notifier).state =
                      listMusicP + files;
                } else {
                  // User canceled the picker
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tambah Lagu'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  proxyDecorator: (child, index, animation) => proxyDecorator(
                    child,
                    index,
                    animation,
                  ),
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final File item = listMusicP.removeAt(oldIndex);
                    listMusicP.insert(newIndex, item);
                    ref.read(listMusicProvider.notifier).state = listMusicP;
                    print(listMusicP);
                  },
                  itemCount: listMusicP.length,
                  itemBuilder: (BuildContext context, int index) =>
                      OrderableCard(
                    key: Key("$index"),
                    index: index,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Submit Lagu'),
            ),
          ],
        ),
      ),
    );
  }
}

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
