import 'package:flutter/cupertino.dart';

class Env {
  Env({required this.tokenNotifier});

  final ValueNotifier<String?> tokenNotifier;
}