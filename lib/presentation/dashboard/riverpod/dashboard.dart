import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final listMusicProvider = StateProvider<List<File>>(
  (ref) => [],
);
