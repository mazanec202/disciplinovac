// This module contains the form for adding a new limitation.
//
// Author: Ondrej Holub

import 'package:disciplinovac/classes/discipline.dart';
import 'package:flutter/material.dart';

// Form widget
class NewLimitationPage extends StatefulWidget {
  @override
  _NewLimitationPageState createState() => _NewLimitationPageState();
}
class _NewLimitationPageState extends State<NewLimitationPage> {
  
  /// First discipline that is part of a limitation.
  Discipline _d1;

  /// Second discipline that is part of a limitation.
  Discipline _d2;

  @override
  Widget build(BuildContext context) {

    List<DropdownMenuItem> list = Discipline.disciplines.map((d){return DropdownMenuItem(value: d, child: Text(d.name));}).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: (){
          if(_d1 == null || _d2 == null){
            return;
          }

          if(_d1 != _d2){
            Discipline.addLimitation(_d1, _d2);
            Navigator.pop(context);
          }
        }
      ),
      appBar: AppBar(
        title: Text('Přidat nové omezení'),
      ),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(width: 0),
            DropdownButton(items: list, value: _d1, hint: Text('Vyberte disciplínu'), onChanged: (d){
              setState(() {
                _d1 = d;
              });
            }),
            Text('nesmí sdílet rundu s'),
            DropdownButton(items: list, value: _d2, hint: Text('Vyberte disciplínu'), onChanged: (d){
              setState(() {
                _d2 = d;
              });
            }),
            SizedBox(width: 0),
          ],
        ),
      )
    );
  }
}