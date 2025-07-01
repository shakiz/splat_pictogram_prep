import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splat_pictogram_prep/draw/rect_painter.dart';

class DrawRectScreen extends StatefulWidget {
  const DrawRectScreen({super.key});

  @override
  State<DrawRectScreen> createState() => _DrawRectScreenState();
}

class _DrawRectScreenState extends State<DrawRectScreen> {
  final GlobalKey _imageKey = GlobalKey();
  final Size originalSize = const Size(1920, 1020);
  Offset? startPoint;
  Offset? endPoint;

  // Original absolute offsets based on original image size
  final List<Offset> originalOffsets = [
    Offset(200, 300),
    Offset(500, 300),
    Offset(500, 350),
    Offset(200, 350),
  ];

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Draw Rect on Image")),
      body: Center(
        child: LayoutBuilder(
          builder: (_, constraints) {
            return Stack(
              children: [
                GestureDetector(
                  onPanStart: (details) {
                    final box = _imageKey.currentContext?.findRenderObject()
                        as RenderBox?;
                    if (box == null) return;

                    final local = box.globalToLocal(details.globalPosition);
                    setState(() {
                      startPoint = local;
                      endPoint = null;
                    });
                  },
                  onPanUpdate: (details) {
                    final box = _imageKey.currentContext?.findRenderObject()
                        as RenderBox?;
                    if (box == null) return;

                    final local = box.globalToLocal(details.globalPosition);
                    setState(() {
                      endPoint = local;
                    });
                  },
                  onPanEnd: (_) {
                    if (startPoint != null && endPoint != null) {
                      final imageBox = _imageKey.currentContext
                          ?.findRenderObject() as RenderBox?;
                      if (imageBox == null) return;

                      final imageSize = imageBox.size;

                      // Store relative values
                      final relativeTopLeft = Offset(
                        startPoint!.dx / imageSize.width,
                        startPoint!.dy / imageSize.height,
                      );
                      final relativeBottomRight = Offset(
                        endPoint!.dx / imageSize.width,
                        endPoint!.dy / imageSize.height,
                      );

                      // Convert to original 1920x1020 coordinate system
                      final originalTopLeft = Offset(
                        relativeTopLeft.dx * originalSize.width,
                        relativeTopLeft.dy * originalSize.height,
                      );
                      final originalBottomRight = Offset(
                        relativeBottomRight.dx * originalSize.width,
                        relativeBottomRight.dy * originalSize.height,
                      );

                      debugPrint(
                          'Rectangle: TopLeft: $originalTopLeft, BottomRight: $originalBottomRight');
                    }
                  },
                  child: SvgPicture.asset(
                    'assets/images/car_splat_diagram.svg',
                    key: _imageKey,
                    width: constraints.maxWidth,
                    fit: BoxFit.contain,
                  ),
                ),
                // Use FutureBuilder or a delayed CustomPaint
                FutureBuilder<Size>(
                  future: _getImageSizeAfterLayout(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    final imageSize = snapshot.data!;
                    final renderedOffsets = originalOffsets.map((absOffset) {
                      final relative = Offset(
                        absOffset.dx / originalSize.width,
                        absOffset.dy / originalSize.height,
                      );
                      return Offset(
                        relative.dx * imageSize.width,
                        relative.dy * imageSize.height,
                      );
                    }).toList();

                    return CustomPaint(
                      painter: RectPainter(renderedOffsets),
                    );
                  },
                ),
                if (startPoint != null && endPoint != null)
                  Positioned(
                    left: min(startPoint!.dx, endPoint!.dx),
                    top: min(startPoint!.dy, endPoint!.dy),
                    child: Container(
                      width: (startPoint!.dx - endPoint!.dx).abs(),
                      height: (startPoint!.dy - endPoint!.dy).abs(),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<Size> _getImageSizeAfterLayout() async {
    await Future.delayed(Duration.zero);
    final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.size ?? Size.zero;
  }
}
