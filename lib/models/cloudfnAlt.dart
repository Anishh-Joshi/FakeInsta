
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services,.dart';

List documents = [];
List databasePosts = [];
buildTimelineCommand(String currentUser) async{
  final snapshot = await Services.followingRef
      .doc(currentUser)
      .collection('userFollowing')
      .get();
  snapshot.docs.forEach((doc) => {documents.add(doc.id)});

  for (int k = 0; k < documents.length; k++) {
    QuerySnapshot newSnapshot =
    await Services.postRef.doc(documents[k]).collection("userPost").get();
    newSnapshot.docs.forEach((element) {
      databasePosts.add(element);
    });
  }

  int r=0;
  for (final i in databasePosts) {
    Services.timelineRef
        .doc(currentUser)
        .collection("posts")
        .doc(r.toString())
        .set({
      'mediaUrl': i['mediaUrl'],
      'username': i['username'],
      'description': i['description'],
      'location': i['location'],
      'postId': i['postId'],
      'ownerId': i['ownerId'],
      'timestamp': i['timestamp'],
      'likes': i["likes"],
    });
    r++;
  }
}