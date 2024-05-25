import 'dart:io';
import 'dart:ui';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:playlist_creator/presentation/dashboard/riverpod/dashboard.dart';

import '../widget/orderable_card.dart';

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

    archiveAsZip() async {
      try {
        // Get the downloads directory
        final directory = await getDownloadsDirectory();
        final zipName = 'zipped_${DateTime.now().millisecondsSinceEpoch}.zip';
        if (directory == null) {
          throw Exception("Could not find the downloads directory");
        }

        // Initialize the ZipFileEncoder
        var encoder = ZipFileEncoder();
        encoder.create('${directory.path}/$zipName');

        // Track used file names to ensure uniqueness
        Map<String, int> fileNameCount = {};

        // Add compressed files to the zip
        for (var file in listMusicP) {
          // Read the file content
          List<int> bytes = await file.readAsBytes();

          // Compress the file content using GZipEncoder
          List<int> compressedBytes = GZipEncoder().encode(bytes, level: 3)!;

          // Get the original file name
          String originalFileName = file.path.split('/').last;
          String uniqueFileName = originalFileName;

          // Check if the file name already exists in the map
          if (fileNameCount.containsKey(originalFileName)) {
            int count = fileNameCount[originalFileName]!;
            count++;
            fileNameCount[originalFileName] = count;
            // Append the count to the file name to make it unique
            // e.g. "song.mp3" becomes "song_1.mp3"
            uniqueFileName =
                "${originalFileName.split('.').first}($count).${originalFileName.split('.').last}";
          } else {
            fileNameCount[originalFileName] = 1;
          }

          // Create a new ArchiveFile with a unique file name
          var archiveFile = ArchiveFile(
              uniqueFileName, compressedBytes.length, compressedBytes);

          // Add the compressed file to the zip
          encoder.addArchiveFile(archiveFile);
        }

        // Close the encoder to finalize the zip file
        encoder.close();

        print('Compressed zip file created at ${directory.path}/$zipName');
      } catch (e) {
        print('An error occurred while creating the compressed zip file: $e');
      }
    }

    archiveAsTbz() async {
      try {
        // Get the downloads directory
        final directory = await getDownloadsDirectory();
        if (directory == null) {
          throw Exception("Could not find the downloads directory");
        }

        final archive = Archive();

        // Track used file names to ensure uniqueness
        Map<String, int> fileNameCount = {};

        // Add compressed files to the zip
        for (var file in listMusicP) {
          // Read the file content
          List<int> bytes = await file.readAsBytes();

          // Compress the file content using GZipEncoder
          List<int> compressedBytes = GZipEncoder().encode(bytes)!;

          // Get the original file name
          String originalFileName = file.path.split('/').last;
          String uniqueFileName = originalFileName;

          // Check if the file name already exists in the map
          if (fileNameCount.containsKey(originalFileName)) {
            int count = fileNameCount[originalFileName]!;
            count++;
            fileNameCount[originalFileName] = count;
            // Append the count to the file name to make it unique
            // e.g. "song.mp3" becomes "song_1.mp3"
            uniqueFileName =
                "${originalFileName.split('.').first}_$count.${originalFileName.split('.').last}";
          } else {
            fileNameCount[originalFileName] = 1;
          }

          // Create a new ArchiveFile with a unique file name
          var archiveFile = ArchiveFile(
              uniqueFileName, compressedBytes.length, compressedBytes);

          // Add the compressed file to the zip
          archive.addFile(archiveFile);
        }

        final tarData = TarEncoder().encode(archive);
        final tarBz2 = BZip2Encoder().encode(tarData);
        final fp = File("${directory.path}/album.tbz");
        fp.writeAsBytesSync(tarBz2);

        print('Compressed zip file created at ${fp.path}');
      } catch (e) {
        print('An error occurred while creating the compressed zip file: $e');
      }
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
              onPressed: () async {
                archiveAsZip();
              },
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
