// This module contains the UI of the screen with accepted solution.
//
// Author: Ondrej Holub

import 'package:disciplinovac/classes/discipline.dart';
import 'package:disciplinovac/classes/person.dart';
import 'package:disciplinovac/classes/solution.dart';
import 'package:disciplinovac/classes/solver.dart';
import 'package:flutter/material.dart';

// Page widget
class AcceptedSolutionPage extends StatefulWidget {
  @override
  _AcceptedSolutionPageState createState() => _AcceptedSolutionPageState();
}
class _AcceptedSolutionPageState extends State<AcceptedSolutionPage> {

  /// Accepted solution.
  Solution solution = Solver.solutions[0]; // Accepted solution is the only one left in `Solver.solutions`

  /// Statistics of accepted solution.
  Widget _buildStats(){
    return Card( 
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            
            Column(children: <Widget>[
              Text('Disciplíny', style: TextStyle(fontSize: 20),),
              solution.getColoredDisciplineCnts()
            ],),
            Column(children: <Widget>[
              Text('Účastníci', style: TextStyle(fontSize: 20),),
              solution.getColoredParticipantCnts()
            ],),
            Column(children: <Widget>[
              Text('Konflikty', style: TextStyle(fontSize: 20),),
              Text("${solution.conflicts()}", style: TextStyle(fontSize: 20, color: (solution.conflicts() > 0) ? Colors.red : Colors.green))
            ],),
          ],
        ),
      ),
    );
  }

  /// List rounds and its disciplines with participant counts.
  _buildRounds(){
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Runda 1', style: TextStyle(fontSize: 18, color: Colors.blue),),
                _swapRoundsIcon(swappingFirstTwo: true),
                Text('Runda 2', style: TextStyle(fontSize: 18, color: Colors.yellow[800]),),
                _swapRoundsIcon(swappingFirstTwo: false),
                Text('Runda 3', style: TextStyle(fontSize: 18, color: Colors.deepPurple),),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 15),),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: solution.round1.map((item) => Text("${item.name} (${item.participants.length})", style: TextStyle(fontSize: 15),)).toList(),
                )),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: solution.round2.map((item) => Text("${item.name} (${item.participants.length})", style: TextStyle(fontSize: 15),)).toList(),
                )),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: solution.round3.map((item) => Text("${item.name} (${item.participants.length})", style: TextStyle(fontSize: 15),)).toList(),
                )),
              ],
            ),
          ],
        ),
      )
    );
  }

  /// Return icon for [swappingFirstTwo] rounds, or the second and third round.
  Widget _swapRoundsIcon({@required bool swappingFirstTwo}){
    return IconButton(
      iconSize: 24,
      padding: EdgeInsets.zero,
      icon: Icon(Icons.swap_horiz),
      onPressed: (){
        setState(() {
          List<Discipline> swapRound = solution.round2;
          if(swappingFirstTwo){
            solution.round2 = solution.round1;
            solution.round1 = swapRound;
          }else{
            solution.round2 = solution.round3;
            solution.round3 = swapRound;
          }
        });
      },
    );
  }

  /// Show all conflicting participants.
  Widget _buildConflictingParticipants(){
    if(solution.conflictingParticipants.length == 0){
      return SizedBox(width: 0, height: 0,);
    }
    return Card(
      child: Column(
        children: solution.conflictingParticipants.map((p) {
          List<DropdownMenuItem<Discipline>> list1 = _buildDropdownMenuItems(p.choices[0]);
          List<DropdownMenuItem<Discipline>> list2 = _buildDropdownMenuItems(p.choices[1]);
          return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Person.getNameOrIcon(p.name),
            DropdownButton( value: list1[0].value, items: list1, onChanged: (d){
              setState(() {
                if(p.changeChoice(0, d)){
                  solution.conflictingParticipants.remove(p);
                }
              });
            }),
            DropdownButton( value: list2[0].value, items: list2, onChanged: (d){
              setState(() {
                if(p.changeChoice(1, d)){
                  solution.conflictingParticipants.remove(p);
                }
              });
            }),
          ]);
        }).toList(),
      ),
    );
  }

  /// Adds the [items] to dropdown button for alternative participant's choices of disciplines from [round] with [color]. 
  void _appendDropdownMenuItemsFromRound(List<DropdownMenuItem<Discipline>> items, List<Discipline> round, Color color){
    for(Discipline d in round){
      items.add(DropdownMenuItem(value: d, child: Text(d.name, style: TextStyle(color: color))));
    }
  }

  /// Completes all the alternative choices for [conflictingDiscipline] as dropdown menu items.
  List<DropdownMenuItem<Discipline>> _buildDropdownMenuItems(Discipline conflictingDiscipline){
    List<DropdownMenuItem<Discipline>> items = [DropdownMenuItem(value: conflictingDiscipline, child: Text(conflictingDiscipline.name, style: TextStyle(color: Colors.red)))];
    
    if(solution.round1.contains(conflictingDiscipline)){
      _appendDropdownMenuItemsFromRound(items, solution.round2, Colors.yellow[800]);
      _appendDropdownMenuItemsFromRound(items, solution.round3, Colors.deepPurple);
    }else if(solution.round2.contains(conflictingDiscipline)){
      _appendDropdownMenuItemsFromRound(items, solution.round1, Colors.blue);
      _appendDropdownMenuItemsFromRound(items, solution.round3, Colors.deepPurple);
    }else{
      _appendDropdownMenuItemsFromRound(items, solution.round1, Colors.blue);
      _appendDropdownMenuItemsFromRound(items, solution.round2, Colors.yellow[800]);
    }

    return items;
  }

  /// Builds list of participants present in [round] with [color].
  Widget _buildParticipantListFromRound(int round, Color color){
    if(solution.conflictingParticipants.length != 0){
      return SizedBox(width: 0, height: 0,);
    }
    
    List<Discipline> r = (round == 1) ? solution.round1 : (round == 2) ? solution.round2 : solution.round3;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: color), color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5))),
      margin: EdgeInsets.all(5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(children: <Widget> [Padding(padding: EdgeInsets.all(5))]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: r.map((d){
            return Padding( padding: EdgeInsets.fromLTRB(10, 0, 10, 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(d.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
              Wrap( crossAxisAlignment: WrapCrossAlignment.end, children: d.participants.map((p){
                return Wrap(children:<Widget>[ Person.getNameOrIcon(p.name), Text('  ')]);
              }).toList(),)
            ]));
          }).toList(),
        ),
      ],),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(title: Text('Vybrané řešení'),),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 8),),
          _buildStats(),
          _buildRounds(),
          _buildConflictingParticipants(),
          _buildParticipantListFromRound(1, Colors.blue),
          _buildParticipantListFromRound(2, Colors.yellow[700]),
          _buildParticipantListFromRound(3, Colors.deepPurple),
      ]),
      )
    );
  }
}