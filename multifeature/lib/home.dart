import 'package:flutter/material.dart';
import 'package:multifeature/calculator.dart';
import 'package:multifeature/clock.dart';
import 'package:multifeature/drawing.dart';
import 'package:multifeature/typing.dart';
import 'package:multifeature/weather.dart';
import 'package:multifeature/writing.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7D9FF),
      body: Column(
        children: [
          // Top gradient with score circle
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB16CEA), Color(0xFF8E2DE2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(70),
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Multi-Feature",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ScaleTransition(
                      scale: _animation,
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.auto_awesome,
                          color: Colors.deepPurple,
                          size: 40,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                buildIconButton(
                  context,
                  Icons.note_alt,
                  "Writing Board",
                  Colors.indigo,
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => WritingBoard())),
                ),
                buildIconButton(
                  context,
                  Icons.type_specimen,
                  "Typing Board",
                  Colors.black,
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => TypingBoard())),
                ),
                buildIconButton(
                  context,
                  Icons.draw_outlined,
                  "Drawing Board",
                  Colors.deepPurple,
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => DrawingBoard())),
                ),
                buildIconButton(
                  context,
                  Icons.sunny_snowing,
                  "Weather App",
                  Colors.grey,
                  () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => WeatherApp())),
                ),
                buildIconButton(
                  context,
                  Icons.timelapse,
                  "Clock",
                  Colors.brown,
                  () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => MyClock())),
                ),
                buildIconButton(
                  context,
                  Icons.calculate_outlined,
                  "calculator",
                  Colors.lightBlue,
                  () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => CalculatorApp())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIconButton(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.1),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }
}
