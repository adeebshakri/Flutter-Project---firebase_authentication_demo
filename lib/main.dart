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
  List<Board> boardMessages = List();
  Board board;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference databaseReference; // databaseReference object

  @override
  void initState() {
    super.initState();

    board = Board("", "");
    databaseReference =
        database.reference().child("community_board"); //creating a tree
    databaseReference.onChildAdded.listen(
        _onEntryAdded); //allows us to have a callback from db .listen will continuously be listening to changes being added onto db
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
                          onSaved: (val) => board.subject = val,
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
            Flexible(
                child: FirebaseAnimatedList(
                  query: databaseReference,
                  //query will hold the data from our db . We get that from passing in the datbaseReference as such
                  itemBuilder: (_, DataSnapshot snapshot,
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
    setState(() {
      boardMessages.add(Board.fromSnapshot(event.snapshot));
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save(); //save
      form.reset(); //clear out
      //save form data to the db
      databaseReference.push().set(board
          .toJson()); //push() gives each item we add into our db a very unique key
    }
  }

  void _onEntryChanged(Event event) {
    var oldEntry = boardMessages.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      boardMessages[boardMessages.indexOf(oldEntry)] =
          Board.fromSnapshot(event.snapshot);
    });
  }
}
