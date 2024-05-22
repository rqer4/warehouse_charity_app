import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:synny_space/home_page.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SignInScreen(
              providers: [
                EmailAuthProvider(),
                GoogleProvider(clientId: "261719020003-h1522mruo5h1fgou54c0hrilnbdbjkl4.apps.googleusercontent.com", ),
              ],
              headerBuilder: (context, constraints, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset('assets/images/sugar.jpg')),
                );
              },
              subtitleBuilder: (context, action) {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 0),
                    child: action == AuthAction.signIn
                        ? const Text(
                            'Welcome to Sunny base. Please sign in!',
                            style: TextStyle(
                              color: Color.fromARGB(255, 8, 68, 118),
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : const Text(
                            'Welcome to Sunny base. Please register!',
                            style: TextStyle(
                                color: Color.fromARGB(255, 8, 68, 118),
                                fontStyle: FontStyle.italic),
                          ));
              },
              footerBuilder: (context, action) {
                return const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Bu singing in, you agree with our terms and conditions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                );
              },
              sideBuilder: (context, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset('assets/images/soda.jpg'),
                  ),
                );
              },
            );
          }
          return const HomePage();
        });
  }
}
