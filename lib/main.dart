import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth - Firebase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _MyHomePage();
}

class _MyHomePage extends State<MyHomePage>{
String _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Community board"),
        ),

        body:Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center ,
              children: <Widget>[

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(                    // Shortcut:  click on flatbutton and Alt+Enter to add padding
                    child: Text("Google-Signin"),
                    onPressed: () => _gSignin(),
                    color: Colors.red,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    child: Text("Signin with Email"),
                    onPressed: () => _signInWithEmail(),
                    color: Colors.yellow,

                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    child: Text("Create Account"),
                    onPressed: () => _createUser(),
                    color: Colors.purple,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    color: Colors.red,
                    child: Text("Signout"),onPressed: ()=> _signout(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    color: Colors.teal,
                    child: Text("Signout of Email"),onPressed: ()=> _signoutOfEmail(),
                  ),
                ),
                Image.network(_imageUrl == null || _imageUrl.isEmpty ? "https://tse1.mm.bing.net/th?id=OIP.6TahjUtodiFzyOyfxKYsKAHaHC&pid=Api&P=0&w=100&h=95":_imageUrl)
              ],))

    );
  }


  Future<FirebaseUser> _gSignin() async{  //google sign in
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(   //Stackoverflow
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    FirebaseUser user = authResult.user;

    print("User is: " + user.photoUrl);
    setState(() {
      _imageUrl = user.photoUrl;
    });
    return user;
  }

  Future _createUser()async {  //create new account
    FirebaseUser user  = (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: "sampleemail2@gmail.com", password: "test12345")).user ; //stackoverflow
      print("User created ${user.displayName}");
      print("Email: ${user.email}");

    }
    _signout(){
    setState(() {
      _googleSignIn.signOut();
      _imageUrl = null;
    });
    }

  _signInWithEmail() async { //stsckoverflow

      FirebaseUser user = (await _auth.signInWithEmailAndPassword(email: "sampleemail2@gmail.com", password: "test12345")
          .catchError((err){
        print("Something went wrong! ${err.toString()}");
      })).user;
    print("User signed in: ${user.email}");
  }

  _signoutOfEmail() {
    setState(() {
      _auth.signOut();
      _imageUrl = null;
    });
  }
}

//This is only for Android Firebase