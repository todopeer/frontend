import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todopeer/src/env.dart';
import 'package:todopeer/src/gql/provider.dart';

import 'src/app.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  WidgetsFlutterBinding.ensureInitialized();

  // build the ENV to be passed down
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final tokenNotifier = ValueNotifier(prefs.getString("token"));
  tokenNotifier.addListener(() {
    if(tokenNotifier.value == null) {
      prefs.remove("token");
    } else {
      prefs.setString("token", tokenNotifier.value!);
    }
   });
  var env = Env(tokenNotifier: tokenNotifier);

  // HttpLink httpLink = HttpLink('https://api.todopeer.com/query');
  // final AuthLink authLink = AuthLink(
  //   getToken: () async {
  //     var token = prefs.getString('token');
  //     if(token == null || token.isEmpty) {
  //       return '';
  //     } else {
  //       return 'Bearer $token';
  //     }
  //   },
  // );
  // final Link link = authLink.concat(httpLink);
  //
  // ValueNotifier<GraphQLClient> client = ValueNotifier(
  //   GraphQLClient(link: link, cache: GraphQLCache()),
  // );

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.

  // runApp(MyApp(prefs: prefs, client: client,));

  runApp(ClientProvider(child: MyApp(env: env), uri: "https://api.todopeer.com/query", tokenGetter: tokenNotifier));
}
