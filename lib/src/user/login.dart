import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  static const routeName = '/login';

  const LoginView({super.key});

  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"),),
     body: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              hintText: "Email",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              // Regular expression pattern to match email format
              final pattern = r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$';
              final regex = RegExp(pattern);

              // Check if the email matches the pattern
              if (!regex.hasMatch(value)) {
                return "Invalid email format";
              }

              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: "Password",
            ),
            obscureText: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child:
            ElevatedButton(
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate()) {
                  print("Validated. would proceed");
                  // Process data.
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    )

    );
  }
}