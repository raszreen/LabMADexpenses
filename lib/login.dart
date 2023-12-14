import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dailyexpenses.dart';

void main() {
  runApp(const MaterialApp(
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ipAddressController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //for image network
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child:
            //     FadeInImage.memoryNetwork(
            //         placeholder: kTransparentImage,
            //         image: "transparent-money-finance-wallet-payment-daily-"),
            // ),

            //for insert image
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('assets/dailyExpenses.jpg'),
            ),

            //username
            Padding(
                padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
            ),

            //password
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
              controller: passwordController,
              obscureText: true, // hide the password
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: ipAddressController,
                decoration: InputDecoration(
                  labelText: "REST API address",
                ),),
            ),

            ElevatedButton(
                onPressed: () async{
                  // implemented login logic here
                  String username = usernameController.text;
                  String password = passwordController.text;
                  if (username == 'raszreen' && password == '12345678') {
                    // navigate to the daily expense screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyExpensesApp(username: username),
                    ),
                    );
                  } else {
                    // show an error message or handle invalid login
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Login Failed'),
                            content: const Text('Invalid username or password.'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                  onPressed: () {
                                  Navigator.pop(context);
                                  },
                              ),
                            ],
                          );
                        },
                    );
                  }
                },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
