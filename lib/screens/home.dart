import 'package:flutter/material.dart';
import 'package:flutube/models/models.dart';
import 'package:flutube/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        FTVideo(
          video: Video(
            title:
                "Doloremque officiis quia perspiciatis eaque labore maxime recusandae maiores.",
            url: "example.com",
            views: 135400,
            date: DateTime.now().subtract(Duration(days: 15)),
            owner: "Lorem Ipsum",
          ),
        ),
      ],
    );
  }
}
