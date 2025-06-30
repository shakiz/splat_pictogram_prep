import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splat_pictogram_prep/populate_point_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey _imageKey = GlobalKey();
  final List<Offset> _tapPoints = [];

  final double _circleRadius = 8; // half of 16x16 marker
  final Size originalSize = const Size(1920, 1020);

  void _onTapDown(TapDownDetails details) {
    final RenderBox box = _imageKey.currentContext?.findRenderObject() as RenderBox;
    final imagePosition = box.localToGlobal(Offset.zero);
    final localTap = details.globalPosition - imagePosition;
    final renderedSize = box.size;

    debugPrint("Width:${box.size.width}  ======  Height:${box.size.height}");
    final position = box.globalToLocal(Offset.zero);

    // Convert to relative (0.0–1.0)
    final relativeOffset = Offset(
      localTap.dx / renderedSize.width,
      localTap.dy / renderedSize.height,
    );

    final absoluteOffset = Offset(
      relativeOffset.dx * originalSize.width,
      relativeOffset.dy * originalSize.height,
    );

    debugPrint("Relative: $relativeOffset");
    debugPrint("Absolute (based on 1920x1020): $absoluteOffset");

    bool isColliding = _tapPoints.any((existingPoint) {
      final dx = (existingPoint.dx - relativeOffset.dx) * renderedSize.width;
      final dy = (existingPoint.dy - relativeOffset.dy) * renderedSize.height;
      final distance = sqrt(dx * dx + dy * dy);
      return distance < (_circleRadius * 2);
    });

    debugPrint("X:${localTap.dx}  ======  Y:${localTap.dy}");

    if (isColliding) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Already marked!')),
      );
      return;
    }

    setState(() {
      _tapPoints.add(relativeOffset);
    });

    getMappedOrdinates();
  }

  void getMappedOrdinates(){
    const Size originalSize = Size(1920, 1020);

    final mappedPoints = _tapPoints.map((offset) {
      final isRelative = offset.dx <= 1.0 && offset.dy <= 1.0;

      final x = isRelative ? (offset.dx * originalSize.width).round() : offset.dx.round();
      final y = isRelative ? (offset.dy * originalSize.height).round() : offset.dy.round();

      return {
        "x": x,
        "y": y,
      };
    }).toList();

    debugPrint(mappedPoints.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tap to Mark')),
      body: Center(
        child: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PopulatePointScreen()));
                },
                child: Text("Populate Points")),
            SizedBox(
              height: 24,
            ),
            LayoutBuilder(
              builder: (_, constraints) {
                return GestureDetector(
                  onTapDown: _onTapDown,
                  child: Stack(
                    children: [
                      SvgPicture.asset(
                        'assets/images/car_splat_diagram.svg',
                        key: _imageKey,
                        width: constraints.maxWidth,
                        fit: BoxFit.contain,
                      ),
                      ..._tapPoints.map((relative) {
                        final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
                        if (box == null) return const SizedBox();

                        final imageSize = box.size;

                        final actualDx = relative.dx * imageSize.width;
                        final actualDy = relative.dy * imageSize.height;

                        return Positioned(
                          left: actualDx - _circleRadius,
                          top: actualDy - _circleRadius,
                          child: Container(
                            width: _circleRadius * 2,
                            height: _circleRadius * 2,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
