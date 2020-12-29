import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/pages/home.dart';
import 'package:flutter_app/widgets/post.dart';
import 'package:flutter_app/widgets/progress.dart';

import '../services,.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final UserModel currentUser;

  Timeline({Key key, this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List databasePosts = [];
  List documents = [];
  List<Post> posts;

  @override
  void initState() {
    Services.timelineRef.doc(currentUser.id).delete();
    super.initState();
    getFollowedUser();
    getTimeline();
  }

  getFollowedUser() async {
    final snapshot = await Services.followingRef
        .doc(widget.currentUser.id)
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

    int r = 0;
    for (final i in databasePosts) {
      Services.timelineRef
          .doc(widget.currentUser.id)
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

  getTimeline() async {
    setState(() {});
    QuerySnapshot snapshot = await Services.timelineRef
        .doc(widget.currentUser.id)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .get();
    posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();

    setState(() {
      this.posts = posts;
      buildTimeline();
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Center(
          child: Text(
        "No Posts To Show",
        style: TextStyle(
          fontSize: 26,
          color: Colors.grey[600],
        ),
      ));
    } else {
      return ListView(children: posts);
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
        body: RefreshIndicator(
      onRefresh: () => getTimeline(),
      child: buildTimeline(),
    ));
  }
}
