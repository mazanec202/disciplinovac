// This module contains the UI of the screen for adding participants to a discipline.
//
// Author: Ondrej Holub

import 'package:disciplinovac/classes/discipline.dart';
import 'package:disciplinovac/classes/person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/flutter_qr_bar_scanner.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';

// Page widget
class DisciplineAddParticipantPage extends StatefulWidget {
  @override
  _DisciplineAddParticipantPageState createState() => _DisciplineAddParticipantPageState();
}
class _DisciplineAddParticipantPageState extends State<DisciplineAddParticipantPage> {

  /// Last scanned code of participant.
  String code;

  /// Disciplines of last scanned participant.
  String details = '';

  /// Widget to be replaced with icon or text of participant code.
  Widget iconOrText = Text('?');

  bool _camState = false;

  _scanCode(){
    setState(() {
      _camState = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _scanCode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Discipline discipline = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(discipline.name),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 300,
              height: 300,
              child: _camState ?
                QRBarScannerCamera(
                  notStartedBuilder: (BuildContext context){
                    return Text('Loading...');
                  },
                  onError: (context, error) => Text(
                      error.toString(),
                      style: TextStyle(color: Colors.red),
                    ),
                  formats: [BarcodeFormats.QR_CODE],
                  qrCodeCallback: (code){
                    Person participant;
                    String choice2;
                    setState(() {
                      iconOrText = Person.getNameOrIcon(code);
                      participant = discipline.addParticipant(code);
                      choice2 =  participant.choices.length == 1 ? '' : ", ${participant.choices[1].name}";
                      details = participant.choices[0].name + choice2;
                    });
                  }
                )
                :
                Text('Wait')
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
            ),
            Text("Počet účastníků:"),
            Text(
              "${discipline.participants.length}",
              style: TextStyle(
                fontSize: 40,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                iconOrText,
                Text(
                  ' má zapsáno: ',
                  style: TextStyle( fontStyle: FontStyle.italic, color: Colors.grey),
                ),
                Text(details),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

