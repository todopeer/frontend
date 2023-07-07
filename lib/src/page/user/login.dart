import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../env.dart';
import '../../gql/api.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  final Env env;

  const LoginPage({super.key, required this.env});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? errorMessage;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  List<Widget> inputFields(BuildContext context) {
    return [
      TextFormField(
        controller: _emailController,
        decoration: const InputDecoration(
          hintText: "Email",
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          // Regular expression pattern to match email format
          const pattern = r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$';
          final regex = RegExp(pattern);

          // Check if the email matches the pattern
          if (!regex.hasMatch(value)) {
            return "Invalid email format";
          }

          return null;
        },
      ),
      TextFormField(
        controller: _passwordController,
        decoration: const InputDecoration(
          hintText: "Password",
        ),
        obscureText: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext ctx) {
    var form = <Widget>[];
    if(errorMessage != null) {
      form.add(Text(errorMessage!));
    }
    form.addAll(inputFields(context));
    form.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Mutation(
        options: MutationOptions(
          document: gql(gqlMutationLogin),
          onCompleted: (dynamic resultData) {
            if(resultData == null) {
              return;
            }

            final String token = resultData['login']['token'];
            widget.env.tokenNotifier.value = token;

            print("completed, data: ");
            print(inspect(resultData));
          },
          onError: (err) {
            if(err == null) {
              return;
            }

            setState(() {
              this.errorMessage = err.graphqlErrors.map((e) => e.message).join(";");
            });
          },
        ),
        builder: buildSubmitButton,
      ),
    ));
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: form,
    );
  }

  Widget buildSubmitButton(RunMutation runMutation, QueryResult<Object?>? result) {
    if(result == null || result.data == null) {
      return ElevatedButton(
        onPressed: () {
          // TODO: check why this would error
          // if (!_formKey.currentState!.validate()) {
          //   return;
          // }

          // do the login
          var email = _emailController.value.text;
          var password = _passwordController.value.text;

          runMutation({
            "email": email,
            "password": password,
          });
        },
        child: const Text('Submit'),
      );
    }

    if(result.hasException) {
      return Text(result.exception.toString());
    }

    if(result.isLoading) {
      return const Text("Loading...");
    }

    return Text("Got Data: ${result.data}");
  }
}