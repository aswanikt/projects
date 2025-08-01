import 'package:flutter/material.dart';

class DrawingBoard extends StatefulWidget {
  @override
  _DrawingBoardState createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  List<List<Offset>> strokes = []; // List of strokes
  List<Offset> currentStroke = [];

  Color selectedColor = Colors.blue;
  double strokeWidth = 4.0;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      currentStroke = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      currentStroke.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      strokes.add(currentStroke);
      currentStroke = [];
    });
  }

  void _clearDrawing() {
    setState(() {
      strokes.clear();
      currentStroke.clear();
    });
  }

  void _undoStroke() {
    setState(() {
      if (strokes.isNotEmpty) strokes.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drawing Board"),
        actions: [
          IconButton(icon: Icon(Icons.undo), onPressed: _undoStroke),
          IconButton(icon: Icon(Icons.clear), onPressed: _clearDrawing),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: DrawingPainter(
                    strokes, currentStroke, selectedColor, strokeWidth),
                size: Size.infinite,
              ),
            ),
          ),
          Container(
            color: Colors.amber[50],
            padding: EdgeInsets.symmetric(horizontal: 36, vertical: 30),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Brush Size"),
                    Expanded(
                      child: Slider(
                        min: 1.0,
                        max: 10.0,
                        value: strokeWidth,
                        onChanged: (value) =>
                            setState(() => strokeWidth = value),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildColorButton(Colors.red),
                    _buildColorButton(Colors.blue),
                    _buildColorButton(Colors.green),
                    _buildColorButton(Colors.orange),
                    _buildColorButton(Colors.black),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: CircleAvatar(
        backgroundColor: color,
        radius: selectedColor == color ? 18 : 14,
        child: selectedColor == color
            ? Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color color;
  final double strokeWidth;

  DrawingPainter(
      this.strokes, this.currentStroke, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (var stroke in strokes) {
      paint.color = color; // All strokes have same color for simplicity
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }

    // Draw current stroke while drawing
    for (int i = 0; i < currentStroke.length - 1; i++) {
      canvas.drawLine(currentStroke[i], currentStroke[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
