import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PopulatePointScreen extends StatefulWidget {
  const PopulatePointScreen({super.key});

  @override
  State<PopulatePointScreen> createState() => _PopulatePointScreenState();
}

class _PopulatePointScreenState extends State<PopulatePointScreen> {
  final GlobalKey _imageKey = GlobalKey();
  final Size originalSize = const Size(1920, 1020);
  final List<Map<String, int>> points = [
    {"x": 951, "y": 569},
    {"x": 511, "y": 169},
    {"x": 821, "y": 269},
  ];
  List<Offset> offsets = [];

  @override
  void initState() {
    super.initState();
    offsets = points.map((point) {
      return Offset(point["x"]!.toDouble(), point["y"]!.toDouble());
    }).toList();
    debugPrint(offsets.toString());

    // Delay the render until the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {}); // Triggers rebuild with imageSize available
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Populate Marks')),
      body: Center(
        child: Column(
          children: [
            LayoutBuilder(builder: (_, constraints) {
              return Stack(
                children: [
                  SvgPicture.asset(
                    'assets/images/car_splat_diagram.svg',
                    key: _imageKey,
                    width: constraints.maxWidth,
                    fit: BoxFit.contain,
                  ),
                  // Show markers based on relative position
                  ...offsets.map((absoluteOffset) {
                    final box = _imageKey.currentContext?.findRenderObject()
                        as RenderBox?;
                    if (box == null) return const SizedBox();

                    final imageSize = box.size;

                    // Convert to relative
                    final relative = Offset(
                      absoluteOffset.dx / originalSize.width,
                      absoluteOffset.dy / originalSize.height,
                    );

                    // Convert to actual rendered image position
                    final renderedDx = relative.dx * imageSize.width;
                    final renderedDy = relative.dy * imageSize.height;

                    return Positioned(
                      left: renderedDx - 8,
                      top: renderedDy - 8,
                      child: Container(
                        width: 8 * 2,
                        height: 8 * 2,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    );
                  }),
                ],
              );
            })
          ],
        ),
      ),
    );
  }
}
