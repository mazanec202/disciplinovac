// This module contains the UI for presenting the found results.
//
// Author: Ondrej Holub

import 'package:disciplinovac/classes/discipline.dart';
import 'package:disciplinovac/classes/person.dart';
import 'package:disciplinovac/classes/solution.dart';
import 'package:disciplinovac/classes/solver.dart';
import 'package:flutter/material.dart';

// Page widget
class ResultsPage extends StatefulWidget {
  @override
  _ResultsPageState createState() => _ResultsPageState();
}
class _ResultsPageState extends State<ResultsPage> {

  /// Returns disciplines of round [roundNum] from solution [s]
  Widget buildRoundDisciplines(int roundNum, Solution s){

    Color color;
    List<Discipline> round;
    switch (roundNum) {
      case 1:
        round = s.round1;
        color = Colors.blue;
        break;
      case 2:
        round = s.round2;
        color = Colors.yellow[800];
        break;
      case 3:
        round = s.round3;
        color = Colors.deepPurple;
        break;
      default:
        throw Exception('buildRoundDisciplines received invalid roundNum');
    }

    List<Text> disciplines = [Text(
      "Runda $roundNum: ",
      style: TextStyle(
        fontStyle: FontStyle.italic,
        color: color,
      ),
    )];

    for(Discipline d in round){
      disciplines.add(Text(d.name, style: TextStyle(color: Colors.black)));
      disciplines.add(Text("(${d.participants.length})", style: TextStyle(color: Colors.grey, fontSize: 12)));
      disciplines.add(Text(', ', style: TextStyle(color: Colors.black)));
    }
    
    if(disciplines.length != 1){
      Text last = disciplines.removeLast();
      Text newLast = Text(last.data.substring(0, last.data.length - 2), style: TextStyle(color: Colors.black),);
      disciplines.add(newLast);
    }

    return Padding(padding: EdgeInsets.only(top: 5), child: Wrap(
      children: disciplines,
    ));
  }

  /// Widget for listing conflicting participants.
  Widget showConflictingParticipants(Solution solution){
    List<Widget> conflicts = [];

    for(Person p in solution.conflictingParticipants){
      Color color = solution.round1.contains(p.choices[0]) ? Colors.blue : solution.round2.contains(p.choices[0]) ? Colors.yellow[800] : Colors.deepPurple;
      conflicts.add(Wrap(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 5),child: Person.getNameOrIcon(p.name)),
            Text(' :     '),
            Text(p.choices[0].name, style: TextStyle(fontStyle: FontStyle.italic, color: color)),
            Text(', '),
            Text(p.choices[1].name, style: TextStyle(fontStyle: FontStyle.italic, color: color)),
          ],
          crossAxisAlignment: WrapCrossAlignment.center,
        ));
    }

    return Column(children: conflicts, mainAxisAlignment: MainAxisAlignment.spaceEvenly);
  }

  /// Returns string with appropriate inflection (according to [conflictCnt]) of the word 'conflict' in the Czech language.
  String _inflectConflicts(int conflictCnt){
    return (conflictCnt == 1) ? "1 konflikt" : (conflictCnt < 5 && conflictCnt != 0) ? "$conflictCnt konflikty" : "$conflictCnt konfliktů";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Přehled řešení (${Solver.solutions.length})'),
      ),
      backgroundColor: Colors.grey[300],
      body: ListView.builder(
        itemCount: Solver.solutions.length,
        itemBuilder: (context, index){
          Solution solution = Solver.solutions[index];
          return Card(
            child: ExpansionTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 3), 
                    child:  Text("${index + 1}. řešení: " + _inflectConflicts(solution.conflicts()), style: TextStyle( fontWeight: FontWeight.bold, color: Colors.black ),
                    ), 
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Table(
                      children: <TableRow>[
                        TableRow(children: <Widget>[
                          Center(child: Text("Disciplíny", style: TextStyle(color: Colors.black),)),
                          Center(child: Text("Účastníci", style: TextStyle(color: Colors.black),)),
                        ]),
                        TableRow(children: <Widget>[
                          Center(child: solution.getColoredDisciplineCnts()),//Text("${s.round1.length}-${s.round2.length}-${s.round3.length}")),
                          Center(child: solution.getColoredParticipantCnts())
                        ])
                      ],
                    )
                  ),
                  buildRoundDisciplines(1, solution),
                  buildRoundDisciplines(2, solution),
                  buildRoundDisciplines(3, solution),
                ],
              ),
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 10.0), child: Text('Seznam konfliktů:', style: TextStyle(fontWeight: FontWeight.bold),)),
                showConflictingParticipants(solution),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: OutlineButton(
                    color: Colors.white,
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                    child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: <Widget>[Icon(Icons.check, color: Colors.green,) ,Text('Přijmout', style: TextStyle(color: Colors.green))]),
                    onPressed: (){
                      Solver.solutions = [solution];
                      Navigator.pushReplacementNamed(context, '/accepted_solution');
                  }),
                ),
              ],
            ),
          );
        }
      )
    );
  }
}