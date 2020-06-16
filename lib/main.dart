import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'board.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Board',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Board> boardMessages = List();    //a list of objects Board , boardMessages is used to add all the board objects we are retrieving and send to our db
  Board board; //a Board object
  final FirebaseDatabase database = FirebaseDatabase.instance; //handle to get in our firebase db (a db reference/ a db object)
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();//it will help us to get a form key handle to use
  DatabaseReference databaseReference; // databaseReference object

  @override
  void initState() {
    super.initState();

    board = Board("", "");  //instantiate board
    databaseReference = database.reference().child("community_board"); //creating a tree , child is what we ill be adding to our realtime db
    databaseReference.onChildAdded.listen(_onEntryAdded); //allows us to have a callback from db .listen will continuously be listening to changes being added onto db
    databaseReference.onChildChanged.listen(_onEntryChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Community board"),
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              flex: 0,
              child: Center(

                child: Form(
                  key: formKey,
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.subject),
                        title: TextFormField(
                          initialValue: "",
                          onSaved: (val) => board.subject = val,  //setting board instance field of the object to whatever we are passing
                          validator: (val) => val == "" ? val : null,
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.message),
                        title: TextFormField(
                          initialValue: "",
                          onSaved: (val) => board.body = val,
                          validator: (val) => val == "" ? val : null,
                        ),
                      ),

                      //Send or Post button
                      FlatButton(
                        child: Text("Post"),
                        color: Colors.greenAccent,
                        onPressed: () {
                          handleSubmit();
                        },
                      )

                    ],
                  ),
                ),
              ),),

            //to show dynamically all of the board communications we are adding into our db to be shown as a Listview in the UI
            Flexible(
                child: FirebaseAnimatedList(      // we could have also gone by creating a Listview Builder. FirebaseAnimatedList is a Listview Builder that has all the things we need to query a firebase db and list all the items in a Listview
                  query: databaseReference,      //query will hold the data from our db . We get that from passing in the datbaseReference as such
                  itemBuilder: (_, DataSnapshot snapshot, // Because FirebaseAnimatedList is a Listview , thus itemBuilder. _ is context
                      Animation<double> animation, int index) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                        ),
                        title: Text(boardMessages[index].subject),
                        subtitle: Text(boardMessages[index].body),
                      ),
                    );
                  },
                )
            ),
          ],
        )
    );
  }

  void _onEntryAdded(Event event) {
    setState(() {          //setState will go ahead and rebuild the UI
      boardMessages.add(Board.fromSnapshot(event.snapshot));
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;
    if (form.validate()) {   //if all our fields have data
      form.save(); //save
      form.reset(); //clear out
      //save form data to the db
      databaseReference.push().set(board.toJson()); //push() gives each item we add into our db a very unique key
    }
  }

  void _onEntryChanged(Event event) {
    var oldEntry = boardMessages.singleWhere((entry) {  //singleWhere is used to compare element we want to compare
      return entry.key == event.snapshot.key;
    });
    setState(() {
      boardMessages[boardMessages.indexOf(oldEntry)] = Board.fromSnapshot(event.snapshot);
    });
  }
}



//database.reference().child("message").set({   //reading from db
//   "firstname": "Adeeb"
//});
//setState((){
//  database.reference().child("message").once().then((DataSnapshot snapshot){
//    Map<dynamic,dynamic> data = snapshot.value;
//    print("Values from db: ${snapshot.value}");
//});