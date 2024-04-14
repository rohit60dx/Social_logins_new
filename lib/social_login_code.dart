import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homescreen.dart';

class LoginSample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginSampleState();
  }
}

class _LoginSampleState extends State<LoginSample> {
  final _formKey = GlobalKey<FormState>();
  final RegExp emailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final RegExp regex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var _passwordVisible;
  var prefs;

  sharedPrefernceInilization() async {
    prefs = await SharedPreferences.getInstance();
  }

  setValueInPrefernce(String email) async {
    await prefs.setString('name', email).then((v) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  //--------------_Facebook variable--------------
  final fb = FacebookLogin();
  //-------------call facebook method---------------
  callFacebookLogin() async {
    final res = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

// Check result status
    switch (res.status) {
      case FacebookLoginStatus.success:
        // Logged in

        // Send access token to server for validation and auth
        final FacebookAccessToken accessToken = res.accessToken!;
        print('Access token: ${accessToken.token}');

        // Get profile data
        final profile = await fb.getUserProfile();
        print('Hello, ${profile!.name}! You ID: ${profile.userId}');

        // Get user profile image url
        final imageUrl = await fb.getProfileImageUrl(width: 100);
        print('Your profile image: $imageUrl');

        // Get email (since we request email permission)
        final email = await fb.getUserEmail();
        // But user can decline permission
        if (email != null) print('And your email is $email');

        break;
      case FacebookLoginStatus.cancel:
        // User cancel log in
        break;
      case FacebookLoginStatus.error:
        // Log in failed
        print('Error while log in: ${res.error}');
        break;
    }
  }

  @override
  void initState() {
    _passwordVisible = false;
    sharedPrefernceInilization();
  }

  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Facebook Setup Page"),
          backgroundColor: Colors.indigo,
        ),
        body: Container(
          child: Form(
            key: _formKey,
            child: Container(
              margin: EdgeInsets.all(60),
              child: Column(
                children: <Widget>[
                  // SizedBox(height: 80,),
                  TextFormField(
                      controller: emailController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          /*prefixIcon: Icon(Icons.email)*/
                          suffixIcon: Icon(Icons.email_sharp)),
                      validator: (emailid) {
                        if (emailid == null || emailid.isEmpty) {
                          return 'Please enter your email ID';
                        } else if (!emailid.contains(emailValid)) {
                          return 'Please enter Valid email ID';
                        } else {
                          return null;
                        }
                      }),
                  TextFormField(
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      /*prefixIcon: Icon(Icons.password),*/
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_passwordVisible,
                    validator: (password) {
                      if (password == null || password.isEmpty) {
                        return 'Please enter your password';
                      } else if (!password.contains(regex)) {
                        return "Password should contain Upper,Lower,Digit\nSpecial character and\nMust be at least 8 characters in length";
                      } else {
                        return null;
                      }
                    },
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // showDialog(
                        //   context: context,
                        //   builder: (context) {
                        //     return AlertDialog(
                        //       content: Text("LogIn Successful"),
                        setValueInPrefernce(emailController.text);

                        //       );
                        //   },
                        // );
                      }
                    },
                    child: const Text('Log In'),
                  ),
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: () {
                            callFacebookLogin();
                          },
                          child: Icon(
                            Icons.facebook,
                            color: Colors.indigo,
                            size: 50,
                          )),
                      Container(
                        child: Icon(
                          Icons.email,
                          color: Colors.black,
                          size: 50,
                        ),
                        margin: EdgeInsets.only(right: 20, left: 20),
                      ),
                      Icon(
                        Icons.whatsapp,
                        color: Colors.green,
                        size: 50,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(child: Text("")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
