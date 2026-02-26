import 'package:flutter/material.dart';

class FirstRow extends StatefulWidget {
  FirstRow({Key? key}) : super(key: key);

  @override
  _FirstRowState createState() => _FirstRowState();
}

class _FirstRowState extends State<FirstRow> {
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
                  arguments: {'boardId': 'normal'},
                );
              },
              child: Container(
                alignment: Alignment.center,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("无异常"),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/board",
                  arguments: {'boardId': 'late_sleep'},
                );
              },
              child: Container(
                alignment: Alignment.center,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("睡得晚"),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/board",
                  arguments: {'boardId': 'eye_strain'},
                );
              },
              child: Container(
                alignment: Alignment.center,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("视疲劳"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
