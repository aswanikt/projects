import 'package:flutter/material.dart';


class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _currentInput = "";
  double _num1 = 0;
  double _num2 = 0;
  String _operation = "";
  bool _waitingForSecondNumber = false;

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _currentInput = "";
        _num1 = 0;
        _num2 = 0;
        _operation = "";
        _waitingForSecondNumber = false;
      } else if (buttonText == "+/-") {
        if (_currentInput.isNotEmpty) {
          if (_currentInput[0] != '-') {
            _currentInput = '-$_currentInput';
          } else {
            _currentInput = _currentInput.substring(1);
          }
          _output = _currentInput;
        }
      } else if (buttonText == "%") {
        if (_currentInput.isNotEmpty) {
          double value = double.parse(_currentInput);
          _currentInput = (value / 100).toString();
          _output = _currentInput;
        }
      } else if (buttonText == ".") {
        if (!_currentInput.contains(".")) {
          _currentInput += ".";
          _output = _currentInput;
        }
      } else if (buttonText == "+" || buttonText == "-" || buttonText == "×" || buttonText == "÷") {
        if (_currentInput.isNotEmpty) {
          _num1 = double.parse(_currentInput);
          _operation = buttonText;
          _currentInput = "";
          _output = _operation;
          _waitingForSecondNumber = true;
        }
      } else if (buttonText == "=") {
        if (_operation.isNotEmpty && _currentInput.isNotEmpty) {
          _num2 = double.parse(_currentInput);
          double result = 0;
          switch (_operation) {
            case "+":
              result = _num1 + _num2;
              break;
            case "-":
              result = _num1 - _num2;
              break;
            case "×":
              result = _num1 * _num2;
              break;
            case "÷":
              result = _num1 / _num2;
              break;
          }
          _output = result.toString();
          _currentInput = result.toString();
          _operation = "";
          _waitingForSecondNumber = false;
        }
      } else {
        if (_waitingForSecondNumber) {
          _currentInput = buttonText;
          _waitingForSecondNumber = false;
        } else {
          if (_currentInput == "0") {
            _currentInput = buttonText;
          } else {
            _currentInput += buttonText;
          }
        }
        _output = _currentInput;
      }
    });
  }

  Widget _buildButton(String buttonText, {Color? color, Color? textColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[200],
            foregroundColor: textColor ?? Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            padding: const EdgeInsets.all(20.0),
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 24.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Text(
              _output,
              style: const TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(child: Divider()),
          Column(
            children: [
              Row(
                children: [
                  _buildButton("C", color: Colors.red, textColor: Colors.white),
                  _buildButton("+/-", color: Colors.grey[350]),
                  _buildButton("%", color: Colors.grey[350]),
                  _buildButton("÷", color: Colors.orange, textColor: Colors.white),
                ],
              ),
              Row(
                children: [
                  _buildButton("7"),
                  _buildButton("8"),
                  _buildButton("9"),
                  _buildButton("×", color: Colors.orange, textColor: Colors.white),
                ],
              ),
              Row(
                children: [
                  _buildButton("4"),
                  _buildButton("5"),
                  _buildButton("6"),
                  _buildButton("-", color: Colors.orange, textColor: Colors.white),
                ],
              ),
              Row(
                children: [
                  _buildButton("1"),
                  _buildButton("2"),
                  _buildButton("3"),
                  _buildButton("+", color: Colors.orange, textColor: Colors.white),
                ],
              ),
              Row(
                children: [
                  _buildButton("0"),
                  _buildButton("."),
                  _buildButton("=", color: Colors.orange, textColor: Colors.white),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}