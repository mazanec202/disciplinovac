// This module contains the Discipline class (used for represenation of disciplines) and its specific exception.
//
// Author: Ondrej Holub

import 'package:disciplinovac/classes/person.dart';
import 'package:vibration/vibration.dart';

/// Class representing a single discipline
class Discipline {

  /// List of all disciplines that should be used for the calculation.
  static List<Discipline> disciplines = [];

  /// List of all limitations that should be used for the calculation.
  static List<List<Discipline>> allLimitations = [];


  /// Name of this discipline.
  String name;

  /// List of participants signed for this discipline.
  List<Person> participants = [];

  /// List of disciplines with which this discipline shares a limitation.
  List<Discipline> limitations = [];


  /// Constructor ensuring unique discipline names and marking new disciplines to a static list.
  /// 
  /// Throws [DisciplineNameConflict] when attempting to create multiple disciplines with the same [name].
  Discipline(String name){
    this.name = name;
    for(Discipline d in Discipline.disciplines){
      if(name == d.name){
        throw new DisciplineNameConflict();
      }
    }
    Discipline.disciplines.add(this);
  }


  /// Add limitation of disciplines [d1] and [d2].
  static void addLimitation(Discipline d1, Discipline d2){
    Discipline.allLimitations.add([d1, d2]); 
    d1.limitations.add(d2);
    d2.limitations.add(d1);
  }

  /// Remove limitation saved at position [index] in the allLimitations list.
  static void removeLimitationByIndex(int index){
    List<Discipline> l = Discipline.allLimitations[index];
    Discipline d1 = l[0];
    Discipline d2 = l[1];

    Discipline.allLimitations.removeAt(index);
    d1.limitations.remove(d2);
    d2.limitations.remove(d1);
  }


  /// Remove all limitations of this.
  void removeLimitations(){
    for(Discipline d in this.limitations){
      for(int i=0; i<Discipline.allLimitations.length; i++){
        List<Discipline> l = Discipline.allLimitations[i];
        if(l.contains(d) && l.contains(this)){
          Discipline.allLimitations.removeAt(i);
          d.limitations.remove(this);
          break;
        }
      }
    }
    this.limitations = [];
  }

  /// Causes a 60ms vibration.
  void vibrate() async {
    if(await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 60);
    }
  }

  /// Add participant based on [name] to this discipline and return an instance of the [participant]. 
  Person addParticipant(String name){
    // Participant is either found or created in the list of all participants.
    Person participant = Person.getPerson(name);
    
    if(participant.addChoice(this)){
      // Discipline was successfuly marked as one of the participant's choices.
      vibrate();
      this.participants.add(participant);
    }
    return participant;
  }

  /// Remove all participants of this discipline.
  void removeParticipants(){
    for(Person participant in participants){
      participant.choices.remove(this);
    }
    participants = [];
  }

}

/// Exception specific to the class Discipline used when there is an attempt to create multiple disciplines with the same name.
class DisciplineNameConflict implements Exception {
  String errMsg() => 'Disciplína s tímto jménem již existuje!';
}

