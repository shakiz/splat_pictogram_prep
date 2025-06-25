import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  void _onTapDown(TapDownDetails details) {
    final RenderBox box = _imageKey.currentContext?.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    final local = details.globalPosition - position;

    setState(() {
      _tapPoints.add(local);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tap to Mark')),
      body: Center(
        child: LayoutBuilder(
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
                  ..._tapPoints.map((offset) {
                    return Positioned(
                      left: offset.dx - 8,
                      top: offset.dy - 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
