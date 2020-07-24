// This module contains the Person class used for representation of disciplines.
//
// Author: Ondrej Holub

import 'package:disciplinovac/classes/discipline.dart';
import 'package:flutter/material.dart';

/// Class representing a single person.
class Person{
  
  /// List of all the created people.
  static List<Person> people = [];


  /// Identifier of this person (usually in form of a code).
  String name;

  /// Choices of this person.
  List<Discipline> choices = [];


  /// Private constructor for the instance of Person assigning provided [name].
  Person._construct(name){
    this.name = name;
  }

  /// Returns an instance of Person identified by [name].
  /// 
  /// Person is either found in the list of people, or a new instance is created and marked in the list.
  static Person getPerson(name){
    for(Person person in people){
      if(person.name == name){
        return person;
      }
    }
    Person newPerson = Person._construct(name);
    people.add(newPerson);
    return newPerson;
  }

  /// Returns eiter a Text or an Image-like widget (if applicable) associated with the provided [code] (name) of a person.
  static Widget getNameOrIcon(String code){
    if(_assetExists(code)){
      return SizedBox( height: 30.0, child:Image(image: AssetImage("assets/$code.png"), width: 30));
    }else{
      return Text(code);
    }
  }

  static bool _assetExists(String code){
    List<String> list = code.split('_');
    if(list.length != 2){
      return false;
    }
    return _checkColor(list[1]) && _checkDiscipline(list[0]);
  }

  /// Verifies, whether is provided [colorCode] valid.
  static bool _checkColor(String colorCode){
    return ['K', 'R', 'G', 'Y', 'U', 'V'].contains(colorCode);
  }

  /// Verifies, whether is provided [iconCode] valid.
  static bool _checkDiscipline(String iconCode){
    return [
      '1kolka',
      'eso',
      'fakir',
      'harmonika',
      'hvezda',
      'klaun',
      'klobouk',
      'kouzlo',
      'kruh',
      'lano',
      'listek',
      'masky',
      'megafon',
      'mim',
      'ohen',
      'opona',
      'popcorn',
      'rumba',
      'silak',
      'stan',
      'stojka',
      'sviha',
      'trampo',
      'zongl'].contains(iconCode);
  }


  /// Returns true if a [discipline] was successfuly marked as a choice of this person.
  /// 
  /// Returns false if this person already has 2 choices or has already chosen the [discipline].
  bool addChoice(Discipline discipline){
    if(choices.length >= 2 || choices.contains(discipline)){
      return false;
    }
    choices.add(discipline);
    return true;
  }

  /// Replaces choice at [index] of this person by a [newChoice] and returns wheter the operation has been successful.
  /// 
  /// [index] must be in the range `0 <= index < this.choices.length`.
  /// [newChoice] has to be different than choices of this person.
  bool changeChoice(int index, Discipline newChoice){
    if(choices[index] == newChoice){
      return false;
    }
    Discipline d = choices.removeAt(index);
    d.participants.remove(this);
    newChoice.participants.add(this);
    choices.add(newChoice);
    return true;
  }
}