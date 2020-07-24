// This module contains the UI of the home screen.
//
// Author: Ondrej Holub

import 'package:disciplinovac/classes/discipline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

// Page widget
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {

  @override void initState() {
    // insert test initialization here, if applicable
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _pressedBackButton,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Disciplíny'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete, color: Colors.white,),
              onPressed: (){
                setState(() {
                  for(Discipline d in Discipline.disciplines){
                    d.removeParticipants();
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.format_list_numbered, color: Colors.white,),
              onPressed: (){
                if(Discipline.disciplines.isNotEmpty){
                  Navigator.pushNamed(context, '/solver');
                }
              },
            ),
          ],
        ),
        body: _disciplines(),
        backgroundColor: Colors.grey[300],
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.add_event,
          children: [
            SpeedDialChild(
              backgroundColor: Colors.green,
              child: Icon(Icons.accessibility_new),
              label: 'Přidat disciplínu',
              onTap: () {
                _addDisciplineDialog(context).then((onValue){
                  setState(() {
                    try{
                      if(onValue != null && onValue.length > 0){
                        Discipline(onValue);
                      }
                    }
                    catch(e){
                      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.errMsg())));
                    }
                  });
                });
              },
            ),
            SpeedDialChild(
              backgroundColor: Colors.red,
              child: Icon(Icons.warning),
              label: 'Přidat omezení',
              onTap: () {
                Navigator.pushNamed(context, '/new_limitation');
              },
            ),
          ],
        )
      )
    );
  }

  /// Prevents the app from an unintentional closing
  Future <bool> _pressedBackButton(){
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Opravdu chceš ukončit aplikaci? Veškerá data budou zahozena!"),
        actions: <Widget>[
          FlatButton(onPressed: ()=>Navigator.pop(context, true), child: Text("Ano")),
          FlatButton(onPressed: ()=>Navigator.pop(context, false), child: Text("Ne")),
        ],
      )
    );
  }

  /// Builds inserted disciplines.
  Widget _disciplines(){

    List<dynamic> list = List.from(Discipline.disciplines);
    list.addAll(Discipline.allLimitations);

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index){
      int indexOfLimitation = index - Discipline.disciplines.length;
        return Card(
          child: ListTile(
            onTap: (){
              if(list[index] is Discipline){
                setState(() {
                  Navigator.pushNamed(context, '/discipline_page', arguments: Discipline.disciplines[index]);
                });
              }
            },
            leading: IconButton(
              padding: EdgeInsets.all(0),
              icon: Icon(Icons.delete),
              onPressed: (){
                setState(() {
                  if(list[index] is Discipline){
                    if(Discipline.disciplines[index].participants.length == 0){
                      Discipline.disciplines[index].removeLimitations();
                      Discipline.disciplines.removeAt(index);  
                    }else{
                      Discipline.disciplines[index].removeParticipants();
                    }
                  }else{
                    Discipline.removeLimitationByIndex(indexOfLimitation);
                  }
                });
              },
            ),
            title: (list[index] is Discipline) ?
                 Text('${Discipline.disciplines[index].name} (${Discipline.disciplines[index].participants.length})')
                 :
                 Wrap(
                   crossAxisAlignment: WrapCrossAlignment.center,
                   children: <Widget>[
                   Text('${Discipline.allLimitations[indexOfLimitation][0].name}', style: TextStyle(color: Colors.red, fontSize: 12)),
                   Text(' X '),
                   Text('${Discipline.allLimitations[indexOfLimitation][1].name}', style: TextStyle(color: Colors.red, fontSize: 12)),
                 ],)
          ),
        );
      }
    );
  }

  /// Dialog for adding disciplines.
  Future<String> _addDisciplineDialog(BuildContext context){
    return showDialog(context: context, builder: (context){
      TextEditingController controller = TextEditingController();
      return AlertDialog(
        title: Text('Přidat novou disciplínu'),
        content: TextField(
          textCapitalization: TextCapitalization.sentences,
          controller: controller,
          autofocus: true,
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: Text('Přidat'),
            onPressed: (){
              Navigator.of(context).pop(controller.text.toString());
            }
          )
        ],
      );
    });
  }
}

