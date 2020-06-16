import 'package:firebase_database/firebase_database.dart';

class Board {  //Board model class
  String key;  //instance variables
  String subject;
  String body;

  Board(this.subject, this.body); //constructor

  Board.fromSnapshot(DataSnapshot snapshot)  //Parsing things from db, DataSnapshot is an object we'll get from our db , snapshot will have the data from the db
      : key = snapshot.key,  //mapping key we are getting from our databse
        subject = snapshot.value["subject"],
        body = snapshot.value["body"];

  toJson() {  //take key,subject and body and make it a json and return a json object  (Mapping of data)
    return {
      "subject": subject,
      "body": body
    };
  }
}
