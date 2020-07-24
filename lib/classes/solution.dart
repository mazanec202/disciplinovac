// This module contains the Solution class used for representation of nodes of the solution tree.
//
// Author: Ondrej Holub

import 'dart:math';
import 'package:disciplinovac/classes/discipline.dart';
import 'package:disciplinovac/classes/person.dart';
import 'package:disciplinovac/classes/solver.dart';
import 'package:flutter/material.dart';

/// Class representing a single solution node.
class Solution{

  /// List of disciplines assigned to the first round.
  List<Discipline> round1 = [];

  /// List of disciplines assigned to the second round.
  List<Discipline> round2 = [];

  /// List of disciplines assigned to the third round.
  List<Discipline> round3 = [];

  /// Index of a discipline (in `Discipline.disciplines`) that is next to be inserted.
  int _indexToBeInserted = 0;

  /// List of participants that are in conflict in this solution node.
  List<Person> conflictingParticipants = [];

  /// Dispersion of participants in rounds of this solution.
  double dispersion;

  /// Returns the number of conflict in this solution.
  int conflicts(){
    return conflictingParticipants.length;
  }

  /// Returns whether this solution node is final (leaf node).
  bool isFinal(){
    return _indexToBeInserted < Solver.nrOfDisciplines ? false : true;
  }


  /* METHODS USED FOR BRANCHING */

  /// Branching method producing new solution nodes.
  /// 
  /// Created solution nodes violating limitations are thrown away.
  List<Solution> branch(){
    List<Solution> children = [];
    Discipline d = Discipline.disciplines[this._indexToBeInserted]; 
    this._indexToBeInserted++;

    // Branch to round1.
    bool insertedToEmpty = this.round1.isEmpty;
    if(_doesntViolateLimitation(round1, d)){
      children.add(this._cloneWithNewDiscipline(1, d));
    }

    // Branch to round2.
    if(_doesntViolateLimitation(round2, d)){
      // Ensure inserting into an empty round happens only once during this branching.
      if(this.round2.isEmpty){
        if(!insertedToEmpty){       // Do not merge the `if` conditions, otherwise following `else` won't work properly.
          insertedToEmpty = true;
          children.add(this._cloneWithNewDiscipline(2, d));
        }
      }else{
        children.add(this._cloneWithNewDiscipline(2, d));
      }
    }

    // Branch to round3.
    if(_doesntViolateLimitation(round3, d)){
      // Ensure inserting into an empty round happens only once during this branching.
      if(this.round3.isEmpty){
        if(!insertedToEmpty){       // Do not merge the `if` conditions, otherwise following `else` won't work properly.
          //insertedToEmpty = true; // Uncomment if rewriting for more than three rounds.
          children.add(this._cloneWithNewDiscipline(3, d));
        }
      }else{
        children.add(this._cloneWithNewDiscipline(3, d));
      }
    }
    return children;
  }

  /// Returns true, if there are no limitations violated by inserting [disciplineToBeInserted] into [round], otherwise false.
  bool _doesntViolateLimitation(List<Discipline> round, Discipline disciplineToBeInserted){
    for(Discipline limitatingDiscipline in disciplineToBeInserted.limitations){
      if(round.contains(limitatingDiscipline)){
        return false;
      }
    }
    return true;
  }

  /// Returns a clone of this solution differentiating in [discipline] inserted into round [roundNum].
  Solution _cloneWithNewDiscipline(int roundNum, Discipline discipline){
    return this._clone()._insertDisciplineTo(roundNum, discipline);
  }

  /// Returns an exact (contentwise) clone of this solution node.
  Solution _clone(){
    Solution clone = Solution();
    clone.round1 = List<Discipline>.from(this.round1);
    clone.round2 = List<Discipline>.from(this.round2);
    clone.round3 = List<Discipline>.from(this.round3);
    clone.conflictingParticipants = List<Person>.from(this.conflictingParticipants);
    clone._indexToBeInserted = this._indexToBeInserted;
    return clone;
  }

  /// Inserts [discipline] into round [roundNum] of this solution, which is returned.
  Solution _insertDisciplineTo(int roundNum, Discipline discipline){
    List<Discipline> round = (roundNum == 1) ? round1 : (roundNum == 2) ? round2 : round3;
    // Recalculate conflicts.
    this._countConflicts(round, discipline);
    round.add(discipline);
    return this;
  }

  /// Recalculates conflicts after inserting [newDiscipline] into [round].
  void _countConflicts(List<Discipline> round, Discipline newDiscipline){
    for(Person newParticipant in newDiscipline.participants){
      for( Discipline oldDiscipline in round ){
        if(oldDiscipline.participants.contains(newParticipant)){
          this.conflictingParticipants.add(newParticipant);
          break;  // Possible, because every participant can have only two disciplines. If we get to this line, one of them is the newDiscipline and the other the oldDiscipline.
        }
      }
    }
  }


  /* METHOD USED FOR SORTING */

  /// Calculate dispersion of participants among rounds of this solution.
  calculateDispersion(){
    double peopleInRoundAvg = Person.people.length / 3;
    
    double base;
    base = this._getParticipantCountForRound(1) - peopleInRoundAvg;
    this.dispersion = pow(base, 2);

    base = this._getParticipantCountForRound(2) - peopleInRoundAvg;
    this.dispersion += pow(base, 2);

    base = this._getParticipantCountForRound(3) - peopleInRoundAvg;
    this.dispersion += pow(base, 2);
  }


  /* METHODS USED FOR UI */

  /// Returns widget of coloured participant distribution among rounds.
  Widget getColoredParticipantCnts(){
    return _colorizeCnts(this.getParticipantCounts());
  }

  /// Returns number of participants in each round.
  List<int> getParticipantCounts(){
    return [_getParticipantCountForRound(1), _getParticipantCountForRound(2), _getParticipantCountForRound(3)];
  }

  /// Returns number of participants in round [roundNum].
  int _getParticipantCountForRound(int roundNum){
    List<Discipline> round = (roundNum == 1) ? this.round1 : (roundNum == 2) ? this.round2 : this.round3 ;
    int cnt = 0;
    for(Discipline d in round){
      cnt += d.participants.length;
    }
    return cnt;
  }

  /// Returns widget of coloured discipline distribution among rounds.
  Widget getColoredDisciplineCnts(){
    return _colorizeCnts([this.round1.length, this.round2.length, this.round3.length]);
  }

  /// Returns widget with coloured data [counts].
  Widget _colorizeCnts(List<int> counts){
    return Row(children: <Widget>[
      Text("${counts[0]}", style: TextStyle(color: Colors.blue, fontSize: 20)),
      Text("-", style: TextStyle(color: Colors.black, fontSize: 20)),
      Text("${counts[1]}", style: TextStyle(color: Colors.yellow[800], fontSize: 20)),
      Text("-", style: TextStyle(color: Colors.black, fontSize: 20)),
      Text("${counts[2]}", style: TextStyle(color: Colors.deepPurple, fontSize: 20)),
    ],mainAxisAlignment: MainAxisAlignment.center,);
  }
}