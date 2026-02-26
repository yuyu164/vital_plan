import 'package:flutter/material.dart';

class RecommendDart extends StatefulWidget {
  RecommendDart({Key? key}) : super(key: key);

  @override
  _RecommendDartState createState() => _RecommendDartState();
}

class _RecommendDartState extends State<RecommendDart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, "/healthRecommend");
        },
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.5,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text("养生推荐"),
        ),
      ),
    );
  }
}
