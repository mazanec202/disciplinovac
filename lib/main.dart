// This module contains the routing and foundations of the application.
//
// Author: Ondrej Holub

import 'package:disciplinovac/pages/accepted_solution.dart';
import 'package:disciplinovac/pages/home.dart';
import 'package:disciplinovac/pages/new_limitation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/discipline_page.dart';
import 'pages/results.dart';
import 'pages/solver_page.dart';

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp
    ]);

    return MaterialApp(
      title: 'Title',
      routes: {
        '/' : (context) => HomePage(),
        '/discipline_page' : (context) => DisciplineAddParticipantPage(),
        '/new_limitation' : (context) => NewLimitationPage(),
        '/solver' : (context) => SolverPage(),
        '/results' : (context) => ResultsPage(),
        '/accepted_solution' : (context) => AcceptedSolutionPage(),
      },
    );
  }
}


main() =>  runApp(MainApp());
