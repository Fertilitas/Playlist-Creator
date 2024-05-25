import 'dart:ui';

import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<int> _items = List<int>.generate(50, (int index) => index);

  @override
  Widget build(BuildContext context) {
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
              data: 'Lagu ${_items[index]}',
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
              onPressed: () {},
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  proxyDecorator: proxyDecorator,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final int item = _items.removeAt(oldIndex);
                      _items.insert(newIndex, item);
                    });
                    print(_items);
                  },
                  itemCount: _items.length,
                  itemBuilder: (BuildContext context, int index) =>
                      OrderableCard(
                    key: Key("$index"),
                    data: 'Lagu ${_items[index]}',
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

class OrderableCard extends StatelessWidget {
  const OrderableCard({
    super.key,
    required this.data,
    this.elevation,
  });
  final String data;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: Colors.lime.shade100,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        child: Center(
          child: Text(data),
        ),
      ),
    );
  }
}
