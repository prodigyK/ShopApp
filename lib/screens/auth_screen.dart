import 'package:course_shop_app/models/http_exception.dart';
import 'package:course_shop_app/providers/auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth-screen';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: screenSize.width - 40,
                    margin: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                    transform: Matrix4.rotationZ(-8 * pi / 180)..translate(-10.0),
                    decoration: BoxDecoration(
                        color: Colors.deepOrange.shade900,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            offset: Offset(0, 2),
                            color: Colors.black26,
                          ),
                        ]),
                    child: Center(
                        child: Text(
                      'MyShop',
                      style: TextStyle(
                        color: Theme.of(context).accentTextTheme.headline6.color,
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Anton',
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    )),
                  ),
                  SizedBox(height: 10),
                  AuthCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final _form = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  Future<void> _saveFormAndSubmit() async {
    if (!_form.currentState.validate()) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // Login
        print('login');
        await Provider.of<Auth>(context, listen: false).signIn(_authData['email'], _authData['password']);
      } else {
        // Sign up
        print('sign up');
        await Provider.of<Auth>(context, listen: false).signUp(_authData['email'], _authData['password']);
      }
    } on HttpException catch (error) {
      print('on HttpException catch (error)');
      print(error.toString());
      String errorMessage = 'Authentication error.';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = ' The email address is already in use by another account.';
      }
      if (error.toString().contains('OPERATION_NOT_ALLOWED')) {
        errorMessage = 'Password sign-in is disabled for this project.';
      }
      if (error.toString().contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
        errorMessage = 'We have blocked all requests from this device due to unusual activity. Try again later.';
      }
      if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'There is no user record corresponding to this identifier. The user may have been deleted.';
      }
      if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'The password is invalid or the user does not have a password.';
      }
      if (error.toString().contains('USER_DISABLED')) {
        errorMessage = 'The user account has been disabled by an administrator.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      print('inside error block');
      print(error.toString());
      _showErrorDialog(error.toString());
    } finally {
      print('finally');
    }

    setState(() {
      _isLoading = false;
    });

  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        elevation: 10,
        duration: Duration(seconds: 5),
      ),
    );
//    showDialog(
//      context: context,
//      builder: (ctx) => AlertDialog(
//        title: Text('An Error Occured'),
//        content: Text(message),
//        actions: [
//          TextButton(
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//              child: Text('OK')),
//        ],
//      ),
//    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'E-Mail'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty || !value.contains('@')) {
                    return 'Enter correct value';
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['email'] = value;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                obscureText: true,
                validator: (value) {
                  if (value.isEmpty || value.length < 5) {
                    return 'Password should have 5 symbols at least';
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['password'] = value;
                },
              ),
              if (_isLogin != true)
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  validator: (value) {
                    final password = _passwordController.text;
                    if (value != password) {
                      return 'Passwords are not equal';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 25),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      child: Text(_isLogin ? 'LOGIN' : 'SIGN UP'),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 10,
                          ),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _saveFormAndSubmit();
                      },
                    ),
              TextButton(
                child: Text(
                  _isLogin ? 'SIGN UP INSTEAD' : 'LOGIN INSTEAD',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
