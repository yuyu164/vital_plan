import 'package:flutter/material.dart';

class SecondRow extends StatefulWidget {
  SecondRow({Key? key}) : super(key: key);

  @override
  _SecondRowState createState() => _SecondRowState();
}

class _SecondRowState extends State<SecondRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/board",
                  arguments: {'boardId': 'neck_pain'},
                );
              },
              child: Container(
                alignment: Alignment.center,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("颈椎难受"),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/emo");
              },
              child: Container(
                alignment: Alignment.center,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("emo了"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
