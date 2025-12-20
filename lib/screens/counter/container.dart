import 'package:flutter/material.dart';
import 'package:flutter_example_app/screens/counter/presentation.dart';

class CounterContainer extends StatefulWidget {
  const CounterContainer({super.key});

  @override
  State<CounterContainer> createState() => _CounterContainerState();
}

class _CounterContainerState extends State<CounterContainer> {
  int count = 0;

  void increment() {
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CounterPresentation(count: count, onIncrement: increment);
  }
}
