import 'package:flutter/material.dart';

class PublicUserPage extends StatefulWidget {
  static const routeName = "/public/";

  final String username;

  const PublicUserPage({super.key, required this.username});

  @override
  State<StatefulWidget> createState() => _PublicUserPage();
}

class _PublicUserPage extends State<PublicUserPage> {
  @override
  Widget build(BuildContext context) {
    final username = widget.username;
    return Scaffold(
      appBar: AppBar(title: Text("User $username")),
      body: Column(
        children: [
          Text("Public View on $username"),
        ],
      ),
    );
  }
}