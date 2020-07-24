// This module contains the UI for the loading page while Solver is working.
//
// Author: Ondrej Holub
import 'package:disciplinovac/classes/solver.dart';
import 'package:flutter/material.dart';

// Page widget
class SolverPage extends StatefulWidget {
  @override
  _SolverPageState createState() => _SolverPageState();
}
class _SolverPageState extends State<SolverPage> {

  /// Start the Solver.
  _solveAndRelocate(context) async{
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    await Solver.solve();
    stopwatch.stop();
    print("Solved in ${stopwatch.elapsedMilliseconds} ms");
    Navigator.pushReplacementNamed(context, '/results');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _solveAndRelocate(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator()
      ),
    );
  }
}