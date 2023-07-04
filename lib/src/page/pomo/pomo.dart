import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PomoPage extends StatefulWidget {
  const PomoPage({super.key});

  @override
  State<StatefulWidget> createState() => _PomoPage();
}

class _PomoPage extends State<PomoPage> {
  DateTime? startAt;
  Duration pomoSize = Duration(minutes: 25);

  Stream<Duration> _clock() async* {
    // This loop will run forever because _running is always true
    while (startAt != null) {
      await Future<void>.delayed(const Duration(seconds: 1));

      Duration used = DateTime.now().difference(startAt!);
      if(used > pomoSize) {
        setState(() {
          startAt = null;
        });
      } else {
        yield used;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(startAt == null) {
      return ElevatedButton(
        onPressed: (){
          setState(() {
            startAt = DateTime.now();
          });
        },
        child: const Text("Start"),
      );
    }

    return StreamBuilder(
      stream: _clock(),
      builder: (context, AsyncSnapshot<Duration> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text("Used: "),
            Text(
              buildText(snapshot.data!),
              style: const TextStyle(fontSize: 50, color: Colors.blue),
            ),
            const Text("Rem: "),
            Text(
              buildText(pomoSize - snapshot.data!),
              style: const TextStyle(fontSize: 50, color: Colors.blue),
            ),
          ],
        );
      },
    );
  }
}

String buildText(Duration duration) {
  int seconds = duration.inSeconds;
  return "${seconds ~/ 60}:${seconds%60}";
}
