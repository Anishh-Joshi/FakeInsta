import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Services{

  static final GoogleSignIn googleSignIn = GoogleSignIn();
  static final commentsRef = FirebaseFirestore.instance.collection("comments");
  static final activityFeedRef = FirebaseFirestore.instance.collection("feed");
  static final postRef = FirebaseFirestore.instance.collection("post");
  static Reference storageRef = FirebaseStorage.instance.ref();
  static final usersRef = FirebaseFirestore.instance.collection('users');
  static final DateTime timestamp = DateTime.now();
  static final followersRef = FirebaseFirestore.instance.collection("followers");
  static final followingRef = FirebaseFirestore.instance.collection("following");
  static final timelineRef = FirebaseFirestore.instance.collection('timelinePost');

}