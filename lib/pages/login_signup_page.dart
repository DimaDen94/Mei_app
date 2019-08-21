import 'package:flutter/material.dart';
import 'package:mei_app/services/authentication.dart';

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _errorMessage;

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in: $userId');
        } else {
          userId = await widget.auth.signUp(_email, _password);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog();
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 &&
            userId != null &&
            _formMode == FormMode.LOGIN) {
          widget.onSignedIn();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    }
  }

  void _validateAndSubmitFB()  async{
    String userId = "";
    userId = await widget.auth.signUpWithFB();
    print('Signed up user: $userId');
    if (userId.length > 0 &&
        userId != null &&
        _formMode == FormMode.LOGIN) {
      widget.onSignedIn();
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        body: Stack(
      children: <Widget>[
        _showBody(),
        _showCircularProgress(),
      ],
    ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          backgroundColor: Colors.deepPurpleAccent,
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                _changeFormToLogin();
                Navigator.of(context).pop();
                widget.onSignedIn();

              },
            ),
          ],
        );
      },
    );
  }

  Widget _showBody() {
    return new Container(
        padding: EdgeInsets.fromLTRB(16.0, .0, 16.0, 0.0),
        color: Color(0xFF183e6d),
        alignment: AlignmentDirectional(0.0, 0.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showLogo(),
              _showEmailInput(),
              _showPasswordInput(),
              _showPrimaryButton(),
              _showOrText(),
              _showFacebookButton(),
              _showDivider(),
              _showSecondaryButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showLogo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 0.0),
      child: new Image(
        image: AssetImage("assets/images/logo.png"),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintStyle: TextStyle(fontSize: 16.0, color: Colors.white60),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            hintText: 'Your email',
            prefixIcon: new Image.asset('assets/icons/customer.png',
                scale: 2.2, width: 48.0, height: 48.0)),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintStyle: TextStyle(fontSize: 16.0, color: Colors.white60),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            hintText: 'Your password',
            prefixIcon: new Image.asset('assets/icons/lock.png',
                scale: 1.8, width: 48.0, height: 48.0)),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget _showOrText() {
    return new Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: new Container(
            child: new Row(mainAxisSize: MainAxisSize.min, children: [
              Text('— OR —',
                  style: new TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w300,
                      color: Colors.white60))
            ]),
            alignment: Alignment(0.0, 0.0)));
  }

  Widget _showSecondaryButton() {
    return new Padding(
        padding: EdgeInsets.only(top: 1.0),
        child: new Container(
            child: new Row(mainAxisSize: MainAxisSize.min, children: [
              new FlatButton(
                child: new Text('Forgot details?',
                    style: new TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w300,
                        color: Colors.white60)),
                onPressed: _changeFormToLogin,
              ),
              new FlatButton(
                child: _formMode == FormMode.LOGIN
                    ? new Text('Create an account',
                        style: new TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w300,
                            color: Colors.white60))
                    : new Text('          Sign in          ',
                        style: new TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w300,
                            color: Colors.white60)),
                onPressed: _formMode == FormMode.LOGIN
                    ? _changeFormToSignUp
                    : _changeFormToLogin,
              )
            ]),
            alignment: Alignment(0.0, 0.0)));
  }

  Widget _showFacebookButton() {
    return new Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: new Container(
            child: new Row(mainAxisSize: MainAxisSize.min, children: [
              new Image(
                image: AssetImage("assets/icons/facebook.png"),
                fit: BoxFit.cover,
                width: 24.0,
                height: 24.0,
              ),
              FlatButton(
                child: new Text('Continue with Facebook',
                    style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300,
                        color: Colors.white)),
                onPressed: _validateAndSubmitFB,
              )
            ]),
            alignment: Alignment(0.0, 0.0)));
  }

  Widget _showDivider() {
    return new Padding(
      padding:
          const EdgeInsets.only(top: 0.0, bottom: 6.0, right: 20.0, left: 20.0),
      child: new Divider(
        color: Colors.white60,
      ),
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: new Container(
          child: new Row(mainAxisSize: MainAxisSize.min, children: [
            new SizedBox(
              height: 50.0,
              width: 180.0,
              child: new RaisedButton(
                elevation: 5.0,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Color(0xFFBD3C41),
                child: _formMode == FormMode.LOGIN
                    ? new Text('Login',
                        style:
                            new TextStyle(fontSize: 20.0, color: Colors.white))
                    : new Text('Create account',
                        style:
                            new TextStyle(fontSize: 20.0, color: Colors.white)),
                onPressed: _validateAndSubmit,
              ),
            ),
          ]),
          alignment: Alignment(0.0, 0.0)),
    );
  }
}
